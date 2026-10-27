#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

export GOCACHE="${TMPDIR:-/tmp}/limits-breaker-go-build-cache"
mkdir -p "$GOCACHE"

OFFICIAL_DIR="output/cloudflare/official"
STAGING_DIR="output/cloudflare/staging"
ITEMS_SOURCE="$OFFICIAL_DIR/items-atlas-flux2-dev-01.jpg"
EFFECTS_SOURCE="$OFFICIAL_DIR/effects-atlas-flux2-dev-01.jpg"

if [[ ! -f "$ITEMS_SOURCE" || ! -f "$EFFECTS_SOURCE" ]]; then
	printf 'Place both Cloudflare atlas JPEGs in %s before running this script.\n' "$OFFICIAL_DIR" >&2
	exit 2
fi

mkdir -p "$STAGING_DIR"

go run tools/key_cloudflare_art.go \
	--input "$ITEMS_SOURCE" \
	--output "$STAGING_DIR/items-atlas-keyed.png" \
	--key cyan
go run tools/crop_cloudflare_atlas.go \
	--input "$STAGING_DIR/items-atlas-keyed.png" \
	--output-dir "$STAGING_DIR/items" \
	--columns 4 --cell-width 128 --cell-height 128 \
	--ids 'rusted_blade,ashen_edge,arcane_staff,iron_cuirass,warden_plate,oak_shield,ember_charm,void_sigil,pilgrim_relic,healing_draught,greater_draught,-,-,-,-,-'

go run tools/key_cloudflare_art.go \
	--input "$EFFECTS_SOURCE" \
	--output "$STAGING_DIR/effects-atlas-keyed.png" \
	--key cyan
go run tools/crop_cloudflare_atlas.go \
	--input "$STAGING_DIR/effects-atlas-keyed.png" \
	--output-dir "$STAGING_DIR/effects" \
	--columns 4 --cell-width 256 --cell-height 256 \
	--ids 'slash,arcane,critical,impact,heal,defeat,correct,incorrect,forge_spark,particle,-,-,-,-,-,-'

printf 'Staged 11 item icons and 10 effects under %s; inspect them before copying into assets/art/.\n' "$STAGING_DIR"
