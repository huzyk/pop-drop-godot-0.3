# Android: Godot editor closes after a short time

## What was changed in build 0.22

The former startup path decoded every one of 75 cosmetic SVG assets at 512x512 pixels and preloaded six large board textures plus six fullscreen overlays, regardless of which skin was active. The mobile editor is itself heavyweight; this is an unnecessary memory multiplier.

Version 0.22 loads cosmetic textures on demand (LRU limited to 18 at a time), chooses exactly one world frame + board texture, exports sprites at 256x256 instead of 512x512, caps runtime to 60 FPS on Android, uses half-size PCM music synthesis and does not poll the energy wallet every frame.

**This addresses an identified risk, not a proven root-cause diagnosis.** Android may still close Godot due to a GPU driver issue, the editor's own memory footprint, a fault in the project or an unrelated Android process limit.

## Step 1: Make sure the editor is importing the newest project

Inside Termux, from the directory you cloned:

```bash
cd ~/pop-drop-godot-0.3
git switch main
git pull --ff-only origin main
git rev-parse --short HEAD
```

Close Godot completely, reopen it, and import or open `project.godot` from this directory. In-game settings should display **0.22.0-mobile-art-beta**. Updating Git files does not automatically install a new APK.

## Step 2: Separate editor crashes from game crashes

The Android Godot **editor** (scene tree, 3D viewport, importer) uses more resources than the exported game. Test the APK independently:

1. Open the most recent successful **Build Android beta APK** workflow in GitHub Actions.
2. Under Artifacts, download `pop-drop-android-arm64-beta-debug`, extract its ZIP and install `pop-drop-debug.apk`.
3. Run without opening the Godot editor. Repeatedly open the shop, switch owned skins and play for several minutes.

If the APK runs but the editor is killed, the issue is specific to the editor/importing workflow. If the APK also closes, an Android crash report is required.

## Step 3: Collect the real Android crash report

On a PC with ADB attached, after the crash:

```bash
adb logcat -d -v time | grep -iE 'godot|FATAL EXCEPTION|Fatal signal|OutOfMemory|lowmemorykiller|lmkd|EGL|Vulkan' > godot-crash.log
```

On-device Termux can use `pkg install android-tools` and **Android Settings > Developer options > Wireless debugging** (pair/connect locally) to run ADB without a computer. Plain `logcat` from Termux usually lacks access to other apps' system logs; a permission error is expected without ADB.

Useful details: whether the **Godot editor** or the **exported game** closed; Android version; phone memory; actions in the last 15 seconds; whether system reports "App keeps stopping" or simply returns to home.

## Guardrails for subsequent work

- Never put all store skin textures into `preload(...)`.
- Keep cosmetic texture import size <=256px for 40–70px runtime sprites, unless a deliberately separate high-resolution asset is required.
- Keep the asset cache bounded, and load only one themed frame/board.
- Run `tests/test_mobile_skin_soak.gd` and screenshot capture after skin changes.
- Performance and Android stability should be tested on a physical device, not claimed solely from GitHub's Linux runner.
