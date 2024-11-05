alias nnn="$HOME/bin/nnn -de"
export NNN_FIFO="/tmp/nnn.fifo"
export NNN_PLUG="p:preview-tui"
export OH_MY_ZSH="$HOME/.oh-my-zsh"


plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $OH_MY_ZSH/oh-my-zsh.sh

n () # to cd on quit
{
    if [ -n $NNNLVL ] && [ "${NNNLVL:-0}" -ge 1 ]; then
        echo "nnn is already running"
        return
    fi
    export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
    nnn "$@"
    if [ -f "$NNN_TMPFILE" ]; then
            . "$NNN_TMPFILE"
            rm -f "$NNN_TMPFILE" > /dev/null
    fi
}
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/home/steven/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/home/steven/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/home/steven/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/home/steven/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

eval "$(starship init zsh)"
