#!/usr/bin/env bash
# Declutter a Sony Bravia Google TV (e.g. XR-65X90L) over ADB.
# Every change here is a reversible `pm disable-user`; run with `restore` to undo.
#
# Usage:
#   ./declutter.sh <TV_IP>            # list candidates, then disable after confirmation
#   ./declutter.sh <TV_IP> restore    # re-enable everything this script disabled
#   ./declutter.sh <TV_IP> list       # only show matching packages on the TV
set -euo pipefail

TV_IP="${1:?Usage: $0 <TV_IP> [list|restore]}"
MODE="${2:-apply}"
TARGET="$TV_IP:5555"

# Packages that serve promoted rows / ad tiles. Names vary by firmware, so
# anything not installed on the TV is simply skipped.
PACKAGES=(
  com.google.android.tvrecommendations   # "Sponsored" / recommendation rows
  com.google.android.apps.tv.dreamx      # Google TV ambient mode promos
  com.sony.dtv.sonyselect                # Sony Select promo tile
  com.sony.dtv.promos                    # Sony promo content (some firmwares)
  com.sony.dtv.interactivetvutil         # interactive ad overlays (some firmwares)
  com.samba.tv                           # Samba TV viewing-data/ads (if bundled)
)

command -v adb >/dev/null || { echo "Install adb first (Android platform-tools)."; exit 1; }

echo "Connecting to $TARGET — accept the 'Allow USB debugging' prompt on the TV."
adb connect "$TARGET" >/dev/null
adb -s "$TARGET" wait-for-device

installed=$(adb -s "$TARGET" shell pm list packages | sed 's/^package://' | tr -d '\r')
present=()
for p in "${PACKAGES[@]}"; do
  grep -qx "$p" <<<"$installed" && present+=("$p")
done

case "$MODE" in
  list)
    echo "Matching packages on this TV:"; printf '  %s\n' "${present[@]:-(none)}"
    echo; echo "Other Sony/Google TV packages, for reference:"
    grep -E '^com\.(sony\.dtv|google\.android\.(tv|apps\.tv))' <<<"$installed" | sed 's/^/  /'
    ;;
  restore)
    for p in "${PACKAGES[@]}"; do
      adb -s "$TARGET" shell pm enable "$p" >/dev/null 2>&1 && echo "re-enabled $p" || true
    done
    ;;
  apply)
    [ ${#present[@]} -eq 0 ] && { echo "Nothing to disable on this firmware."; exit 0; }
    echo "Will disable:"; printf '  %s\n' "${present[@]}"
    read -rp "Proceed? [y/N] " ok; [[ "$ok" =~ ^[Yy]$ ]] || exit 0
    for p in "${present[@]}"; do
      adb -s "$TARGET" shell pm disable-user --user 0 "$p" && echo "disabled $p"
    done
    echo "Done. Restart the TV (hold power on remote → Restart)."
    ;;
  *) echo "Unknown mode: $MODE"; exit 1 ;;
esac
