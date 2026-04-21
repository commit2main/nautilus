# From https://wiki.archlinux.org/title/Fish#Modify_.bashrc_to_drop_into_fish
# Added interactivity check to workaround SDDM bug https://github.com/sddm/sddm/issues/1807
if grep -qv 'fish' /proc/$PPID/comm && [[ ${SHLVL} == [1,2] ]] && [ -z "$GREETD_SOCK" ]
then
	shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
	exec fish $LOGIN_OPTION
fi
