#!/usr/bin/env bash


pkill yambar

# if type "xrandr"; then
#   for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#     MONITOR=$m yambar &
#   done
# else
yambar &
# fi
