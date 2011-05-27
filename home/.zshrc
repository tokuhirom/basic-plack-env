# =========================================================================
# tokuhirom's .zshrc
#
# =========================================================================

# -------------------------------------------------------------------------
# terminal
#
# -------------------------------------------------------------------------
# Ctrl+S での stop をやめる
stty stop undef

if [ "$TERM" = "linux" ] ; then
    export LANG=C
else
    export LANG=ja_JP.UTF-8
fi
export LV='-Ou8 -c'
export LC_DATE=C
# export LC_ALL=C

# -------------------------------------------------------------------------
# zsh basic settings
#
# -------------------------------------------------------------------------
# emacs like keybindings
bindkey -e
#履歴たっぷりで。
HISTFILE=$HOME/.zsh-history           # 履歴をファイルに保存する
HISTSIZE=1000                         # メモリ内の履歴の数
SAVEHIST=1000                         # 保存される履歴の数
setopt extended_history               # 履歴ファイルに時刻を記録
setopt share_history                  # 履歴を全端末で共有
export HARNESS_COLOR=1 # Test::Harness.

# zsh completion
fpath=(~/.zsh/completion/ $fpath)
autoload -U ~/.zsh/completion/*(:t)
autoload -U compinit
# -C: security check を無視 http://www.u-suke.org/wiki/?page=zsh%2Fcompinit
compinit -C

export PATH="/usr/local/bin/:$PATH"
export PATH="$HOME/bin:$HOME/local/bin/:$PATH"
if [ -e "$HOME/share/dotfiles/local/bin/" ]
then
	export PATH="$PATH:$HOME/share/dotfiles/local/bin/"
fi
if [ -e "$HOME/private-bin/" ]
then
	export PATH="$PATH:$HOME/private-bin/"
fi
if [ -e "/usr/local/mysql/bin/" ]
then
	export PATH="/usr/local/mysql/bin/:$PATH"
fi
if [ -e "/usr/local/app/perl/bin/" ]
then
	export PATH="/usr/local/app/perl/bin/:$PATH"
fi
if [ -e "/usr/local/app/perl/bin/" ]
then
	export PATH="/usr/local/app/perl/bin:$PATH"
fi

setopt autopushd print_eight_bit
setopt auto_menu auto_cd correct auto_name_dirs auto_remove_slash
setopt extended_history hist_ignore_dups hist_ignore_space prompt_subst
setopt pushd_ignore_dups rm_star_silent sun_keyboard_hack
setopt extended_glob list_types no_beep always_last_prompt
setopt cdable_vars sh_word_split auto_param_keys
unsetopt promptcr
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# URL の自動クォート
autoload -U url-quote-magic
zle -N self-insert url-quote-magic


# -------------------------------------------------------------------------
# ls 関係
#
# -------------------------------------------------------------------------
if [ "$HOST" = 'skinny.local' ]; then
    alias ls='/usr/local/bin/ls --color -ltr'
else
    alias ls='\ls --color -ltr'
fi
alias s='ls'
alias l='ls'
alias sl='ls'
alias la='ls -a'
alias ll='ls -l'
alias llh='ls -lh'
alias まけ='make'

# -------------------------------------------------------------------------
# プロンプトの設定
#
# -------------------------------------------------------------------------
setopt prompt_subst

# 色設定を簡単にするための術
autoload colors
colors

set_prompt() {
    # ダム
    if [ "$TERM" = "dumb" ] ; then
        export PROMPT='%h %n@%m[%d] %# '
        export RPROMPT='%D %T'
    else
        # see http://zsh.sunsite.dk/Doc/Release/zsh_12.html
        # see http://www.jmuk.org/diary/2007/10/21/0

        local host_colors md5cmd host_color user_color

        if [ $HOST = 'gp.ath.cx' ];
        then
            host_color="%{$fg[blue]%}"
        else
            host_color="%{$fg[green]%}"
        fi

        if [ `whoami` = root ]; then
            user_color="%{$fg_bold[red]%}"
        else
            user_color="%{$fg[yellow]%}"
        fi

        export PROMPT="$user_color%n%{$reset_color%}%{$fg[green]%}@%{$host_color%}%m%{$reset_color%}%% "
      	export RPROMPT='%{[33m%}[%(5~,%-2~/.../%2~,%~)] %w %T%{$reset_color%}'
    fi
}
set_prompt


# -------------------------------------------------------------------------
# エディタとかページャとか
#
# -------------------------------------------------------------------------
export	EDITOR=vim
alias	vi=vim

function unisync () {
    # unison -batch -times ~/share/dotfiles ssh://gp.ath.cx//home/tokuhirom/share/dotfiles/
    unison -batch -times ~/share/howm ssh://gp.ath.cx//home/tokuhirom/share/howm/
}

function unisync_local () {
    # unison -batch -times ~/share/dotfiles ssh://192.168.1.3//home/tokuhirom/share/dotfiles/
    unison -batch -times ~/share/howm ssh://192.168.1.3//home/tokuhirom/share/howm/
}

function random () {
    perl -le 'use Time::HiRes qw/gettimeofday/;use Digest::MD5 qw/md5_hex/; print md5_hex(rand().gettimeofday())';
}

export GISTY_DIR=$HOME/dev/gists/

if [ -x /usr/bin/keychain ]; then
    keychain --quiet id_rsa
    . $HOME/.keychain/$HOST-sh
fi

# =========================================================================
# followings are settings for some sucky operating systems
#
# =========================================================================

# for FreeBSD.
if [ -e '/usr/local/bin/gls' ]; then
	alias ls='\gls --color'
fi

# -------------------------------------------------------------------------
# for osx

export PERL_BADLANG=0

if [ -e "/usr/local/screen_sessions/" ];
then
    export SCREENDIR=/usr/local/screen_sessions/
fi

if [ -e "/usr/X11/bin/" ];
then
    export PATH="/usr/X11/bin/:$PATH"
fi

function isight () {
    TMPL=$HOME/share/isight/%Y/%m/%d
    BASE=`/usr/local/bin/date +$TMPL`
    FILE=`/usr/local/bin/date +$BASE/%H.%M.%S.jpg`
    mkdir -p $BASE
    /usr/local/bin/isightcapture $FILE 
    open $FILE
}

function minicpan_get () {
    perl `which minicpan` -r http://cpan.yahoo.com/ -l ~/share/minicpan
}

if [ `pwd` = '/' ];
then
    cd $HOME
fi

function clone_coderepos {
    git svn clone -s http://svn.coderepos.org/share/$1
}

if [ -f ~/.zshrc-secret ];
then
    source ~/.zshrc-secret
fi

function today() {
    local WORK DATE TODAY
    WORK=$HOME/tmp
    DATE=`date +%Y%m%d`
    TODAY=$WORK/$DATE

    mkdir -p $TODAY
    cd $TODAY
}
function nytprofgp() {
    nytprofhtml
    rm -rf rm -rf /usr/local/webapp/tmp/tmp/nytprof
    mv nytprof /usr/local/webapp/tmp/tmp/
    echo "http://64p.org/tmp/nytprof/index.html"
}


if [ -d ~/public_html/ ]
then
    function nytsetup {
        nytprofhtml; rm -rf ~/public_html/tmp/nytprof; mv nytprof/ ~/public_html/tmp/
    }
fi

function hok_foo () {
    gdb --args $*
}
function hok () {
    echo "run\nbt" | hok_foo $*
}

function perlconf() {
    perl -e 'use Config; use Data::Dumper; print Dumper(\%Config)'|lv 
}
function rfc() {
    lv "$HOME/share/docs/my-rfc-mirror/rfc$1.txt"
}
function git-ignore-elf() {
    perl -E 'use Path::Class;dir(".")->recurse(callback => sub { return if -f !$_[0] || $_[0] =~ /\.o$/;$f=file($_[0])->openr() or return;$f->read(my $buf, 4); say "$_[0]" if substr($buf,1,3) eq "ELF"; })' >> .gitignore
}

export PERL_AUTOINSTALL="--defaultdeps"

function google() {
    w3m http://google.com
}

function httpstatus() {perl -MHTTP::Status -e '$x=shift;print "$x ".status_message($x),$/' $*}
function daemonstat() {
    sudo perl -e '$prefix = -d "/command/" ? "/command/" : "";for (</service/*>) { $_=`${prefix}svstat $_`;s!/service/(.+?): (.+?\) )(\d+) seconds!sprintf "%-10s %-15s %3ddays %02d:%02d:%02d $3", $1, $2, $3/60/60/24,($3/60/60)%24, ($3/60)%60, $3%60!e;print }'
}
# ~/dev/ 以下を最新にする
function devfetch() {
    perl -e 'for (<~/dev/*>) { next unless -d "$_/.git/"; chdir $_; system q/git fetch/ }'
}
function devcheck() {
    perl -MFile::Basename=basename -e 'for (<~/dev/*>) { next unless -d "$_/.git/"; chdir $_; $x =  `git status 2> /dev/null`; $b=basename($_);print "$b: Changed\n" if $x=~/Changed/; print  "$b: $1\n" if $x=~/(Your branch is ahead of .+\.)/; }'
}
alias e="emacsclient -t"
alias v="vim"
alias u="cd ../"
alias uu="cd ../../"
alias uuu="cd ../../../"
alias uuuu="cd ../../../../"

# on OSX
if [ -d /Users/tokuhrom/ ]; then
    function reload_chrome() {
        osascript -e tell application "Google Chrome" to reload active tab of window 1
    }
fi

function totalprocsize() {
    sudo perl -le 'for (@ARGV){open F,"</proc/$_/smaps" or die $!;map{/^Pss:\s*(\d+)/i and $s+=$1}<F>}printf "%.1f[MB]\n", ($s/1024.0)' `pgrep -f $1`
}
function alc() {
    if [ $# != 0 ]; then
        w3m "http://eow.alc.co.jp/$*/UTF-8/?ref=sa" | less +38
    else
        echo 'usage: alc word'
    fi
}
alias pd=perldoc
alias cpanmf="cpanm --mirror http://cpan.cpantesters.org/"

if [ -f $HOME/perl5/perlbrew/etc/bashrc ]; then
    source $HOME/perl5/perlbrew/etc/bashrc
fi

if [ -d $HOME/perl5/perlbrew/perls/current/bin/ ]; then
    export PATH=$HOME/perl5/perlbrew/perls/current/bin/:$PATH
fi

function ctags_perl () {
    ctags -R lib -h ".pm" --exclude=blib --exclude=.svn --languages=Perl --langmap=Perl:+.t
}

function gh_sync() {
    gh all tokuhirom --into ~/dev/ --ssh
}

if [ -d /usr/local/lib/node/ ]; then
    export NODE_PATH=/usr/local/lib/node/:$PATH
fi

if [ -d /usr/local/share/npm/bin ]; then
    export PATH=/usr/local/share/npm/bin/:$PATH
fi
