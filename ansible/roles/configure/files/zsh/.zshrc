# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"
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

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
