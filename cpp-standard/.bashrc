alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias ll='ls -lah'

# Git PS1
if [ -f /usr/lib/git-core/git-sh-prompt ]; then
    source /usr/lib/git-core/git-sh-prompt
fi
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
export GIT_PS1_SHOWUNTRACKEDFILES=true
export GIT_PS1_SHOWUPSTREAM=auto
PS1='\[\e[32m\]\u@\h\[\e[0m\]:\[\e[34m\]\W\[\e[31m\]$(__git_ps1 " (%s)")\[\e[0m\]\$ '
