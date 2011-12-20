#key bindings for command line editing (man zshzle)
#Get back emacs search commands
bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward

#AWESOME...
#pushes current command on command stack
#and gives blank line, after that line runes
#command stack is popped
bindkey "^t" push-line-or-edit

#Map ctrl-u and ctrl-k to be like emacs mode
bindkey "^U" kill-whole-line
bindkey "^K" kill-line

# helps debug completion problems, F2
bindkey "^[OQ" _complete_debug

# bind v in vi command mode to open current command in the $EDITOR
autoload edit-command-line
zle -N edit-command-line

# bind v in vi cmd mode to edit the current command in vim
bindkey -M vicmd v edit-command-line
setopt AUTO_CD    #if you type in a directory and hit enter, cd there
setopt AUTO_PUSHD #cd pushes directories on to the stack

#Setting to fix bad settings in global zshrc
#Do not autocorrect on enter, I don't like that much correction
setopt NO_CORRECT_ALL 

#Prompt
# the cool thing about these prompt settings is that they make your command line
# entries appear blue, but everything else stays the same.  Zany!
# 
# Also switches between blue and red depending on the exit code of the last command.

# auto-quote special shell characters as you type a URL, so that you don't have
# to single quote it
#
# we have to jump through some hoops here in case this isn't found
unfunction url-quote-magic >& /dev/null
if autoload +X url-quote-magic 2> /dev/null; then
  # we successfully loaded the url-quote-magic function
  zle -N self-insert url-quote-magic
fi

########### This section tries to display i or c for insert and command code
########### in the prompt... unfortunately it clears the color state for last executed
########### command... I think this could be fixed with precmd or something, not sure...
#setopt prompt_subst
#VIMODE=" i"
##REAL_PS1='%B%n%b@%U%m%u${VIMODE}%(!.#.>) '
##PS1=${REAL_PS1}
#bindkey -v
#function zle-line-init() {
# # Must match the VIMODE initial value above.
#  zle -K viins
#} #zle -N zle-line-init
#
## Show insert/command mode in vi.
## zle-keymap-select is executed every time KEYMAP changes.
## See http://zshwiki.org/home/examples/zlewidgets for details.
#function zle-keymap-select {
# # Traditional right-hand side vi standard mode display
#  # RPS1="${${KEYMAP/vicmd/-- NORMAL --}/(main|viins)/-- INSERT --}"
#  # Shorter version on the left.
# VIMODE="${${KEYMAP/vicmd/ c}/(main|viins)/ i}"
# PROMPT=$MY_PROMPT
# zle reset-prompt
#}
#
#zle -N zle-keymap-select

# This prompt uses oh-my-zsh prompt stuff for colors and the git prompt so lets deconstruct this:
# Really useful reference for the prompt: http://www.nparikh.org/unix/prompt.php
#
# Note: using $fg_bold[color] inside a %(x.true.false) statment yields prompts
# with lines longer than the width of the terminal
#
# %(0?.%{\e[1;32m%}.%{\e[1;31m%})
#   First, lets color the first section of the prompt on the command exit of the
#   previous command %(x.true.false) is the syntax and x=? means the exit code of
#   the previous command
#   The \e[1;32m codes are colors.  1 for bold 32 or 31 for green/red
# ➜
#   Literal character, unicode.
# %*
#   Current time.  For some reason p, P, Y all don't work.  zsh seems to have
#   some alternatives that do work
# %(3L.S:$SHLVL .)
#   Check the current SHLVL, if it is greater than 2 display S:$SHLVL so I can
#   know if I'm in a sub shell
# %{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}
#   Color the prompt blue, display the git prompt that has the current branch
#   in it
# $(vi_mode_prompt_info)
#   Only set when in zle command line mode see .oh-my-zsh/plugins/vi-mode for
#   more info, displays $MODE_INDICATOR when in command mode in the prompt
# %
#   Literal character
# %{$reset_color%}'
#   Not sure what this does, but it was in the example.
PROMPT=$'%(0?.%{\e[1;32m%}.%{\e[1;31m%})➜ %* %(3L.S:$SHLVL .)%{$fg_bold[blue]%}$(git_prompt_info)%{$fg_bold[blue]%}$(vi_mode_prompt_info) %{$reset_color%}'
setopt TRANSIENT_RPROMPT # RPROMPT disappears in terminal history great for copying

MODE_INDICATOR="%{$fg_bold[red]%}vicmd>"
