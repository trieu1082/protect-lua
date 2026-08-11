# Trieu Client - Dylib UI Đẹp Bo Góc

Dylib khi inject vào app sẽ hiện **frame UI đẹp bo góc** với:

- Header gradient tím -> hồng -> cam
- Icon 👑 bo tròn + blur glassmorphism
- Text `CLIENT MADE BY TRIỆU`
- Card bo góc `24pt` + shadow + animation spring
- Box trạng thái "Đã inject thành công"
- **Nút ĐÓNG** gradient bo góc 14pt dưới cùng
- Khi bấm Đóng: frame đóng với animation scale + hiện notify toast **"Chúc bạn chs vui vẻ 🎮✨"**

## 📁 Files

- `TrieuClient.mm` - source chính (Objective-C++ ARC, UIKit)
- `Makefile` - build bằng Theos
- `TrieuClient.plist` - filter bundle
- `build.sh` - build trực tiếp bằng clang (không cần Theos)

## 🔨 Cách Build

### Cách 1: Theos (khuyên dùng cho jailbreak)

```bash
export THEOS=~/theos
make package
# file .deb sẽ có dylib trong /Library/MobileSubstrate/DynamicLibraries/
```

Đổi `com.example.app` trong `TrieuClient.plist` thành bundle ID app bạn muốn inject.

Hoặc để hiện trên mọi app:
```plist
{ Filter = { Bundles = ( "com.apple.UIKit" ); }; }
```

### Cách 2: Xcode clang (cho IPA sideload)

Trên **macOS** có Xcode:

```bash
chmod +x build.sh
./build.sh
# ra file TrieuClient.dylib
```

Inject vào IPA:

```bash
# 1. Giải nén IPA
unzip App.ipa

# 2. Copy dylib
cp TrieuClient.dylib Payload/App.app/Frameworks/

# 3. Chèn load command
insert_dylib --inplace --all-yes @executable_path/Frameworks/TrieuClient.dylib Payload/App.app/AppBinary

# 4. Resign
codesign -fs - --deep Payload/App.app/Frameworks/TrieuClient.dylib
codesign -fs - Payload/App.app

# 5. Đóng gói lại
zip -r App-patched.ipa Payload
```

Hoặc dùng **Azule**, **Sideloadly**, **E-Sign**.

## 🎨 Preview UI

```
┌─────────────────────────────┐  <- dim + blur dark 0.45
│      ┌───────────────┐      │
│      │  ╭─────────╮  │      │  Header gradient
│      │  │  👑 72°  │  │      │  bo góc 24
│      │  ╰─────────╯  │      │
│      │ ✨ CLIENT MADE BY ✨ │ │
│      ├───────────────┤      │
│      │     TRIỆU     │      │  Title 34 Heavy
│      │ Premium Client v1.0  │
│      │ ─────────────── │    │  divider
│      │ 🟢 Đã inject thành công│ │ box 14 bo góc
│      │ Sẵn sàng...   │      │
│      │ ┌───────────┐ │      │  Nút ĐÓNG gradient
│      │ │  ĐÓNG  ✕  │ │      │  48h bo góc 14
│      └───────────────┘      │
└─────────────────────────────┘
Toast: "Chúc bạn chs vui vẻ 🎮✨" (đen 85% bo góc 14)
```

## ⚙️ Tùy chỉnh

- Đổi text notify trong `TrieuClient.mm` hàm `closeTrieuUI()` -> `showToast(@"...")`
- Đổi màu gradient header: `headerGradient.colors`
- Đổi màu nút: `btnGrad.colors`
- Đổi delay hiện UI: `trieu_constructor()` dispatch_after 0.8s
- Thêm auto hiện lại khi foreground: uncomment trong `UIApplicationDidBecomeActiveNotification`

## 📞 Gọi thủ công

Từ tweak khác có thể gọi:

```objc
extern void showTrieuClient(void);
showTrieuClient();
```

## ✅ Yêu cầu

- iOS 13.0+
- ARC enabled
- Frameworks: UIKit, Foundation, QuartzCore
