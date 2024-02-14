# brew
export PATH=$HOME/bin:/usr/local/bin:$PATH

# --- prompt
setopt PROMPT_SUBST
PROMPT='%F{green}%*%f %F{blue}%~%f$ '

# -- compinit
autoload -Uz compinit
compinit -C

# --- aliases
source $HOME/.aliases

# --- inits
if command -v starship &> /dev/null
then
  eval "$(starship init zsh)"
fi

if command -v zoxide &> /dev/null
then
  eval "$(zoxide init zsh)"
fi

if command -v fzf &> /dev/null
then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi
