# Custom Fingerprinting Script Guide

## 🎯 Overview

`AttributionLinker` hỗ trợ hai cách để thu thập fingerprint:

1. **Default Script**: Sử dụng `fingerprint.js` có sẵn trong assets
2. **Custom Script**: Cung cấp JavaScript script tùy chỉnh qua hàm `init()`

## 🔧 Cách sử dụng

### 1. Sử dụng Default Script

```dart
final linker = AttributionLinker();
linker.init(); // Sử dụng fingerprint.js mặc định

final fingerprint = await linker.fingerprint;
```

### 2. Sử dụng Custom Script

```dart
final customScript = '''
async function parseFingerprintInfo() {
  // Your custom fingerprinting logic here
  
  const fingerprint = {
    custom_field: "custom_value",
    timestamp: new Date().toISOString(),
    // ... other fields
  };
  
  return fingerprint;
}

// Execute and return result
parseFingerprintInfo().then(result => {
  window.flutter_inappwebview.callHandler('fingerprintResult', JSON.stringify(result));
}).catch(error => {
  window.flutter_inappwebview.callHandler('fingerprintError', error.toString());
});
''';

final linker = AttributionLinker();
linker.init(customScript: customScript);

final fingerprint = await linker.fingerprint;
```

## 📝 Yêu cầu cho Custom Script

### ✅ Bắt buộc

1. **Function**: Phải có function `parseFingerprintInfo()` 
2. **Return**: Function phải return object chứa fingerprint data
3. **Handler**: Phải gọi `window.flutter_inappwebview.callHandler('fingerprintResult', ...)`
4. **Error handling**: Phải handle error và gọi `fingerprintError` handler

### 🎨 Template cơ bản

```javascript
async function parseFingerprintInfo() {
  try {
    // Your data collection logic
    const fingerprint = {
      // Your custom fields
      field1: "value1",
      field2: "value2",
      collected_at: new Date().toISOString()
    };
    
    return fingerprint;
  } catch (error) {
    throw new Error(`Collection failed: ${error.message}`);
  }
}

// Required execution pattern
parseFingerprintInfo().then(result => {
  window.flutter_inappwebview.callHandler('fingerprintResult', JSON.stringify(result));
}).catch(error => {
  window.flutter_inappwebview.callHandler('fingerprintError', error.toString());
});
```

## 🌟 Ví dụ Advanced Custom Script

```javascript
async function parseFingerprintInfo() {
  // Có thể sử dụng UAParser (đã được load sẵn)
  const parser = new UAParser(navigator.userAgent);
  const parsed = parser.getResult();
  
  // Thu thập dữ liệu tùy chỉnh
  const customData = {
    // Basic info từ UAParser
    browser: parsed.browser.name,
    os: parsed.os.name,
    
    // Custom fields
    app_version: "1.0.0",
    session_id: generateSessionId(),
    user_preferences: getUserPreferences(),
    
    // Advanced fingerprinting
    canvas_hash: getCanvasFingerprint(),
    webgl_info: getWebGLInfo(),
    
    // Network info
    connection_type: getConnectionType(),
    
    // Timestamp
    collected_at: new Date().toISOString()
  };
  
  return customData;
}

function generateSessionId() {
  return Date.now().toString(36) + Math.random().toString(36).substr(2);
}

function getUserPreferences() {
  return {
    dark_mode: window.matchMedia('(prefers-color-scheme: dark)').matches,
    reduced_motion: window.matchMedia('(prefers-reduced-motion: reduce)').matches
  };
}

function getCanvasFingerprint() {
  try {
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    ctx.textBaseline = 'top';
    ctx.font = '14px Arial';
    ctx.fillText('Custom fingerprint', 2, 2);
    return canvas.toDataURL().slice(-50); // Last 50 chars
  } catch (e) {
    return '';
  }
}

function getWebGLInfo() {
  try {
    const canvas = document.createElement('canvas');
    const gl = canvas.getContext('webgl');
    return {
      vendor: gl.getParameter(gl.VENDOR),
      renderer: gl.getParameter(gl.RENDERER)
    };
  } catch (e) {
    return {};
  }
}

function getConnectionType() {
  const conn = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
  return conn ? conn.effectiveType : 'unknown';
}

// Execute
parseFingerprintInfo().then(result => {
  window.flutter_inappwebview.callHandler('fingerprintResult', JSON.stringify(result));
}).catch(error => {
  window.flutter_inappwebview.callHandler('fingerprintError', error.toString());
});
```

## 🔍 Available Libraries

Trong custom script, bạn có thể sử dụng:

- **UAParser**: `new UAParser(userAgent)` - Parse user agent
- **Standard Web APIs**: Navigator, Screen, WebGL, Canvas, etc.
- **ES6+ Features**: async/await, destructuring, template literals

## 🚨 Lưu ý quan trọng

1. **Security**: Không thu thập thông tin nhạy cảm
2. **Performance**: Tránh operations tốn thời gian
3. **Cross-platform**: Test trên nhiều platform
4. **Error handling**: Luôn handle exceptions
5. **Privacy**: Tuân thủ quy định về privacy
