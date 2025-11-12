# Assets Instructions

## Images Folder

Place your logo image here. Recommended formats:
- PNG (with transparent background preferred)
- JPG
- SVG (requires additional package)

**Recommended logo name:** `logo.png`

To use your logo, update line 131 in `lib/screens/onboarding/onboarding_screen.dart`:
```dart
// Uncomment and use:
Image.asset('assets/images/logo.png', width: 120, height: 120),

// And comment out the Icon widget
```

### Recommended Logo Specifications:
- Size: 500x500 pixels (or similar square ratio)
- Format: PNG with transparent background
- File size: Under 500KB for optimal performance

## Videos Folder

Place your background video here.

**Recommended video name:** `background.mp4`

### Recommended Video Specifications:
- Format: MP4 (H.264 codec)
- Resolution: 720p (1280x720) or 1080p (1920x1080)
- Duration: 10-30 seconds (will loop automatically)
- File size: Under 10MB for optimal app performance
- Orientation: Portrait or Square works best for mobile

### Tips:
1. Keep the video subtle so text remains readable
2. Avoid videos with too much motion or bright colors
3. The app applies a dark overlay (30% opacity) for better text visibility
4. If no video is found, the app will show a beautiful gradient background instead

### Free Video Resources:
- Pexels (pexels.com/videos)
- Pixabay (pixabay.com/videos)
- Videvo (videvo.net)

Look for keywords like: "cooking", "food preparation", "restaurant", "kitchen"
