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

// Removes a nearly uniform charcoal backdrop from Cloudflare art when the
// generator ignores a chroma key. Use only on candidates with a flat backdrop.
func main() {
	input := flag.String("input", "", "source JPEG or PNG")
	output := flag.String("output", "", "destination PNG with alpha")
	tolerance := flag.Int("tolerance", 8, "maximum per-channel distance from the sampled corner color")
	flag.Parse()
	if *input == "" || *output == "" {
		panic("usage: go run tools/key_cloudflare_gray_art.go --input source.jpg --output cutout.png")
	}

	f, err := os.Open(*input)
	check(err)
	defer f.Close()
	source, _, err := image.Decode(f)
	check(err)
	w, h := source.Bounds().Dx(), source.Bounds().Dy()
	pixels := make([]color.NRGBA, w*h)
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			pixels[y*w+x] = color.NRGBAModel.Convert(source.At(source.Bounds().Min.X+x, source.Bounds().Min.Y+y)).(color.NRGBA)
		}
	}

	key := cornerMean(pixels, w, h)
	mask := make([]bool, len(pixels))
	queue := make([]int, 0, len(pixels)/2)
	seed := func(index int) {
		if !mask[index] && maxDistance(pixels[index], key) <= *tolerance {
			mask[index] = true
			queue = append(queue, index)
		}
	}
	for x := 0; x < w; x++ {
		seed(x)
		seed((h-1)*w + x)
	}
	for y := 0; y < h; y++ {
		seed(y * w)
		seed(y*w + w - 1)
	}
	for head := 0; head < len(queue); head++ {
		i := queue[head]
		x, y := i%w, i/w
		for dy := -1; dy <= 1; dy++ {
			for dx := -1; dx <= 1; dx++ {
				if dx == 0 && dy == 0 {
					continue
				}
				nx, ny := x+dx, y+dy
				if nx >= 0 && ny >= 0 && nx < w && ny < h {
					seed(ny*w + nx)
				}
			}
		}
	}

	outImage := image.NewNRGBA(image.Rect(0, 0, w, h))
	removed, softened := 0, 0
	for y := 0; y < h; y++ {
		for x := 0; x < w; x++ {
			i := y*w + x
			c := pixels[i]
			if mask[i] {
				outImage.SetNRGBA(x, y, color.NRGBA{R: c.R, G: c.G, B: c.B, A: 0})
				removed++
				continue
			}
			if !nearMask(mask, x, y, w, h, 1) || maxDistance(c, key) > *tolerance+18 {
				outImage.SetNRGBA(x, y, c)
				continue
			}
			fg, ok := nearestForeground(pixels, mask, x, y, w, h)
			if !ok {
				outImage.SetNRGBA(x, y, c)
				continue
			}
			a := estimateAlpha(c, fg, key)
			if a >= 0.995 {
				outImage.SetNRGBA(x, y, c)
				continue
			}
			if a < 0.2 {
				a = 0.2
			}
			outImage.SetNRGBA(x, y, color.NRGBA{
				R: unmix(c.R, key.R, a),
				G: unmix(c.G, key.G, a),
				B: unmix(c.B, key.B, a),
				A: uint8(a*255 + 0.5),
			})
			softened++
		}
	}

	out, err := os.Create(*output)
	check(err)
	defer out.Close()
	check(png.Encode(out, outImage))
	fmt.Printf("{\"output\":%q,\"width\":%d,\"height\":%d,\"key_rgb\":[%d,%d,%d],\"transparent_pixels\":%d,\"softened_edge_pixels\":%d}\n", *output, w, h, key.R, key.G, key.B, removed, softened)
}

func cornerMean(p []color.NRGBA, w, h int) color.NRGBA {
	var sumR, sumG, sumB, count int
	patch := 12
	for _, origin := range []image.Point{{0, 0}, {w - patch, 0}, {0, h - patch}, {w - patch, h - patch}} {
		for y := origin.Y; y < origin.Y+patch; y++ {
			for x := origin.X; x < origin.X+patch; x++ {
				c := p[y*w+x]
				sumR += int(c.R)
				sumG += int(c.G)
				sumB += int(c.B)
				count++
			}
		}
	}
	return color.NRGBA{R: uint8(sumR / count), G: uint8(sumG / count), B: uint8(sumB / count), A: 255}
}

func maxDistance(a, b color.NRGBA) int {
	dr, dg, db := abs(int(a.R)-int(b.R)), abs(int(a.G)-int(b.G)), abs(int(a.B)-int(b.B))
	if dg > dr {
		dr = dg
	}
	if db > dr {
		dr = db
	}
	return dr
}

func nearMask(mask []bool, x, y, w, h, radius int) bool {
	for dy := -radius; dy <= radius; dy++ {
		for dx := -radius; dx <= radius; dx++ {
			nx, ny := x+dx, y+dy
			if nx >= 0 && ny >= 0 && nx < w && ny < h && mask[ny*w+nx] {
				return true
			}
		}
	}
	return false
}

func nearestForeground(p []color.NRGBA, mask []bool, x, y, w, h int) (color.NRGBA, bool) {
	best, found := color.NRGBA{}, false
	bestDistance := 1 << 30
	for dy := -6; dy <= 6; dy++ {
		for dx := -6; dx <= 6; dx++ {
			nx, ny := x+dx, y+dy
			if nx < 0 || ny < 0 || nx >= w || ny >= h || (dx == 0 && dy == 0) {
				continue
			}
			i := ny*w + nx
			if mask[i] {
				continue
			}
			d := dx*dx + dy*dy
			if d < bestDistance {
				best, bestDistance, found = p[i], d, true
			}
		}
	}
	return best, found
}

func estimateAlpha(observed, foreground, background color.NRGBA) float64 {
	fr, fg, fb := float64(int(foreground.R)-int(background.R)), float64(int(foreground.G)-int(background.G)), float64(int(foreground.B)-int(background.B))
	or, og, ob := float64(int(observed.R)-int(background.R)), float64(int(observed.G)-int(background.G)), float64(int(observed.B)-int(background.B))
	denominator := fr*fr + fg*fg + fb*fb
	if denominator < 1 {
		return 1
	}
	a := (or*fr + og*fg + ob*fb) / denominator
	if a < 0 {
		return 0
	}
	if a > 1 {
		return 1
	}
	return a
}

func unmix(observed, background uint8, alpha float64) uint8 {
	value := (float64(observed) - float64(background)*(1-alpha)) / alpha
	if value < 0 {
		return 0
	}
	if value > 255 {
		return 255
	}
	return uint8(value + 0.5)
}

func abs(value int) int {
	if value < 0 {
		return -value
	}
	return value
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}
