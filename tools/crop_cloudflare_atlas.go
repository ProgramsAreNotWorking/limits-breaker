package main

import (
	"flag"
	"fmt"
	"image"
	"image/png"
	"os"
	"path/filepath"
	"strings"
)

// Crops a keyed, row-major Cloudflare atlas into individual runtime PNGs.
func main() {
	input := flag.String("input", "", "keyed atlas PNG")
	outputDir := flag.String("output-dir", "", "destination directory")
	idsValue := flag.String("ids", "", "comma-separated row-major filenames, using '-' for an empty cell")
	columns := flag.Int("columns", 4, "number of cells per row")
	cellWidth := flag.Int("cell-width", 256, "cell width")
	cellHeight := flag.Int("cell-height", 256, "cell height")
	flag.Parse()
	if *input == "" || *outputDir == "" || *idsValue == "" || *columns < 1 || *cellWidth < 1 || *cellHeight < 1 {
		panic("usage: go run tools/crop_cloudflare_atlas.go --input atlas.png --output-dir assets/art/icons/items --ids rusted_blade,ashen_edge,...")
	}

	f, err := os.Open(*input)
	check(err)
	defer f.Close()
	source, err := png.Decode(f)
	check(err)
	ids := strings.Split(*idsValue, ",")
	if len(ids)%(*columns) != 0 {
		panic("cell id count must fill complete rows")
	}
	rows := len(ids) / *columns
	bounds := source.Bounds()
	if bounds.Dx() != (*columns)*(*cellWidth) || bounds.Dy() != rows*(*cellHeight) {
		panic(fmt.Sprintf("atlas dimensions are %dx%d; requested grid requires exactly %dx%d", bounds.Dx(), bounds.Dy(), (*columns)*(*cellWidth), rows*(*cellHeight)))
	}
	check(os.MkdirAll(*outputDir, 0755))
	written := 0
	for index, rawID := range ids {
		id := strings.TrimSpace(rawID)
		if id == "" || id == "-" {
			continue
		}
		if filepath.Base(id) != id || filepath.Ext(id) != "" {
			panic("cell ids must be plain filenames without directories or extensions")
		}
		column, row := index%(*columns), index/(*columns)
		crop := image.Rect(bounds.Min.X+column*(*cellWidth), bounds.Min.Y+row*(*cellHeight), bounds.Min.X+(column+1)*(*cellWidth), bounds.Min.Y+(row+1)*(*cellHeight))
		cell := image.NewNRGBA(image.Rect(0, 0, *cellWidth, *cellHeight))
		for y := 0; y < *cellHeight; y++ {
			for x := 0; x < *cellWidth; x++ {
				cell.Set(x, y, source.At(crop.Min.X+x, crop.Min.Y+y))
			}
		}
		path := filepath.Join(*outputDir, id+".png")
		out, err := os.Create(path)
		check(err)
		check(png.Encode(out, cell))
		check(out.Close())
		written++
	}
	fmt.Printf("{\"output_dir\":%q,\"cells\":%d,\"written\":%d,\"cell\":[%d,%d]}\n", *outputDir, len(ids), written, *cellWidth, *cellHeight)
}

func check(err error) {
	if err != nil {
		panic(err)
	}
}
