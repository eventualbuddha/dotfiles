################
# local config #
################

# very first config, if present
[ -f ~/.zshrc.local.init ] && source ~/.zshrc.local.init

# or generic local config
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# local functions
fpath=( "$HOME/.zfunctions" $fpath )

# local scripts
export PATH="${HOME}/bin:${PATH}"

# yarn global binaries
export PATH="${HOME}/.yarn/bin:${PATH}"

# editor config
export EDITOR=vim


################
# key bindings #
################

bindkey -e

###########
# aliases #
###########

alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

alias serve='python3 -m http.server'


########
# asdf #
########

ASDF_DIR="${HOME}/.asdf"
# https://asdf-vm.com/guide/getting-started.html#_3-install-asdf
source "${ASDF_DIR}/asdf.sh"
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit && compinit


#########################
# History Configuration #
#########################

HISTSIZE=5000               # How many lines of history to keep in memory
HISTFILE=~/.zsh_history     # Where to save history to disk
SAVEHIST=5000               # Number of history entries to save to disk
HISTDUP=erase               # Erase duplicates in the history file
setopt appendhistory        # Append history to the history file (no overwriting)
setopt sharehistory         # Share history across terminals
setopt incappendhistory     # Immediately append to the history file, not just when a term is killed
setopt HIST_IGNORE_ALL_DUPS # Delete old recorded entry if new entry is a duplicate.


#################
# prompt (pure) #
#################

autoload -U promptinit; promptinit
prompt pure


###########################
# fzf – fuzzy file finder #
###########################

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


############
# autojump #
############

[[ -s ~/.autojump/etc/profile.d/autojump.sh ]] && source ~/.autojump/etc/profile.d/autojump.sh
autoload -U compinit && compinit -u


#######
# git #
#######

alias gs="git status"
alias gd="git diff"
alias gco="git-checkout-plus"

# https://github.com/junegunn/fzf/wiki/examples
# fbr - checkout git branch (including remote branches), sorted by most recent commit, limit 30 last branches
fbr() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

###########################
# zsh syntax highlighting #
###########################

source "${HOME}/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"


###################
# local overrides #
###################

[ -f ~/.zshrc.local.override ] && source ~/.zshrc.local.override
