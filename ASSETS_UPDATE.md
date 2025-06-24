# Assets Update Guide

## Tự động cập nhật Assets từ Remote URLs

Project này có một test đặc biệt để tự động tải và cập nhật các assets từ các URL remote. Điều này giúp đảm bảo các thư viện JavaScript luôn được cập nhật từ nguồn gốc.

### 🎯 Mục đích

- Tự động tải các assets mới nhất từ internet
- Tạo backup cho các files cũ
- Verify tính hợp lệ của files sau khi tải
- Dễ dàng thêm/bớt assets cần cập nhật

### 📋 Assets hiện tại được quản lý

| File | Type | Source | Description |
|------|------|--------|-------------|
| `ua-parser.min.js` | Remote | [ua-parser-js/master](https://raw.githubusercontent.com/faisalman/ua-parser-js/refs/heads/master/dist/ua-parser.min.js) | User Agent Parser Library |
| `fingerprint.js` | Local | Project assets | Device fingerprinting script |

**Remote assets**: Được tự động tải từ internet khi chạy test  
**Local assets**: Được quản lý trong project, có thể override bằng custom script

### 🚀 Cách sử dụng

#### 1. Cập nhật tất cả assets:
```bash
flutter test test/attribution_linker_test.dart --name "download and update assets"
```

#### 2. Verify assets tồn tại:
```bash
flutter test test/attribution_linker_test.dart --name "verify assets exist"
```

#### 3. Chạy tất cả tests:
```bash
flutter test
```

### ➕ Thêm assets mới

Để thêm assets mới cần được quản lý, chỉnh sửa file `test/attribution_linker_test.dart`:

```dart
final assetsToUpdate = <String, String>{
  'ua-parser.min.js': 'https://raw.githubusercontent.com/faisalman/ua-parser-js/refs/heads/master/dist/ua-parser.min.js',
  
  // Thêm assets mới ở đây
  'new-library.min.js': 'https://example.com/path/to/new-library.min.js',
  'another-asset.css': 'https://cdn.example.com/another-asset.css',
};
```

### 📁 Cấu trúc sau khi chạy

```
assets/
├── ua-parser.min.js           # File chính
├── ua-parser.min.js.backup    # Backup của file cũ (nếu có)
└── [other-assets...]
```

### 🔒 An toàn

- **Backup tự động**: Files cũ được backup trước khi ghi đè
- **Verification**: Content được verify sau khi download
- **Error handling**: Test sẽ fail nếu download không thành công
- **Timeout protection**: Test có timeout 5 phút để tránh hang

### 📊 Output mẫu

```
🔄 Updating ua-parser.min.js...
📥 Downloading from: https://raw.githubusercontent.com/faisalman/ua-parser-js/refs/heads/master/dist/ua-parser.min.js
💾 Created backup: ua-parser.min.js.backup
✅ Successfully updated: ua-parser.min.js
📊 File size: 84.2 KB
📄 Content preview: !function(r,d){"use strict";function i(i){for(var e={},o=0;o<i.length;o++)e[i[o].toUpperCase()]...

🎉 All assets updated successfully!
```

### 🚨 Lưu ý

- **Internet connection**: Cần kết nối internet để download
- **File permissions**: Đảm bảo có quyền ghi vào thư mục assets
- **Large files**: Test có timeout 5 phút, tăng nếu cần thiết
- **Version control**: Kiểm tra thay đổi trước khi commit
