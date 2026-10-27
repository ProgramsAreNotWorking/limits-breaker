package main

import (
	"flag"
	"fmt"
	"image"
	"image/color"
	_ "image/jpeg"
	"image/png"
	"os"
)

func main() {
	input := flag.String("input", "", "source image (JPEG or PNG)")
	output := flag.String("output", "", "destination PNG with alpha")
	keyName := flag.String("key", "green", "chroma key color: green, cyan or magenta")
	flag.Parse()
	if *input == "" || *output == "" {
		fmt.Fprintln(os.Stderr, "usage: go run tools/key_cloudflare_art.go --input source.jpg --output cutout.png")
		os.Exit(2)
	}

	file, err := os.Open(*input)
	check(err)
	defer file.Close()
	source, _, err := image.Decode(file)
	check(err)
	width, height := source.Bounds().Dx(), source.Bounds().Dy()
	key := chromaColor(*keyName)
	if width == 0 || height == 0 {
		panic("source image is empty")
	}
	pixels := make([]color.NRGBA, width*height)
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			pixels[y*width+x] = color.NRGBAModel.Convert(source.At(source.Bounds().Min.X+x, source.Bounds().Min.Y+y)).(color.NRGBA)
		}
	}

	background := make([]bool, len(pixels))
	queue := make([]int, 0, width*height/2)
	seed := func(index int) {
		if !background[index] && isKeyCandidate(pixels[index], *keyName) {
			background[index] = true
			queue = append(queue, index)
		}
	}
	for x := 0; x < width; x++ {
		seed(x)
		seed((height-1)*width + x)
	}
	for y := 0; y < height; y++ {
		seed(y * width)
		seed(y*width + width - 1)
	}

	for head := 0; head < len(queue); head++ {
		index := queue[head]
		x, y := index%width, index/width
		for dy := -1; dy <= 1; dy++ {
			for dx := -1; dx <= 1; dx++ {
				if dx == 0 && dy == 0 {
					continue
				}
				nx, ny := x+dx, y+dy
				if nx < 0 || ny < 0 || nx >= width || ny >= height {
					continue
				}
				seed(ny*width + nx)
			}
		}
	}

	// Remove vivid key color even when it is enclosed by a frame, then soften
	// the few contaminated pixels next to the keyed region.
	for i, c := range pixels {
		if isStrongKey(c, *keyName) {
			background[i] = true
		}
	}
	outputImage := image.NewNRGBA(image.Rect(0, 0, width, height))
	removed, softened := 0, 0
	for y := 0; y < height; y++ {
		for x := 0; x < width; x++ {
			index := y*width + x
			c := pixels[index]
			if background[index] {
				outputImage.SetNRGBA(x, y, color.NRGBA{R: c.R, G: c.G, B: c.B, A: 0})
				removed++
				continue
			}
			if !nearBackground(background, x, y, width, height, 4) || keyDominance(c, *keyName) < 2 || keyStrength(c, *keyName) < 48 {
				outputImage.SetNRGBA(x, y, c)
				continue
			}

			alpha := estimateAlpha(c, pixels, background, x, y, width, height, *keyName, key)
			if alpha >= 0.998 {
				outputImage.SetNRGBA(x, y, c)
				continue
			}
			if alpha < 0.04 {
				alpha = 0.04
			}
			outputImage.SetNRGBA(x, y, color.NRGBA{
				R: unmix(c.R, key.R, alpha),
				G: unmix(c.G, key.G, alpha),
				B: unmix(c.B, key.B, alpha),
				A: uint8(alpha * 255.0),
			})
			softened++
		}
	}

	out, err := os.Create(*output)
	check(err)
	defer out.Close()
	encoder := png.Encoder{CompressionLevel: png.BestCompression}
	check(encoder.Encode(out, outputImage))
	fmt.Printf("{\"output\":%q,\"width\":%d,\"height\":%d,\"transparent_pixels\":%d,\"softened_edge_pixels\":%d}\n", *output, width, height, removed, softened)
}

func chromaColor(name string) color.NRGBA {
	switch name {
	case "green":
		return color.NRGBA{G: 255, A: 255}
	case "cyan":
		return color.NRGBA{G: 255, B: 255, A: 255}
	case "magenta":
		return color.NRGBA{R: 255, B: 255, A: 255}
	default:
		panic("key must be green, cyan or magenta")
	}
}

func keyStrength(c color.NRGBA, name string) int {
	switch name {
	case "green":
		return int(c.G)
	case "cyan":
		return minInt(int(c.G), int(c.B))
	case "magenta":
		return minInt(int(c.R), int(c.B))
	default:
		return 0
	}
}

func keyDominance(c color.NRGBA, name string) int {
	switch name {
	case "green":
		return int(c.G) - maxInt(int(c.R), int(c.B))
	case "cyan":
		return minInt(int(c.G), int(c.B)) - int(c.R)
	case "magenta":
		return minInt(int(c.R), int(c.B)) - int(c.G)
	default:
		return -255
	}
}

func isKeyCandidate(c color.NRGBA, name string) bool {
	return keyStrength(c, name) >= 96 && keyDominance(c, name) >= 20
}

func isStrongKey(c color.NRGBA, name string) bool {
	switch name {
	case "green":
		return int(c.G) >= 150 && int(c.R) <= 125 && int(c.B) <= 125 && keyDominance(c, name) >= 38
	case "cyan":
		return int(c.G) >= 150 && int(c.B) >= 150 && int(c.R) <= 125 && keyDominance(c, name) >= 38
	case "magenta":
		return int(c.R) >= 150 && int(c.B) >= 150 && int(c.G) <= 125 && keyDominance(c, name) >= 38
	default:
		return false
	}
}

func nearBackground(mask []bool, x, y, width, height, radius int) bool {
	for dy := -radius; dy <= radius; dy++ {
		for dx := -radius; dx <= radius; dx++ {
			nx, ny := x+dx, y+dy
			if nx >= 0 && ny >= 0 && nx < width && ny < height && mask[ny*width+nx] {
				return true
			}
		}
	}
	return false
}

func estimateAlpha(observed color.NRGBA, pixels []color.NRGBA, background []bool, x, y, width, height int, keyName string, key color.NRGBA) float64 {
	bestDistance := 999
	var foreground color.NRGBA
	for dy := -4; dy <= 4; dy++ {
		for dx := -4; dx <= 4; dx++ {
			nx, ny := x+dx, y+dy
			if nx < 0 || ny < 0 || nx >= width || ny >= height || (dx == 0 && dy == 0) {
				continue
			}
			index := ny*width + nx
			if background[index] || keyDominance(pixels[index], keyName) > 18 {
				continue
			}
			distance := dx*dx + dy*dy
			if distance < bestDistance {
				bestDistance = distance
				foreground = pixels[index]
			}
		}
	}
	if bestDistance == 999 {
		return clamp01(1.0 - float64(keyDominance(observed, keyName))/255.0)
	}

	fr, fg, fb := float64(int(foreground.R)-int(key.R)), float64(int(foreground.G)-int(key.G)), float64(int(foreground.B)-int(key.B))
	or, og, ob := float64(int(observed.R)-int(key.R)), float64(int(observed.G)-int(key.G)), float64(int(observed.B)-int(key.B))
	denominator := fr*fr + fg*fg + fb*fb
	if denominator < 1.0 {
		return 1.0
	}
	return clamp01((or*fr + og*fg + ob*fb) / denominator)
}

func clamp01(value float64) float64 {
	if value < 0 {
		return 0
	}
	if value > 1 {
		return 1
	}
	return value
}

func clamp8(value float64) uint8 {
	if value < 0 {
		return 0
	}
	if value > 255 {
		return 255
	}
	return uint8(value + 0.5)
}

func unmix(observed, key uint8, alpha float64) uint8 {
	return clamp8((float64(observed) - float64(key)*(1.0-alpha)) / alpha)
}

func minInt(a, b int) int {
	if a < b {
		return a
	}
	return b
}

func maxInt(a, b int) int {
	if a > b {
		return a
	}
	return b
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}
