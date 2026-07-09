#!/usr/bin/env bash
set -euo pipefail

godot --headless --export-release "Web" "export/web/index.html"
# cp web/web_shell.css export/web/web_shell.css

rm -f export/web_export.zip
(cd export/web && zip -rq ../web_export.zip .)
echo "Created export/web_export.zip"

echo "Uploading to itch.io..."
~/.config/itch/apps/butler/butler push export/web b1773rm4n/psx-strike:web
echo "Uploaded to https://itch.io/t/b1773rm4n/psx-strike"

echo "Serving export/web at http://127.0.0.1:8000"
cd export/web
exec python -m http.server