# Assets

## Pixel character
The PixelBuddy character is **code-drawn**, not an image. It lives in
`lib/features/clock/presentation/widgets/pixel_buddy_painter.dart` as a
`CustomPainter` over a 32×32 grid. To restyle it, edit cell coordinates/colors
there — no image editing required, and it stays crisp at any size.

## Sounds
Place alarm/timer audio in `assets/sounds/`. The default reference is
`sounds/alarm.mp3` (`AlarmModel.soundAsset`). Add a royalty-free `alarm.mp3`
before release. Missing files degrade gracefully to vibration during dev.

## App icon
1. Create a 1024×1024 PNG master (e.g. `assets/icon/icon.png`).
2. Add dev dependency and config:

   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.14.1

   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icon/icon.png"
     min_sdk_android: 23
   ```

3. Generate:

   ```bash
   dart run flutter_launcher_icons
   ```

This overwrites the placeholder mipmap/AppIcon assets created by `flutter create`.
