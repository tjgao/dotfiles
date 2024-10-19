. "$HOME/.cargo/env"

export EDITOR="/opt/neovim/bin/nvim"
# function preexec() {
#     timer=$(($(date +%s%0N)))
# }
# function precmd() {
#     if [ $timer ]; then
#         now=$(($(date +%s%0N)))
#         elapsed=$(~/.local/bin/elapsed_time_fmt.py $(($now-$timer)))
#         export RPROMPT="%F{cyan}${elapsed} %{$reset_color%}"
#         unset timer
#     fi
# }

function fcd() {
    folder=$(fd -t d | fzf -q "$1")
    echo $folder
    if [[ ! -z "$folder" ]]
    then
        cd $folder
    fi
}
