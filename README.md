# Bonanza Creek builds

The page publishers get from the pitch deck: **https://bonanzacreek.lifewheel.us/**

It always shows the latest release: Windows, macOS and Linux downloads, a small "quick look in the browser" link (the web build,
unpacked into `play/`), the version, the date and the gameplay video.

## Put up a new build

From a terminal, after `tools/export_itch.sh` in `gold-fever`:

```sh
./publish-build.sh 0.5.2 "Deeper ground, new sluice tier"
```

Or on github.com: **Releases → Draft a new release**. Give it a tag like `v0.5.2`, write the notes, attach the zips
named exactly `bonanza-creek-windows.zip`, `bonanza-creek-macos.zip`, `bonanza-creek-linux.zip` and
`bonanza-creek-web.zip`, and click **Publish**.

The page is hosted on Firebase (project `bonanza-creek-play`; `bonanzacreek.lifewheel.us` is a CNAME to `bonanza-creek-play.web.app` in the lifewheel.us DNS at Turbify). `publish-build.sh` redeploys it at the end; after a release made on github.com, run `firebase/deploy.sh`. The old GitHub Pages copy at n3at18.github.io/bonanza-creek-builds still deploys from Actions but is no longer linked anywhere. Older releases stay listed under
Releases, but the page only links the latest one. To pull a bad build, delete that release; the page then falls back
to the one before it after the next deploy (Actions → Deploy → Run workflow).

## Files

| Path | What |
|---|---|
| `site/index.html` | The page (one file, no build step) |
| `site/media/` | Key art (`key_camp.jpg`) and the gameplay video (`pitch.mp4` + `pitch_poster.jpg`) |
| `.github/workflows/deploy.yml` | Assembles `site/` + the latest release into the Pages site and writes `builds.json` |
| `publish-build.sh` | Uploads the four zips from `gold-fever/build/itch/` as a release |

Images and the video are real captures of the game (see `gold-fever/docs/marketing/pitch-deck/assets/SHOTS.md`).
Video music: Kevin MacLeod (incompetech.com), CC BY 4.0.

## Deck page

`site/deck/` is the pitch deck as one scrolling page, for friends to critique: https://bonanzacreek.lifewheel.us/deck/ . Regenerate it with `python3 export_web.py ~/source/steam/bonanza-creek-builds/site/deck` in `gold-fever/docs/marketing/pitch-deck/deck/`, then push.
