#!/usr/bin/env bash
choice=$(echo -e "Shutdown\nReboot\nLogout" | wofi --dmenu --lines 3 --prompt "Power")
case "$choice" in
    Shutdown) systemctl poweroff ;;
    Reboot) systemctl reboot ;;
    Logout) hyprctl dispatch exit ;;
esac

