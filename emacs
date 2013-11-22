#!/bin/zsh

# Created by rejuvyesh <mail@rejuvyesh.com>
# Modified from muflax <mail@muflax.com>

eclient=$(which emacsclient)
emacs=$(which emacs)
vim=$(which vim)

if [[ ${0:t} == "emacs-gui" ]]; then
    argclient=("-c" "-n")
    argemacs=""
else
    argclient="-nw"
    argemacs="-nw"
fi

# use the daemon if it exists, but fall back on a stand-alone emacs, or vim/vi on crappy systems
if [[ -e $eclient ]]; then
    if [[ -e $emacs ]]; then
        emacsclient $argclient --alternate-editor="emacs $argemacs" $*
    else
        if [[ -e $vim ]]; then
            emacsclient $argclient --alternate-editor='vim' $*
        else
            emacsclient $argclient --alternate-editor='vi' $*
        fi
    fi
else
    if [[ -e $emacs ]]; then
        emacs $argemacs $* &!
    else
        if [[ -e $vim ]]; then
            vim $*
        else
            vi $*
        fi
    fi
fi
