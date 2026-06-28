alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lah'
# Pyenv
export PYENV_ROOT=/usr/local/pyenv
export PATH=$PYENV_ROOT/bin:$HOME/.local/bin:$PATH
eval "$(pyenv init - bash)"

# nvm
export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Git PS1
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    source /usr/lib/git-core/git-sh-prompt
fi
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=auto
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\W\[\e[31m\]$(__git_ps1 " (%s)")\[\e[0m\]\$ '
