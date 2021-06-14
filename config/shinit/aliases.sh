#!/bin/sh

export LS_OPTIONS='-h --color'

alias ls='ls ${LS_OPTIONS}'
alias sl='ls ${LS_OPTIONS}'
alias lh='ls ${LS_OPTIONS}'

alias ll='ls ${LS_OPTIONS} -l'
alias l='ls ${LS_OPTIONS} -lAF'


export DF_OPTIONS='-h'
alias df='df ${DF_OPTIONS}'

alias 'cd..'='cd ..'
# cd. is cd .., not cd $PWD
alias 'cd.'='cd ..'

alias xargs0='xargs -0'

#alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
## busybox ignores the "-v"
alias mvi='mv -vi'

export GIT_LANG='en_US.UTF-8'
alias git='LANG=${GIT_LANG:-C} LC_ALL=${GIT_LANG:-C} git'
# typo.
alias gti='LANG=${GIT_LANG:-C} LC_ALL=${GIT_LANG:-C} git'

alias tcpdump='tcpdump -s 65535'
