# Android APK Project for 2004scape

## Current Architecture Analysis
- **Renderer**: Canvas-based (789x532 fixed dimensions)
- **Communication**: WebSocket for client-server
- **Mobile Support**: Existing detection and mobile template (client-mobile.ejs)
- **Client**: JavaScript with touch event handling already implemented

## APK Wrapper Benefits
1. **Full Screen Control**: No browser UI, complete immersion
2. **Native Features**: Device orientation, haptic feedback, hardware back button
3. **Persistent Storage**: Local credential/settings storage
4. **Performance**: Hardware acceleration, reduced browser overhead
5. **Distribution**: Google Play Store availability

## Technical Implementation Options

### 1. Android WebView (Simplest)
- Native Android app with WebView component
- Direct control over WebView settings
- Minimal overhead

### 2. Capacitor/Cordova (Recommended)
- Cross-platform (iOS possible later)
- Rich plugin ecosystem
- Native API access
- Easy WebSocket handling

### 3. React Native WebView
- More UI control
- Heavier framework
- Better for custom native UI elements

## Key Implementation Tasks
1. **Dynamic Canvas Scaling**: Handle different screen sizes/ratios
2. **Enhanced Touch Controls**: Optimize for mobile gameplay
3. **Network Resilience**: Handle connection drops/reconnects
4. **Android Lifecycle**: Proper pause/resume handling
5. **Local Storage**: Settings, credentials, cache

## Existing Mobile Code Assets
- `/view/client-mobile.ejs` - Mobile-optimized template
- `/view/client.ejs` - Main game client
- `/public/client/client.js` - Game client logic
- Mobile detection already in `/src/web.ts`

## Next Steps
1. Set up Android development environment
2. Create WebView wrapper prototype
3. Implement canvas scaling algorithm
4. Add network state management
5. Test on various Android devices