#!/bin/zsh
# Désinstalle Nouvo.
APP="$HOME/Applications/Nouvo.app"
pluginkit -e ignore -i io.github.kuunoh.Nouvo.FinderExtension 2>/dev/null
pluginkit -r "$APP/Contents/PlugIns/NouvoExtension.appex" 2>/dev/null
rm -rf "$APP"
killall Finder 2>/dev/null
echo "✓ Nouvo désinstallé."
