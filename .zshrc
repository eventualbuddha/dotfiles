################
# local config #
################

# very first config, if present
[ -f ~/.zshrc.local.init ] && source ~/.zshrc.local.init

# or generic local config
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# local functions
fpath=( "$HOME/.zfunctions" $fpath )


#########
# rbenv #
#########

export PATH="${HOME}/.rbenv/bin:${PATH}"
eval "$(rbenv init -)"


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

function gco() {
  if [ $# = 0 ]; then
    git checkout $(git-default-branch)
  else
    git checkout "$@"
  fi
}

function git-default-branch() {
  local git_dir="$(git rev-parse --git-dir)"
  local git_default_branch_file="${git_dir}/.git-default-branch"

  if [ ! -f "${git_default_branch_file}" ]; then
    git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@" > "${git_default_branch_file}"
  fi

  cat "${git_default_branch_file}"
}


###########################
# zsh syntax highlighting #
###########################

source "${HOME}/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"


###################
# local overrides #
###################

[ -f ~/.zshrc.local.override ] && source ~/.zshrc.local.override