# How to Generate Your App Icon

## Quick Steps

1. **Open the Icon Generator:**
   - Open `create_icon.html` in your web browser
   - The icon will be automatically generated

2. **Download the Icon:**
   - Click "Download Icon (PNG)" button
   - Save it as `app_icon.png` in the `assets/icons/` folder
   - Replace the existing file if prompted

3. **Generate All Icon Sizes:**
   ```bash
   flutter pub run flutter_launcher_icons
   ```

4. **Build Your APK:**
   ```bash
   flutter clean
   flutter build apk --release
   ```

## Icon Design

The generator creates a minimalist white tractor silhouette with:
- **Tractor Body:** Blocky, modern design
- **Wheels:** Large rear wheel with detailed tread patterns, smaller front wheel
- **Steering Wheel:** Circular handlebar visible above the body
- **Seat:** Visible above the rear wheel
- **Background:** Forest green (#2E7D32) with optional gradient effect

## Current Configuration

- **Source:** `assets/icons/app_icon.png`
- **Background Color:** #2E7D32 (Forest Green)
- **Foreground:** White tractor silhouette
- **Adaptive Icon:** Enabled with 4px padding
- **All Sizes:** Automatically generated for Android

## Notes

- The icon generator creates a 1024x1024 pixel icon
- All Android icon sizes are generated automatically
- The icon will appear crisp on all devices
- Adaptive icon background matches system primary color

