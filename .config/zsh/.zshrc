# vim: filetype=zsh
# Florian Wallners zshrc

if [ -d ${HOME}/bin ]; then
    PATH=${HOME}/bin:$PATH
fi

if [ -d "${HOME}/.local/bin" ]; then
    PATH=${HOME}/.local/bin:${PATH}
fi

if [ -d ${HOME}/workspace/golang ]; then
    export GOPATH=${HOME}/workspace/golang
    export GOBIN=${GOPATH}/bin

    PATH=${PATH}:${GOBIN}
fi

export HISTSIZE=6144
export SAVEHIST=4096
export HISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history
mkdir -p "$(dirname "$HISTFILE")"

# keybindings
bindkey -e                  # emacs key bindings
bindkey ' ' magic-space     # also do history expansion on space
bindkey "\e[3~" delete-char # make delete work correctly

# The options. Listed  here are only those that differ from the defaults.
# They are ordered alphabetically not by subject.
setopt ALWAYS_TO_END        # Move to end of word after completion
setopt AUTO_CD              # If an unknown command is a directory cd into it.
setopt BRACE_CCL            # Expand expressions in braces
setopt COMPLETE_IN_WORD     # Don't move to end of word when completing.
setopt CORRECT              # Try auto correction of commands
setopt EQUALS               # Filename expansion on right hand side of '='
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history
setopt HIST_FIND_NO_DUPS    # Don't display a line previously found
setopt HIST_IGNORE_ALL_DUPS # Remove all duplicates from the history
setopt HIST_IGNORE_SPACE    # Remove command from history if it starts with a space
setopt HIST_NO_STORE        # Don't store history in the history
setopt HIST_REDUCE_BLANKS   # Remove all superflous blanks from history entries
setopt HIST_SAVE_NO_DUPS    # Don't write duplicate entries in the history file
setopt SHARE_HISTORY        # History is shared between shells.
setopt LONG_LIST_JOBS       # Display jobs in long list formats
setopt MARK_DIRS            # Mark a generated filename as directory '/'
setopt NUMERIC_GLOB_SORT    # Sort generated numerical file names numerical
setopt PUSHD_TO_HOME        # empty pushd pushes '~' onto stack

export EDITOR=vim
export PAGER=less
export LESS='-deFgiMRSX -P?fFile %f:stdin. ?m(%i of %m) :.line %l ?Lof %L:.?p (%p\%):.'
export LESSCHARSET=utf-8   # Is this still necessary?
# Format man pages for a width of 80 col no matter how wide the terminal
export MANWIDTH=80
# Use bat as manual pager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# In the process of switching to bat, but for the time being...
if [ -f /usr/share/source-highlight/src-hilite-lesspipe.sh ]; then
    LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
fi


# Don't ignore leading dots when sorting.
export LC_COLLATE="C"
export LC_CTYPE=en_US.UTF-8
export LANG=en_US.UTF-8

# Set up aliases
alias mv='nocorrect mv'    # no spelling correction on mv
alias cp='nocorrect cp'    # no spelling correction on cp
alias mkdir='nocorrect mkdir' # no spelling correction on mkdir

if (( $+commands[eza] )); then
    alias ll='eza -l --icons --git --group-directories-first'
    alias la='eza -la --icons --git --group-directories-first'
else
    alias ll='ls -l'
    alias la='ls -a'
fi

alias cd..="cd .."
alias \#='sudo'
alias doch='sudo $(fc -ln -1)'
alias cat='bat -p'
alias xps='ps aucx | head -1; ps aucx | grep -i '
alias https='http --default-scheme=https'
alias xc='wl-copy'
if (( $+commands[vimx] )); then
    alias vim='vimx'
fi

# 1. Completion control & init
fpath=(${ZDOTDIR:-$HOME/.config/zsh}/completion $fpath)
autoload -Uz compinit && compinit -i
if (( $+commands[terraform] )) || (( $+commands[tofu] )); then
    autoload -U +X bashcompinit && bashcompinit
fi

# 2. initialize sheldon plugin manager (loads fzf-tab)
if (( $+commands[sheldon] )); then
    eval "$(sheldon source)"
fi

# 3. FZF Configuration (Base options MUST be set before theme)
export FZF_TMUX=1
export FZF_TMUX_OPTS="-p80%,60%"
export FZF_BASE_OPTS="--layout=reverse-list --no-separator --border=rounded \
                         --info=inline -m --prompt='▶' --pointer='→' \
                         --marker='♡ '"
export FZF_DEFAULT_OPTS_FILE="$HOME/.config/fzf/colors"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --ignore-file "$HOME/.gitexcludes" \
                               --exclude .git --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND=${FZF_DEFAULT_COMMAND}
export FZF_COMPLETION_OPTS='--border --info=inline'

# 4. Load theme colors (Appends colors to FZF_DEFAULT_OPTS and sets zstyles)
theme_file=${XDG_STATE_HOME:-$HOME/.local/state}/zsh/theme_colors.zsh
[[ -f "$theme_file" ]] && source "$theme_file"

# Reload theme on USR1 signal (sent by theme-watcher.service)
TRAPUSR1() {
    [[ -f "$theme_file" ]] && source "$theme_file"
}

# 5. Load completion styles (MUST come after fzf-tab and theme)
[[ -f ${ZDOTDIR:-$HOME/.config/zsh}/completion.zsh ]] && source ${ZDOTDIR:-$HOME/.config/zsh}/completion.zsh

[[ -f /usr/share/fzf/shell/key-bindings.zsh ]] && source /usr/share/fzf/shell/key-bindings.zsh

if (( $+commands[kubectl] )); then
    source <(kubectl completion zsh)
fi

if (( $+commands[minikube] )); then
    source <(minikube completion zsh)
fi

if (( $+commands[helm] )); then
    source <(helm completion zsh)
fi

if (( $+commands[k3d] )); then
    source <(k3d completion zsh)
fi

if (( $+commands[stern] )); then
    source <(stern --completion zsh)
fi

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

# GCloud SDK completion
for gcloud_completion in \
    "/usr/lib64/google-cloud-sdk/completion.zsh.inc" \
    "/usr/share/google-cloud-sdk/completion.zsh.inc" \
    "/opt/google-cloud-sdk/completion.zsh.inc"; do
    if [ -f "$gcloud_completion" ]; then
        source "$gcloud_completion"
        break
    fi
done

if (( $+commands[direnv] )); then
    eval "$(direnv hook zsh)"
fi

# 6. Starship Configuration (Using dynamic config in state directory)
export STARSHIP_CONFIG="$HOME/.local/state/starship/config.toml"
eval "$(starship init zsh)"
