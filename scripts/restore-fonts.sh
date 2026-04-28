#!/bin/sh
# =============================================================================
# reMarkable Chinese Font Auto-Restore Script
# 
# This script lives at /home/root/restore-fonts.sh on the reMarkable device.
# It is triggered by:
#   1. xochitl ExecStartPre (via systemd override)
#   2. SSH login (via .profile)
#
# /home/root/ is on an encrypted partition that survives OS updates.
# /etc/ is a volatile overlay that resets on reboot.
# /usr/share/fonts/ is on the root partition that OS updates overwrite.
#
# This script handles all three cases.
# =============================================================================

FONT_SRC="/home/root/.local/share/fonts"
FONT_DST="/usr/share/fonts/ttf/chinese"

# --- Step 1: Copy fonts to system directory if missing ---
if [ -d "$FONT_SRC" ] && [ ! -d "$FONT_DST" ]; then
    mount -o remount,rw /
    mkdir -p "$FONT_DST"
    cp "$FONT_SRC"/*.ttf "$FONT_DST"/ 2>/dev/null
    cp "$FONT_SRC"/*.otf "$FONT_DST"/ 2>/dev/null
    chmod 644 "$FONT_DST"/* 2>/dev/null
    mount -o remount,ro / 2>/dev/null
fi

# --- Step 2: Rebuild font cache ---
fc-cache -f -v

# --- Step 3: Ensure xochitl override exists (volatile /etc resets on reboot) ---
if [ ! -f "/etc/systemd/system/xochitl.service.d/fonts.conf" ]; then
    mkdir -p /etc/systemd/system/xochitl.service.d/
    printf "[Service]\nExecStartPre=/home/root/restore-fonts.sh\n" > /etc/systemd/system/xochitl.service.d/fonts.conf
    systemctl daemon-reload
fi
