#!/usr/bin/env bash
choice=$(echo -e "Integrated\nHybrid" | wofi --dmenu --lines 2 --prompt "GPU Mode")
case "$choice" in
    Integrated) supergfxctl -m Integrated ;;
    Hybrid) supergfxctl -m Hybrid ;;
esac

