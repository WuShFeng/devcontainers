alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lah'
# Pyenv
export PYENV_ROOT=$HOME/.pyenv
export PATH=$PYENV_ROOT/bin:$HOME/.local/bin:$PATH
eval "$(pyenv init - bash)"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s /usr/share/nvm/init-nvm.sh ] && source /usr/share/nvm/init-nvm.sh

# Git PS1
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
    source /usr/share/git/completion/git-prompt.sh
fi
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=auto
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\W\[\e[31m\]$(__git_ps1 " (%s)")\[\e[0m\]\$ '
