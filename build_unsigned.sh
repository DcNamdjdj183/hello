#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$ROOT/build"
ARCHIVE="$BUILD_DIR/3105.xcarchive"
IPA="$BUILD_DIR/3105-unsigned.ipa"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
command -v xcodebuild >/dev/null || { echo 'xcodebuild is required on macOS' >&2; exit 127; }

echo "Starting xcodebuild archive..."
if ! xcodebuild \
  -project "$ROOT/ThreeOneOSFive.xcodeproj" \
  -scheme 3105 \
  -configuration Release \
  -sdk iphoneos \
  -archivePath "$ARCHIVE" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY='' \
  archive 2>&1 | tee "$BUILD_DIR/xcodebuild.log"; then

  echo "::error title=Xcodebuild Failure::Archive step failed"

  # Export error lines as GitHub annotations
  grep -E "(error:|fatal error:)" "$BUILD_DIR/xcodebuild.log" | head -n 30 | while IFS= read -r err_line; do
    echo "::error::$err_line"
  done

  # Also write to GitHub Step Summary if available
  if [ -n "${GITHUB_STEP_SUMMARY:-}" ]; then
    echo "## ❌ Xcodebuild Archive Failed" >> "$GITHUB_STEP_SUMMARY"
    echo '```text' >> "$GITHUB_STEP_SUMMARY"
    grep -E -C 2 "(error:|fatal error:|\*\* ARCHIVE FAILED \*\*)" "$BUILD_DIR/xcodebuild.log" | head -n 120 >> "$GITHUB_STEP_SUMMARY" || tail -n 80 "$BUILD_DIR/xcodebuild.log" >> "$GITHUB_STEP_SUMMARY"
    echo '```' >> "$GITHUB_STEP_SUMMARY"
  fi

  echo "-------------------- XCODEBUILD ERRORS --------------------"
  grep -E -C 3 "(error:|fatal error:|\*\* ARCHIVE FAILED \*\*)" "$BUILD_DIR/xcodebuild.log" | head -n 100 || true
  echo "-------------------- LAST 100 LINES --------------------"
  tail -n 100 "$BUILD_DIR/xcodebuild.log"
  echo "--------------------------------------------------------"
  exit 65
fi

APP="$ARCHIVE/Products/Applications/3105.app"
test -d "$APP"

# Copy dns folder directly to app bundle if present
if [ -d "$ROOT/ThreeOneOSFive/dns" ]; then
  mkdir -p "$APP/dns"
  cp -R "$ROOT/ThreeOneOSFive/dns/"* "$APP/dns/" 2>/dev/null || true
fi

# Copy Patches folder directly to app bundle if present
if [ -d "$ROOT/ThreeOneOSFive/Patches" ]; then
  mkdir -p "$APP/Patches"
  cp -R "$ROOT/ThreeOneOSFive/Patches/"* "$APP/Patches/" 2>/dev/null || true
fi

/usr/libexec/PlistBuddy -c "Set :CFBundleExecutable 3105" "$APP/Info.plist" || true
/usr/libexec/PlistBuddy -c "Set :CFBundlePackageType APPL" "$APP/Info.plist" || true
mkdir -p "$BUILD_DIR/Payload"
cp -R "$APP" "$BUILD_DIR/Payload/"
(
  cd "$BUILD_DIR"
  /usr/bin/zip -qry "$IPA" Payload
  rm -rf Payload
)
echo "$IPA"
