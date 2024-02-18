# General
setopt NO_BEEP CLOBBER
setopt HIST_SAVE_NO_DUPS

if (( $+commands[starship] )); then
  eval "$(starship init zsh)"
else
  # Prompt
  setopt PROMPT_SUBST
  autoload -Uz promptinit; promptinit; prompt pure;
fi

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi

if (( $+commands[fzf] )); then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# Aliases
source $HOME/.aliases
