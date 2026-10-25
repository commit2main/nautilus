# Use the image's uxplayrc (fixed ports) unless the user has their own.
if [ -z "${UXPLAYRC:-}" ] && [ ! -e "$HOME/.uxplayrc" ] && [ ! -e "$HOME/.config/uxplayrc" ]; then
  export UXPLAYRC=/usr/share/uxplay/uxplayrc
fi
