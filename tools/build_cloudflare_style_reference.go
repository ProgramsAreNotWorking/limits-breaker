package main

import (
	"fmt"
	"image"
	"image/color"
	_ "image/jpeg"
	"image/png"
	"os"
)

// Builds a materials-only reference board from the approved player master.
// It is an input reference for future model generations, never a game asset.
func main() {
	if len(os.Args) != 3 {
		panic("usage: go run tools/build_cloudflare_style_reference.go player-cutout.png style-reference.png")
	}
	in, err := os.Open(os.Args[1])
	check(err)
	defer in.Close()
	source, _, err := image.Decode(in)
	check(err)

	board := image.NewRGBA(image.Rect(0, 0, 512, 512))
	background := color.RGBA{R: 19, G: 20, B: 23, A: 255}
	for y := 0; y < 512; y++ {
		for x := 0; x < 512; x++ {
			board.SetRGBA(x, y, background)
		}
	}

	// Swatches show cloak, plate, burgundy cloth and dark steel without a full
	// character silhouette or face, reducing pose and identity transfer.
	regions := []image.Rectangle{
		image.Rect(174, 104, 286, 216),
		image.Rect(218, 142, 330, 254),
		image.Rect(194, 182, 306, 294),
		image.Rect(174, 252, 286, 364),
	}
	positions := []image.Point{{16, 16}, {272, 16}, {16, 272}, {272, 272}}
	for i, region := range regions {
		for y := 0; y < 224; y++ {
			for x := 0; x < 224; x++ {
				sx := region.Min.X + x*region.Dx()/224
				sy := region.Min.Y + y*region.Dy()/224
				p := color.NRGBAModel.Convert(source.At(sx, sy)).(color.NRGBA)
				if p.A < 48 || (int(p.G) > int(p.R)+5 && int(p.G) > int(p.B)+5 && p.G > 70) {
					continue
				}
				// Composite the transparent master over charcoal before encoding
				// to JPEG-compatible RGB for the model reference input.
				a := uint16(p.A)
				blend := color.RGBA{
					R: uint8((uint16(p.R)*a + uint16(background.R)*(255-a)) / 255),
					G: uint8((uint16(p.G)*a + uint16(background.G)*(255-a)) / 255),
					B: uint8((uint16(p.B)*a + uint16(background.B)*(255-a)) / 255), A: 255,
				}
				board.SetRGBA(positions[i].X+x, positions[i].Y+y, blend)
			}
		}
	}

	out, err := os.Create(os.Args[2])
	check(err)
	defer out.Close()
	check(png.Encode(out, board))
	fmt.Printf("reference=%s size=512x512 swatches=%d\n", os.Args[2], len(regions))
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}
