
#!/bin/bash
# Check if the user is logged in
USER=$(who | grep '(:0)' | awk '{print $1}')
if [ -n "$USER" ]; then
    export DISPLAY=:0
    export XAUTHORITY=/home/brage/.Xauthority
    su $USER -c "xset dpms force off"
fi
