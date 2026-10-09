#!/bin/zsh
# Builds Nouvo.app (+ Finder extension), installs it to ~/Applications and enables it.
set -euo pipefail
cd "${0:A:h}"

BUILD=build
APP="$BUILD/Nouvo.app"
EXT="$APP/Contents/PlugIns/NouvoExtension.appex"
INSTALL_DIR="$HOME/Applications"
TARGET="$(uname -m)-apple-macos13.0"

rm -rf "$BUILD"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources/Templates" "$EXT/Contents/MacOS"

echo "→ Building app"
swiftc -O -target "$TARGET" -module-name Nouvo \
  Sources/App/main.swift -o "$APP/Contents/MacOS/Nouvo"

echo "→ Building Finder extension"
swiftc -O -target "$TARGET" -module-name NouvoExtension -parse-as-library -application-extension \
  -framework FinderSync -Xlinker -e -Xlinker _NSExtensionMain \
  Sources/Extension/FinderSync.swift -o "$EXT/Contents/MacOS/NouvoExtension"

cp Support/App-Info.plist "$APP/Contents/Info.plist"
cp Support/Ext-Info.plist "$EXT/Contents/Info.plist"
mkdir -p "$EXT/Contents/Resources"
cp -R Support/Localization/*.lproj "$APP/Contents/Resources/"
cp -R Support/Localization/*.lproj "$EXT/Contents/Resources/"

echo "→ Generating templates"
T="$APP/Contents/Resources/Templates"
print -n "" | textutil -stdin -format txt -convert docx -output "$T/template.docx"
print -n "" | textutil -stdin -format txt -convert rtf  -output "$T/template.rtf"
print "{}" > "$T/template.json"
/usr/bin/python3 -I - "$T/template.xlsx" <<'PY'
import sys, zipfile
files = {
 "[Content_Types].xml": '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>',
 "_rels/.rels": '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>',
 "xl/workbook.xml": '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Feuil1" sheetId="1" r:id="rId1"/></sheets></workbook>',
 "xl/_rels/workbook.xml.rels": '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/></Relationships>',
 "xl/worksheets/sheet1.xml": '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData/></worksheet>',
}
with zipfile.ZipFile(sys.argv[1], "w", zipfile.ZIP_DEFLATED) as z:
    for name, data in files.items():
        z.writestr(name, data)
PY

echo "→ Signing (ad-hoc)"
codesign --force --sign - --entitlements Support/Ext.entitlements "$EXT"
codesign --force --sign - "$APP"

echo "→ Installing to $INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
pluginkit -r "$INSTALL_DIR/Nouvo.app/Contents/PlugIns/NouvoExtension.appex" 2>/dev/null || true
rm -rf "$INSTALL_DIR/Nouvo.app"
cp -R "$APP" "$INSTALL_DIR/"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$INSTALL_DIR/Nouvo.app"
pluginkit -a "$INSTALL_DIR/Nouvo.app/Contents/PlugIns/NouvoExtension.appex"
sleep 1 && pluginkit -e use -i io.github.kuunoh.Nouvo.FinderExtension

echo "→ Restarting Finder"
killall Finder || true

echo "✓ Done. Right-click in any Finder folder → New."
