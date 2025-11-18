# How to Update FARM Hub App Icon

## Quick Method (Using HTML Generator)

1. **Open the Icon Generator**:
   - Open `create_icon.html` in your web browser
   - The icon will be automatically generated

2. **Download the Icon**:
   - Click "Download Icon (PNG)" button
   - Save it as `app_icon.png` in the `assets/icons/` folder
   - Replace the existing file if prompted

3. **Generate All Icon Sizes**:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

4. **Rebuild the App**:
   ```bash
   flutter clean
   flutter build apk --release
   ```

## Alternative Method (Using Online Tools)

### Option 1: Canva (Recommended)
1. Go to [canva.com](https://www.canva.com)
2. Create a custom design: 1024x1024 pixels
3. Set background color to #2E7D32
4. Add a white tractor icon or symbol
5. Download as PNG
6. Save to `assets/icons/app_icon.png`

### Option 2: Figma
1. Go to [figma.com](https://www.figma.com)
2. Create a new frame: 1024x1024
3. Fill with #2E7D32
4. Design a clean tractor icon in white
5. Export as PNG at 1x resolution
6. Save to `assets/icons/app_icon.png`

### Option 3: IconKitchen (Google)
1. Go to [icon.kitchen](https://icon.kitchen)
2. Upload your 1024x1024 icon
3. Generate adaptive icon
4. Download and use the foreground image

## Design Tips for Professional Icon

1. **Keep it Simple**: 
   - Use minimal details
   - Ensure it's recognizable at small sizes

2. **High Contrast**:
   - White foreground on green background
   - No gradients that cause pixelation

3. **Sharp Edges**:
   - Use vector-style graphics
   - Avoid soft edges or blur

4. **Safe Zone**:
   - Keep important elements within 80% of icon
   - This prevents clipping on Android adaptive icons

5. **Resolution**:
   - Always use 1024x1024 or higher
   - Never upscale a smaller image

## After Updating Icon

1. **Verify the Icon**:
   - Check that `assets/icons/app_icon.png` is 1024x1024
   - Ensure it has crisp, sharp edges
   - Verify colors are correct (#2E7D32 background, white foreground)

2. **Regenerate Icons**:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

3. **Test on Device**:
   - Build and install the APK
   - Check that the icon appears crisp and professional
   - Verify it's not pixelated

## Troubleshooting

### Icon Still Looks Pixelated
- Ensure source icon is 1024x1024 minimum
- Check that you're using PNG format (not JPEG)
- Verify icon has sharp edges (not blurred)
- Make sure you ran `flutter pub run flutter_launcher_icons` after updating

### Icon Not Updating
- Run `flutter clean`
- Delete `build/` folder
- Run `flutter pub get`
- Run `flutter pub run flutter_launcher_icons`
- Rebuild the app

### Icon Clipped on Android
- Ensure important elements are within 80% safe zone
- Check `adaptive_icon_foreground_padding` in `pubspec.yaml`
- Increase padding if needed

## Current Configuration

The icon is configured in `pubspec.yaml`:
- Background: #2E7D32 (Forest Green)
- Foreground: assets/icons/app_icon.png
- Padding: 4 pixels (safe zone)
- All Android icon sizes are generated automatically

