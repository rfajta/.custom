. ~/.custom/environment/envvars.sh
[[ -s `brew --prefix`/etc/autojump.sh ]] && . `brew --prefix`/etc/autojump.sh

##
# Your previous /Users/robertfa/.bash_profile file was backed up as /Users/robertfa/.bash_profile.macports-saved_2014-01-23_at_15:06:13
##

# MacPorts Installer addition on 2014-01-23_at_15:06:13: adding an appropriate PATH variable for use with MacPorts.
export PATH=/opt/local/bin:/opt/local/sbin:$PATH
# Finished adapting your PATH environment variable for use with MacPorts.


[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

. ~/.custom/environment/prompt.sh
. ~/.custom/environment/aliases.sh
. ~/.custom/environment/commands.sh
. ~/.custom/bin/mvncolor.sh
