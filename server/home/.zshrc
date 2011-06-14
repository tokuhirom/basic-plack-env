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
autoload -U compinit
# -C: security check を無視 http://www.u-suke.org/wiki/?page=zsh%2Fcompinit
compinit -C

export PATH="/usr/local/bin/:$PATH"
export PATH="$HOME/bin:$HOME/local/bin/:$PATH"

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

function random () {
    perl -le 'use Time::HiRes qw/gettimeofday/;use Digest::MD5 qw/md5_hex/; print md5_hex(rand().gettimeofday())';
}

# =========================================================================
# followings are settings for some sucky operating systems
#
# =========================================================================

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

alias e="emacsclient -t"
alias v="vim"

function totalprocsize() {
    sudo perl -le 'for (@ARGV){open F,"</proc/$_/smaps" or die $!;map{/^Pss:\s*(\d+)/i and $s+=$1}<F>}printf "%.1f[MB]\n", ($s/1024.0)' `pgrep -f $1`
}

# perl5 specific settngs
export PERL_BADLANG=0
export PLACK_ENV=deployment
export PERL_CPANM_OPT="-n -l ~/perl5/ --no-man-pages"
export PATH="$HOME/perl5/bin:$PATH";
export PERL5OPT="-Mlib=$HOME/perl5/lib/perl5/"

