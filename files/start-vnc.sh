#!/bin/bash

echo $VNC_PASSWORD | vncpasswd -f > $HOME/.vnc/passwd

vncserver :0 -fg \
  -SecurityTypes VncAuth \
  -depth $VNC_COLOR_DEPTH \
  -geometry $VNC_GEOMETRY \
  -passwd $HOME/.vnc/passwd
