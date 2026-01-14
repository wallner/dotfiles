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
    PATH=${PATH}:${GOPATH}/bin
fi

export HISTSIZE=6144
export SAVEHIST=4096
export HISTFILE=$HOME/.zsh/history

# keybindgs
bindkey -e                  # emacs key bindings
bindkey ' ' magic-space     # also do history expansion on space
bindkey "\e[3~" delete-char # make delete work correctly

# The options. Listed  here are only those that differ from the defaults.
# They are ordered alphabetically not by subject.
setopt ALWAYS_TO_END        # Move to end of word after completion
setopt AUTO_CD              # If an unknown command is a directory cd into it.
setopt BRACE_CCL            # Expand expressions in braces
setopt COMPLETE_IN_WORD     # Don't move to end of word when completeing.
setopt CORRECT              # Try auto correction of commands
setopt EQUALS               # Filename expansion on right hand side of '='
setopt HIST_IGNORE_ALL_DUPS # Remove all duplicates from the history
setopt HIST_IGNORE_DUPS     # Ignore duplicates of direct predecessor
setopt HIST_IGNORE_SPACE    # Remove command from history if it starts with a space
setopt HIST_NO_STORE        # Don't store history in the history
setopt HIST_REDUCE_BLANKS   # Remove all superflous blanks from history entries
setopt SHARE_HISTORY        # History is shared between shells.
setopt LONG_LIST_JOBS       # Display jobs in long list formats
setopt MARK_DIRS            # Mark a generated filename as directory '/'
setopt NUMERIC_GLOB_SORT    # Sort generated numerical file names numerical
setopt PUSHD_TO_HOME        # empty pushd pushes '~' onto stack

export EDITOR=vim
export PAGER=less
export LESS='-deFgiMRSX -P?fFile %f:stdin. ?m(%i of %m) :.line %l ?Lof %L:.?p (%p\%):.'
export LESSCHARSET=utf-8   # Is this still necessary?
# Format man pages for a wigth of 80 col no matter how wide the terminal
export MANWIDTH=80
# Use bat as manual pager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export MANROFFOPT="-c"

# In the process of switching to bat, but for the time beiing...
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
alias xc='xclip -i -selection clipboard'
alias vim='vimx'

# Completition control
fpath=($HOME/.zsh/completion $fpath)

autoload -Uz compinit && compinit -i
autoload -U +X bashcompinit && bashcompinit

# initialize antidote
if [ ! -d ${HOME}/.zsh/antidote ]; then
    git clone --depth=1 https://github.com/mattmc3/antidote.git ${HOME}/.zsh/antidote
fi
source ${HOME}/.zsh/antidote/antidote.zsh
zstyle ':antidote:bundle' file ${HOME}/.zsh/plugins.txt
zstyle ':antidote:static' file ${HOME}/.zsh/plugins.zsh
antidote load

# Completion caching
zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $HOME/.zsh/cache/$HOST

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
zstyle ':completion:*' group-name ''

# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# match uppercase from lowercase
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '*\~'

# Separate matches into groups
zstyle ':completion:*:matches' group 'yes'

# Describe options in full
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'

# Searchable display strings
zstyle ':completion:*' fzf-search-display true
# disable sort when completing 'git checkout'
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# give a preview of commandline arguments when completing `kill`
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
# preview when completing env vars (note: only works for exported variables)
# eval twice, first to unescape the string, second to expand the $variable
zstyle ':completion::*:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-completion-opts --preview='eval eval echo {1}'
# preview a `git status` when completing git add
zstyle ':completion::*:git::git,add,*' fzf-completion-opts --preview='git -c color.status=always status --short'

# enable fzf

export FZF_TMUX=1
export FZF_TMUX_OPTS="-p80%,60%"
export FZF_DEFAULT_OPTS="--layout=reverse-list --no-separator --border=rounded \
                         --info=inline -m --prompt='▶' --pointer='→' \
                         --marker='♡ '"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --ignore-file "$HOME/.gitexcludes" \
                               --exclude .git --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND=${FZF_DEFAULT_COMMAND}
export FZF_COMPLETION_OPTS='--border --info=inline'

precmd() {
    if [ $(get_theme.sh) = 'dark' ]; then
        export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} \
                        --color=bg+:#414559,bg:#303446,spinner:#f2d5cf,hl:#e78284 \
                        --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf \
                        --color=marker:#f2d5cf,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284"
        export FZF_CTRL_T_OPTS="${FZF_DEFAULT_OPTS} --preview 'pistol {}' \
                         --header 'E to edit' --bind 'E:execute(vim {})'"
        export BAT_THEME="Catppuccin Macchiato"
        export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#838ba7"  #Frappe overlay1
    else
        export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS} \
                        --color=bg+:#ccd0da,bg:#eff1f5,spinner:#dc8a78,hl:#d20f39 \
                        --color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78 \
                        --color=marker:#dc8a78,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39"
        export FZF_CTRL_T_OPTS="${FZF_DEFAULT_OPTS} --preview 'pistol {}' \
                         --header 'E to edit' --bind 'E:execute(vim {})'"
        export BAT_THEME="Catppuccin Latte"
        export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#8c8fa1" # Latte Overlay1
    fi
}

source /usr/share/fzf/shell/key-bindings.zsh


# use the tmux popup
zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
zstyle ':fzf-tab:*' popup-min-size 70 25
zstyle ':fzf-tab:*' popup-pad 30 0
zstyle ':fzf-tab:*' default-color $'\033[38m'

# Show systemd unit status
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# give a preview of commandline arguments when completing `kill`
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
'[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap

# environment variable
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
    fzf-preview 'echo ${(P)word}'


# preview for git commands
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
    'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
    'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
    'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
    'case "$group" in
    "commit tag") git show --color=always $word ;;
    *) git show --color=always $word | delta ;;
    esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
    'case "$group" in
    "modified file") git diff $word | delta ;;
    "recent commit object name") git show --color=always $word | delta ;;
    *) git log --color=always $word ;;
    esac'

# preview for directories
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'pistol ${(Q)realpath}'

if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

if (( $+commands[terraform] )); then
    complete -o nospace -C $(which terraform) terraform
fi

if (( $+commands[tofu] )); then
    complete -o nospace -C $(which tofu) tofu
fi

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

if [ -f /usr/lib64/google-cloud-sdk/completion.zsh.inc ]; then
    source "/usr/lib64/google-cloud-sdk/completion.zsh.inc"
fi

eval "$(direnv hook zsh)"

# Removing duplicate entries from $PATH
typeset -U PATH

eval "$(starship init zsh)"


