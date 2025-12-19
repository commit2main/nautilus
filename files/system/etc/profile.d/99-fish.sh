# From https://wiki.archlinux.org/title/Fish#Modify_.bashrc_to_drop_into_fish
# Added interactivity check to workaround SDDM bug https://github.com/sddm/sddm/issues/1807
if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && ${SHLVL} -lt 3 ]]
then
	shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
	exec fish $LOGIN_OPTION
fi