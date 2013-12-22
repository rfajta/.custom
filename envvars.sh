shopt -s autocd
export CDPATH=./:~/

# Tell ls to be colourful
export CLICOLOR=1

# Tell grep to highlight matches
export GREP_OPTIONS='--color=auto'
export LSCOLORS=gxBxhxDxfxhxhxhxhxcxcx

# PATH
export PATH="$PATH:.:~/bin"

# init colors
~/.custom/initcolors.sh

# using clever pager most, which supports olors for e.g. manpages
export MANPAGER="most"
