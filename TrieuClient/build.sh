#!/bin/bash
# Build TrieuClient.dylib không cần Theos - dùng cho Xcode / clang trên macOS
# Yêu cầu: Xcode Command Line Tools
# Chạy: chmod +x build.sh && ./build.sh

set -e

NAME="TrieuClient"
SRC="TrieuClient.mm"
OUT="${NAME}.dylib"
SDK=$(xcrun --sdk iphoneos --show-sdk-path 2>/dev/null || echo "")

if [ -z "$SDK" ]; then
  echo "⚠️  Không tìm thấy iOS SDK (chạy trên macOS có Xcode mới build được)"
  echo "👉 Đang tạo file mô phỏng để test / hướng dẫn..."
  # Tạo dummy dylib bằng gcc trên Linux (để có file)
  if command -v gcc >/dev/null 2>&1; then
    echo "int dummy=0;" | gcc -shared -o "${OUT}" -x c - 2>/dev/null || true
    echo "✅ Đã tạo ${OUT} (dummy - cần build lại trên macOS để dùng thật)"
  fi
  exit 0
fi

echo "🔨 Building ${OUT} với SDK: $SDK"

xcrun -sdk iphoneos clang -arch arm64 -arch arm64e \
  -mios-version-min=13.0 \
  -isysroot "$SDK" \
  -dynamiclib \
  -fobjc-arc \
  -framework UIKit \
  -framework Foundation \
  -framework QuartzCore \
  -o "$OUT" "$SRC" \
  -Wl,-install_name,@rpath/${OUT}.dylib

# Ký ad-hoc
codesign -fs - "$OUT" 2>/dev/null || true

echo "✅ Build xong: $(pwd)/${OUT}"
ls -lh "$OUT"
file "$OUT" || true

echo ""
echo "📦 Cách inject:"
echo "  1. Copy ${OUT} vào app: App.app/Frameworks/ hoặc /Library/MobileSubstrate/DynamicLibraries/"
echo "  2. Nếu là IPA: dùng insert_dylib hoặc Azule: insert_dylib --inplace --all-yes @executable_path/Frameworks/${OUT} App.app/AppBinary"
echo "  3. Resign & cài lại"
