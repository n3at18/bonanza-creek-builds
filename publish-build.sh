#!/usr/bin/env bash
# Publish a new set of builds to https://bonanzacreek.lifewheel.us/
#   ./publish-build.sh <version> ["what changed"] [folder with the four zips]
# Takes gold-fever's build/itch/gold-fever-{windows,macos,linux,web}.zip (made by tools/export_itch.sh), uploads them
# as release v<version> named bonanza-creek-*.zip, and the release starts the page deploy (about a minute).
# A missing zip is skipped; the page shows that platform as "Coming soon".
set -euo pipefail
ver=${1:?usage: ./publish-build.sh <version> ["what changed"] [zip folder]}
notes=${2:-}
src=${3:-$HOME/source/steam/gold-fever/build/itch}
repo=n3at18/bonanza-creek-builds
export GH_TOKEN=${GH_TOKEN:-$(gh auth token --user n3at18)}

tmp=$(mktemp -d)
trap 'rm -rf "${tmp:?}"' EXIT
for p in windows macos linux web; do
	if [ -f "$src/gold-fever-$p.zip" ]; then cp "$src/gold-fever-$p.zip" "$tmp/bonanza-creek-$p.zip"
	elif [ -f "$src/bonanza-creek-$p.zip" ]; then cp "$src/bonanza-creek-$p.zip" "$tmp/"
	else echo "skip $p: no zip in $src"; fi
done
ls "$tmp"/*.zip >/dev/null 2>&1 || { echo "no zips found in $src" >&2; exit 1; }

if gh release view "v$ver" -R "$repo" >/dev/null 2>&1; then
	# Same version again: replace its files, then re-save the release so the page redeploys
	gh release upload "v$ver" "$tmp"/*.zip -R "$repo" --clobber
	gh release edit "v$ver" -R "$repo" --notes "$notes" --latest
else
	gh release create "v$ver" "$tmp"/*.zip -R "$repo" --title "Bonanza Creek $ver" --notes "$notes" --latest
fi
echo "Published v$ver. The page updates in about a minute: https://bonanzacreek.lifewheel.us/"
