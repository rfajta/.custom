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
~/.custom/bin/initcolors.sh

# using clever pager most, which supports olors for e.g. manpages
export MANPAGER="most"

#export JAVA8_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_51.jdk/Contents/Home
export JAVA_HOME=`/usr/libexec/java_home -v '1.8*'`
#JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_51.jdk/Contents/Home

export GOPATH=$HOME/.go

export PAGER=more

