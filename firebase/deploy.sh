#!/usr/bin/env bash
# Rebuilds the Firebase site (https://bonanzacreek.lifewheel.us, also bonanza-creek-play.web.app) from site/ plus the
# latest GitHub release: builds.json for the download cards and the web build unpacked into play/. Run after a release.
set -euo pipefail
cd "$(dirname "$0")"
export GH_TOKEN=${GH_TOKEN:-$(gh auth token --user n3at18)}
R=n3at18/bonanza-creek-builds
tmp=$(mktemp -d); trap 'rm -rf "${tmp:?}"' EXIT
rm -rf "${PWD:?}/public"; mkdir public; cp -R ../site/. public/
gh release view -R $R --json tagName,publishedAt,body,assets > "$tmp/rel.json"
web=false
if gh release download -R $R --pattern 'bonanza-creek-web.zip' -D "$tmp/web" 2>/dev/null; then
	mkdir -p public/play && unzip -q "$tmp/web/bonanza-creek-web.zip" -d public/play && web=true
fi
python3 - "$tmp/rel.json" "$web" <<'PY'
import json, sys
r = json.load(open(sys.argv[1]))
json.dump({"version": r.get("tagName", "").lstrip("v"), "date": r.get("publishedAt", ""), "notes": r.get("body", ""),
           "assets": {a["name"]: {"url": a["url"], "size": a["size"]} for a in r.get("assets", [])},
           "web": sys.argv[2] == "true", "video": True}, open("public/builds.json", "w"), indent=1)
PY
firebase deploy --only hosting --project bonanza-creek-play
