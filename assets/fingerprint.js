/**
 * Device Fingerprinting Script
 * Collects comprehensive device information for attribution linking
 */

async function parseFingerprintInfo() {
  const ua = navigator.userAgent || '';
  const uaData = navigator.userAgentData;

  // 🧠 Ưu tiên entropy cao nếu có hỗ trợ
  const highEntropy = uaData?.getHighEntropyValues
    ? await uaData.getHighEntropyValues([
        "platform", "platformVersion", "architecture", "model", "uaFullVersion", "bitness", "fullVersionList"
      ])
    : null;

  // 📦 Dùng UAParser.js
  const parser = new UAParser(ua);
  const parsed = parser.getResult();

  // 📱 Phân loại hệ điều hành
  function detectOS() {
    const p = (highEntropy?.platform || parsed.os.name || '').toLowerCase();
    if (p.includes('android')) return 'android';
    if (p.includes('ios')) return 'ios';
    if (p.includes('ipad')) return 'ipados';
    if (p.includes('mac')) return 'macos';
    if (p.includes('win')) return 'windows';
    if (p.includes('linux')) return 'linux';
    return 'others';
  }

  const osType = detectOS();

  // 🌙 Phát hiện hệ thống sáng/tối
  const prefersDark = window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches;
  const systemBrightness = prefersDark ? 'dark' : 'light';

  // 🔍 Thu thập thêm thông tin nâng cao
  function getCanvasFingerprint() {
    try {
      const canvas = document.createElement('canvas');
      const ctx = canvas.getContext('2d');
      if (!ctx) return '';
      
      ctx.textBaseline = 'top';
      ctx.font = '14px Arial';
      ctx.fillText('Device fingerprint test 🔍', 2, 2);
      return canvas.toDataURL();
    } catch (e) {
      return '';
    }
  }

  function getWebGLFingerprint() {
    try {
      const canvas = document.createElement('canvas');
      const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
      if (!gl) return {};
      
      return {
        vendor: gl.getParameter(gl.VENDOR) || '',
        renderer: gl.getParameter(gl.RENDERER) || '',
        version: gl.getParameter(gl.VERSION) || '',
        shading_language: gl.getParameter(gl.SHADING_LANGUAGE_VERSION) || ''
      };
    } catch (e) {
      return {};
    }
  }

  function getConnectionInfo() {
    const conn = navigator.connection || navigator.mozConnection || navigator.webkitConnection;
    if (!conn) return {};
    
    return {
      effective_type: conn.effectiveType || '',
      downlink: conn.downlink || '',
      rtt: conn.rtt || ''
    };
  }

  // ✅ Trải phẳng dữ liệu fingerprint
  const fingerprint = {
    // Basic device info
    os_type: osType,
    os_name: highEntropy?.platform || parsed.os.name || '',
    os_version: highEntropy?.platformVersion || parsed.os.version || '',
    browser_name: parsed.browser.name || '',
    browser_version: highEntropy?.uaFullVersion || parsed.browser.version || '',
    device_model: highEntropy?.model || parsed.device.model || '',
    device_type: parsed.device.type || '',
    device_arch: highEntropy?.architecture || '',
    device_bitness: highEntropy?.bitness || '',
    
    // Screen and display
    screen_res: `${screen.width}x${screen.height}`,
    screen_available: `${screen.availWidth}x${screen.availHeight}`,
    screen_color_depth: screen.colorDepth || '',
    pixel_ratio: window.devicePixelRatio || 1,
    system_brightness: systemBrightness,
    
    // Locale and timezone
    timezone: Intl.DateTimeFormat().resolvedOptions().timeZone || '',
    language: navigator.language || '',
    languages: navigator.languages?.join(', ') || '',
    
    // Hardware capabilities
    cpu_cores: navigator.hardwareConcurrency?.toString() || '',
    device_memory: navigator.deviceMemory?.toString() || '',
    
    // Network
    connection_info: getConnectionInfo(),
    
    // Advanced fingerprinting
    canvas_fingerprint: getCanvasFingerprint(),
    webgl_info: getWebGLFingerprint(),
    
    // Touch support
    touch_support: 'ontouchstart' in window || navigator.maxTouchPoints > 0,
    max_touch_points: navigator.maxTouchPoints || 0,
    
    // Browser features
    cookies_enabled: navigator.cookieEnabled,
    do_not_track: navigator.doNotTrack || '',
    
    // Raw data
    user_agent: ua,
    user_agent_data: uaData || null,
    user_agent_parsed: parsed,
    browser_full_version_list: highEntropy?.fullVersionList?.map(b => `${b.brand}/${b.version}`).join(', ') || '',
    
    // Timestamp
    collected_at: new Date().toISOString()
  };

  return fingerprint;
}

// Execute and return result
parseFingerprintInfo().then(result => {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('fingerprintResult', JSON.stringify(result));
  } else {
    // Fallback for testing or debugging
    console.log('Fingerprint collected:', result);
  }
}).catch(error => {
  if (window.flutter_inappwebview) {
    window.flutter_inappwebview.callHandler('fingerprintError', error.toString());
  } else {
    console.error('Fingerprint collection error:', error);
  }
});
