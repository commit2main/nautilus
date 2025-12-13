# From https://wiki.archlinux.org/title/Fish#Modify_.bashrc_to_drop_into_fish
# Added interactivity check to workaround SDDM bug https://github.com/sddm/sddm/issues/1807
if [[ $- == *i* ]] &&
   [[ -z ${BASH_EXECUTION_STRING} ]] &&
   [[ ${SHLVL} -eq 1 ]] &&
   [[ $(ps -p $PPID -o comm=) != fish ]]
then
    shopt -q login_shell && LOGIN_OPT='--login' || LOGIN_OPT=''
    exec fish $LOGIN_OPT
fi