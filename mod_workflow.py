import yaml
import re

with open('.github/workflows/build-unsigned-ipa.yml', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace the run block of 'Build unsigned archive'
old_run = """        - name: Build unsigned archive
        env:
          PROJECT: ${{ steps.locate.outputs.project }}
          WORKSPACE: ${{ steps.locate.outputs.workspace }}
          SCHEME: ${{ steps.locate.outputs.scheme }}
          BUNDLE_ID: ${{ inputs.bundle_id }}
        run: |
          set -euo pipefail
          ARCHIVE="$RUNNER_TEMP/App.xcarchive"
          if [ -n "$WORKSPACE" ]; then
            xcodebuild archive -workspace "$WORKSPACE" -scheme "$SCHEME" -sdk iphoneos -configuration Release -archivePath "$ARCHIVE" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='' PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID"
          else
            xcodebuild archive -project "$PROJECT" -scheme "$SCHEME" -sdk iphoneos -configuration Release -archivePath "$ARCHIVE" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='' PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID"
          fi"""

new_run = """        - name: Build unsigned archive
        env:
          PROJECT: ${{ steps.locate.outputs.project }}
          WORKSPACE: ${{ steps.locate.outputs.workspace }}
          SCHEME: ${{ steps.locate.outputs.scheme }}
          BUNDLE_ID: ${{ inputs.bundle_id }}
        run: |
          set -uo pipefail
          ARCHIVE="$RUNNER_TEMP/App.xcarchive"
          if [ -n "$WORKSPACE" ]; then
            xcodebuild archive -workspace "$WORKSPACE" -scheme "$SCHEME" -sdk iphoneos -configuration Release -archivePath "$ARCHIVE" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='' PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" > xcodebuild.log 2>&1
          else
            xcodebuild archive -project "$PROJECT" -scheme "$SCHEME" -sdk iphoneos -configuration Release -archivePath "$ARCHIVE" CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO CODE_SIGN_IDENTITY='' PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID" > xcodebuild.log 2>&1
          fi
          EXIT_CODE=$?
          cat xcodebuild.log
          if [ $EXIT_CODE -ne 0 ]; then
            echo ""
            echo "========================================="
            echo "🔥 DETAILED ERRORS EXTRACTED FROM LOG: 🔥"
            echo "========================================="
            grep -i "error:" xcodebuild.log || true
            grep -i "failed" xcodebuild.log || true
            exit $EXIT_CODE
          fi"""

text = text.replace(old_run, new_run)

with open('.github/workflows/build-unsigned-ipa.yml', 'w', encoding='utf-8') as f:
    f.write(text)
print("Modified build-unsigned-ipa.yml")
