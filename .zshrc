# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path setup
PATH="/opt/homebrew/bin:$PATH"
PATH="$(go env GOPATH)/bin:$PATH"
PATH="$HOME/.cargo/bin:$PATH"
PATH="/opt/homebrew/opt/python@3.13/libexec/bin:$PATH"
PATH="/opt/homebrew/opt/ffmpeg@6/bin:$PATH"
PATH="/opt/homebrew/opt/mysql@8.4/bin:$PATH"
PATH="$HOME/Developer/dotfiles/bin:$PATH"
PATH="$HOME/.ghcup/bin:$PATH"
export PATH

# Homebrew
eval "$(brew shellenv)"

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in Powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit

zinit cdreplay -q

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Open command in edit buffer
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^e' edit-command-line

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey "^[^[[D" backward-word
bindkey "^[^[[C" forward-word

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:nvim:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:nvim:*' fzf-preview '
if [[ -d $realpath ]]; then
    ls --color $realpath
else
    cat $realpath
fi
'

# Global Aliases
alias -g NE='2>/dev/null'

# Aliases
alias ls='ls --color'
alias l='ls --color -lah'
alias cdd='cd ~/Developer/'
alias cdt='cd ~/Developer/testing'
alias cds='cd ~/Developer/School/year3'
alias gs='git status'
alias statusbarfix='xcrun simctl status_bar booted override --time 9:41 --cellularMode active --cellularBars 4 --batteryState charging --operatorName ""'
alias vim='nvim'
alias tree='tree -C --gitignore -a -I ".git"'
alias kctl='kubectl'
alias tctl='talosctl'
alias exportenv='export $(grep -v '^#' .env | xargs)'
alias dcu='docker-compose up -d'
alias dcd='docker-compose down'
alias dcs='docker-compose stop'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias or='vim $HOME/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/harrydayexe/inbox/*.md'
alias oo='cd $HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/harrydayexe'
alias ob='open /Applications/Obsidian.app'
alias bsi='cbonsai -S --life=60'

alias glu='git fetch --prune && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}"'
alias gru='git fetch --prune && git branch -r | awk "{print \$1}" | egrep -v -f /dev/fd/0 <(git branch -vv | grep origin) | awk "{print \$1}" | xargs git branch -d'
alias gpm='git co main && git pull origin main'

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Shell integrations
eval "$(fzf --zsh)"
if [ -z "$DISABLE_ZOXIDE" ]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# The Fuck
eval "$(thefuck --alias)"

# Add ssh agent
eval "$(ssh-agent -s &>/dev/null)"

# NVM integrations
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Set LS COLORS
export LSCOLORS="ExFxBxDxCxegedabagacad"

# For GPG
export GPG_TTY=$(tty)
alias testgpg="echo \"test\" | gpg --clearsign"
alias killgpg="gpgconf --kill gpg-agent"

source ~/.iterm2_shell_integration.zsh

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
