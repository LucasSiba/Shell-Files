# .bashrc

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
   platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
   platform='freebsd'
elif [[ "$unamestr" == 'Darwin' ]]; then
   platform='osx'
fi

hex2dec () {
    echo $* | perl -lne 'foreach $num (split /\s/) { $hex_val = hex($num); print $hex_val; }'
}

dec2hex () {
    echo $* | perl -lne 'foreach $num (split /\s/) { printf "%x\n", $num }'
}

unix2real () {
    perl -MPOSIX -le 'print "$_ => ".strftime("%F %T", gmtime $_) for @ARGV' $*
}

sxe_chomp () {
    perl -nle '$l=$_; if ($l=~/^\d{8}\s\d{6}/) {$l=substr($l, 39);} print $l;'
}

hed() {
    let HEAD_LINES=$LINES-4
    head -n $HEAD_LINES $1
}

tale() {
    let TAIL_LINES=$LINES-4
    tail -n $TAIL_LINES $1
}

h() {
    history | grep -i $* | perl -nale 'BEGIN{%x=();} $_ =~ /^\s*(\d*)  (.*)$/; $x{$2}=$1; END{ @keys = sort { $x{$a} <=> $x{$b} } keys(%x); foreach $k (@keys) {print "$k"} }' | tale
}

infocat() {
    perl -MFile::stat -MIO::Handle -e 'foreach $f (@ARGV) {STDERR->autoflush(1); $s=stat($f)->size; open($FH, "<$f") or die "Failed to open $f: $!"; $r = 0; $old_p; while (<$FH>) { print $_; $r += length($_); $p = int(($r/$s)*100); if ($p != $old_p) { print stderr sprintf("\r$f - %d\% ", $p); $old_p = $p; } } print stderr "\n"; } ' $@
}

linecount() {
    perl -e 'our $c = 0; $SIG{ALRM} = sub { print stderr sprintf("\r%d", $c); alarm 1; }; alarm 1; while (<>) { $c++; } print stderr "\r$c\n";'
}

go_utf8() {
    export LC_ALL=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LANGUAGE=en_US.UTF-8
}

dbg () {   
    local pgm=$1;
    shift;
    test -f $pgm || pgm=$(which $pgm);
    local type=$(file $pgm);
    case "$type" in
        *core\ file*)
            pgm=$(echo $type | sed "s/^\([^:]*\).*'\(.*\)'/\2 \1/")
        ;;
        *)  
            cmdf=/tmp/gdb.$(basename `tty`);
            local argv=$(perl -le "print join' ',map{qq{'\$_'}}@ARGV" -- "$@");
            cat > $cmdf  <<-END
    she rm -f $cmdf
    set confirm off
    set print pretty
    set listsize 40
    tb main
    r $argv
END
            set -- -x $cmdf
        ;;
    esac;
    $(which gdb) -q $pgm $*
}

# how - Like "which", but finds aliases/bash-fns and perl modules. Expands symlinks and shows file type.
how() {
    PATH=$PATH  # reset path search
    shopt -s extdebug
    typeset -F $1 2>&- \
    || alias $1 2>&- \
    || case $1 in *::*)
        perl -m$1 -e '($x="'$1'")=~s|::|/|g; print $INC{"$x.pm"}."\n"'
        ;;
       *)
        local w=$(which $1)
        if [ "$w" ]; then
            local r=$(realpath $w)
            test $w = $r || echo -n "$w -> "
            file $r | sed s/,.*//
        fi
       esac
    shopt -u extdebug
}

#######################
#
#  aliases
#
#######################

alias l="ls -alF"
alias ll="ls -lhF"
if [[ $platform == 'freebsd' || $platform == 'osx' ]]; then
   alias ls='ls -F -G'
else
    alias ls='ls -F --color=auto'
fi
ls-() { ls -$*; }
alias grep="grep --color --binary-files=without-match -E"
alias egrep="egrep --color --binary-files=without-match"

#######################
#
#  environment settings
#
#######################

export EDITOR=vim
export HISTCONTROL=ignoredups
export HISTSIZE=50000
export HISTFILESIZE=50000
shopt -s histappend
export PROMPT_COMMAND='history -a'
export LESS=-iqsMRXF
export GNU_WHICH=/usr/local/bin/which
export PAGER="less -isM"
export LC_ALL=C
export LANG=C

# check the window size after each command and, if necessary, update the values of LINES and COLUMNS.
shopt -s checkwinsize

if [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
  HAS_COMPLETION=1
fi

if [ "$HAS_COMPLETION" ]; then
  export GIT_PS1_SHOWDIRTYSTATE=1
  PS1='$( [ $? = 0 ] && echo "\[\033[01;33m\]\t" || echo "\[\033[31m\]>>> \t <<<" ) \[\033[01;32m\]\u@\[\033[01;33m\]\h:\[\033[01;32m\]\w\[\033[01;33m\]$(__git_ps1)\n\[\033[01;32m\]# \[\033[00m\]'
else
  PS1='$( [ $? = 0 ] && echo "\[\033[01;33m\]\t" || echo "\[\033[31m\]>>> \t <<<" ) \[\033[01;32m\]\u@\[\033[01;33m\]\h:\[\033[01;32m\]\w\n\[\033[01;32m\]# \[\033[00m\]'
fi

PS4='\t + '         # ... for "set -x"

# Adjust the PATH
echo $PATH | fgrep -q $HOME/bin   || PATH=$HOME/bin:$PATH
echo $PATH | fgrep -q :/sbin      || PATH=$PATH:/sbin
echo $PATH | fgrep -q :/usr/sbin  || PATH=$PATH:/usr/sbin
export PATH

# SSH AGENT 
GREP=`which grep`
test=`/bin/ps -ef | $GREP ssh-agent | $GREP -v grep | /usr/bin/awk '{print $2}' | xargs`
if [ "$test" = "" ]; then
   # there is no agent running
   if [ -e "$HOME/agent.sh" ]; then
      # remove the old file
      /bin/rm -f $HOME/agent.sh
   fi;
   # start a new agent
   /usr/bin/ssh-agent | $GREP -v echo >&$HOME/agent.sh
fi;
test -e $HOME/agent.sh && source $HOME/agent.sh
alias kagent="kill -9 $SSH_AGENT_PID"

