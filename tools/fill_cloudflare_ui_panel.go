package main

import (
	"flag"
	"fmt"
	"image"
	"image/color"
	"image/png"
	"os"
)

// Fills the keyed center and removes green spill around the frame so the PNG
// can be used as a clean nine-slice texture in Godot.
func main() {
	input := flag.String("input", "", "keyed panel frame PNG")
	output := flag.String("output", "", "panel frame PNG with a solid center")
	margin := flag.Int("margin", 64, "source margin around the transparent center")
	fill := flag.String("fill", "#15181e", "center fill RGB hex color")
	flag.Parse()
	if *input == "" || *output == "" {
		panic("usage: go run tools/fill_cloudflare_ui_panel.go --input keyed.png --output panel.png")
	}
	colorValue, err := parseHex(*fill)
	check(err)
	file, err := os.Open(*input)
	check(err)
	defer file.Close()
	decoded, err := png.Decode(file)
	check(err)
	bounds := decoded.Bounds()
	img := image.NewNRGBA(image.Rect(0, 0, bounds.Dx(), bounds.Dy()))
	filled := 0
	cleaned := 0
	for y := 0; y < img.Bounds().Dy(); y++ {
		for x := 0; x < img.Bounds().Dx(); x++ {
			c := color.NRGBAModel.Convert(decoded.At(bounds.Min.X+x, bounds.Min.Y+y)).(color.NRGBA)
			center := x >= *margin && x < img.Bounds().Dx()-*margin && y >= *margin && y < img.Bounds().Dy()-*margin
			if center && (c.A == 0 || isGreenKey(c)) {
				img.SetNRGBA(x, y, colorValue)
				filled++
			} else if isGreenKey(c) {
				clean := nearestUnkeyedColor(decoded, bounds, x, y)
				clean.A = c.A
				img.SetNRGBA(x, y, clean)
				cleaned++
			} else {
				img.SetNRGBA(x, y, c)
			}
		}
	}
	out, err := os.Create(*output)
	check(err)
	defer out.Close()
	check(png.Encode(out, img))
	fmt.Printf("{\"output\":%q,\"size\":%dx%d,\"center_fill\":%q,\"filled_pixels\":%d,\"green_spill_pixels_cleaned\":%d}\n", *output, img.Bounds().Dx(), img.Bounds().Dy(), *fill, filled, cleaned)
}

func isGreenKey(c color.NRGBA) bool {
	maxOther := int(c.R)
	if int(c.B) > maxOther {
		maxOther = int(c.B)
	}
	return c.G >= 14 && int(c.G)-maxOther >= 8
}

func nearestUnkeyedColor(source image.Image, bounds image.Rectangle, x, y int) color.NRGBA {
	for radius := 1; radius <= 5; radius++ {
		var red, green, blue, count int
		for dy := -radius; dy <= radius; dy++ {
			for dx := -radius; dx <= radius; dx++ {
				distance := abs(dx)
				if abs(dy) > distance {
					distance = abs(dy)
				}
				if distance != radius {
					continue
				}
				sx := bounds.Min.X + x + dx
				sy := bounds.Min.Y + y + dy
				if !image.Pt(sx, sy).In(bounds) {
					continue
				}
				candidate := color.NRGBAModel.Convert(source.At(sx, sy)).(color.NRGBA)
				if candidate.A == 0 || isGreenKey(candidate) {
					continue
				}
				red += int(candidate.R)
				green += int(candidate.G)
				blue += int(candidate.B)
				count++
			}
		}
		if count > 0 {
			return color.NRGBA{R: uint8(red / count), G: uint8(green / count), B: uint8(blue / count), A: 255}
		}
	}
	return color.NRGBA{R: 21, G: 24, B: 30, A: 0}
}

func abs(value int) int {
	if value < 0 {
		return -value
	}
	return value
}

func parseHex(value string) (color.NRGBA, error) {
	if len(value) != 7 || value[0] != '#' {
		return color.NRGBA{}, fmt.Errorf("expected #RRGGBB color, got %q", value)
	}
	var r, g, b uint8
	if _, err := fmt.Sscanf(value, "#%02x%02x%02x", &r, &g, &b); err != nil {
		return color.NRGBA{}, err
	}
	return color.NRGBA{R: r, G: g, B: b, A: 255}, nil
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}
