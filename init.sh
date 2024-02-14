#!/usr/bin/env bash

set -u
install_homebrew=2
install_fonts=2
install_packages=2
install_starship=2
install_iterm2=2
install_vscode=2
install_vscode_ext=2

help() {
  cat << EOF
usage: $0 [OPTIONS]

    --help              Show this message
    -y                  Yes to all prompts
    --[no-]brew         Enable/disable installation of homebrew
    --[no-]fonts        Enable/disable installation of fonts
    --[no-]packages     Enable/disable installation of packages
    --[no-]starship     Enable/disable installation of starship prompt
    --[no-]iterm2       Enable/disable installation of iterm2
    --[no-]vscode       Enable/disable installation of vscode
    --[no-]vscode-ext   Enable/disable installation of vscode extensions


EOF
}

for opt in "$@"; do
  case $opt in
    --help)
      help
      exit 0
      ;;
    -y)
      install_homebrew=1
      install_fonts=1
      install_packages=1
      install_starship=1
      install_iterm2=1
      install_vscode=1
      install_vscode_ext=1
      ;;
    --brew)           install_homebrew=1   ;;
    --no-brew)        install_homebrew=0   ;;
    --fonts)          install_fonts=1      ;;
    --no-fonts)       install_fonts=0      ;;
    --packages)       install_packages=1   ;;
    --no-packages)    install_packages=0   ;;
    --starship)       install_starship=1   ;;
    --no-starship)    install_starship=0   ;;
    --iterm2)         install_iterm2=1     ;;
    --no-iterm2)      install_iterm2=0     ;;
    --vscode)         install_vscode=1     ;;
    --no-vscode)      install_vscode=0     ;;
    --vscode-ext)     install_vscode_ext=1 ;;
    --no-vscode-ext)  install_vscode_ext=0 ;;
    *)
      echo "unknown option: $opt"
      help
      exit 1
      ;;
  esac
done

# ask a question and capture y/n
ask() {
  echo
  while true; do
    read -p "$1 ([y]/n) " -r
    REPLY=${REPLY:-"y"}
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      return 0
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
      return 1
    fi
  done
}

# check if package is installed by brew
brew_installed() {
  brew list "$1" &> /dev/null && return 0
  return 1
}

# install package with brew if not already installed
install_if_missing_brew() {
  echo -n " - Checking for '$1'..."
  if ! brew_installed "$1"; then
    echo "not found, installing..."
    brew install "$1"
  else
    echo found!
  fi
}

##############################
#         HOMEBREW           #
##############################
if [ $install_homebrew -eq 2 ]; then
  ask "Install homebrew?"
  install_homebrew=$?
fi
if [ $install_homebrew -eq 1 ]; then
  echo -n " - Checking for 'brew'..."
  if ! command -v brew &> /dev/null
  then
    echo "not found, installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo found!
  fi
fi

##############################
#         NERD FONTS         #
##############################
if [ $install_fonts -eq 2 ]; then
  ask "Install fonts?"
  install_fonts=$?
fi
if [ $install_fonts -eq 1 ]; then
  brew tap homebrew/cask-fonts
  install_if_missing_brew font-hack-nerd-font
  # if ! brew_installed "font-hack-nerd-font"; then
  #   echo "not found, installing..."
  #   brew tap homebrew/cask-fonts
  #   brew install font-hack-nerd-font
  # else
  #   echo found!
  # fi
fi

##############################
#          PACKAGES          #
##############################
if [ $install_packages -eq 2 ]; then
  ask "Install packages?"
  install_packages=$?
fi
if [ $install_packages -eq 1 ]; then
  declare -a arr=("git" "eza" "bat" "rg" "fzf")
  for i in "${arr[@]}"
  do
    echo
    echo -n " - Checking for '$i'..."
    if ! command -v "$i" &> /dev/null
    then
      echo "not found, installing..."
      # ripgrep is rg
      if [ "$i" == "rg" ]; then
        brew install "ripgrep"
      else
        brew install "$i"
      fi

      # configure fzf for zsh
      if [ "$i" == "fzf" ]; then
        echo
        echo " - Configuring fzf for zsh..."
        "$(brew --prefix)/opt/fzf/install --completion --no-key-bindings --update-rc --no-bash --no-fish"
      fi
    else
      echo found!
    fi
  done
fi

##############################
#      STARSHIP  PROMPT      #
##############################
if [ $install_starship -eq 2 ]; then
  ask "Install starship prompt?"
  install_starship=$?
fi
if [ $install_starship -eq 1 ]; then
  echo
  install_if_missing_brew starship
  # echo -n " - Checking for 'Starship Prompt'..."
  # if ! brew_installed starshipe; then
  #   echo "not found, installing..."
  #   brew install starship
  # else
  #   echo "found!"
  # fi
  echo
  echo " - Configuring..."
  home_config_dir="$HOME/.config"
  if ! test -d "$home_config_dir"; then
    echo "- Creating $home_config_dir..."
    mkdir "$home_config_dir"
  fi
  echo -n " - Symlinking 'starship.toml' to '$home_config_dir/'..."
  ln -sf "$PWD/config/starship.toml" "$home_config_dir/starship.toml"
  echo "done!"
fi

##############################
#           ITERM2           #
##############################
if [ $install_iterm2 -eq 2 ]; then
  ask "Install iterm2?"
  install_iterm2=$?
fi
if [ $install_iterm2 -eq 1 ]; then
  install_if_missing_brew iterm2
  # echo -n " - Checking for 'iterm2'..."
  # if ! brew_installed "iterm2"; then
  #   echo "not found, installing..."
  #   brew install iterm2
  # else
  #   echo found!
  # fi
  iterm2_config_dir="$HOME/Library/Application Support/iTerm2/DynamicProfiles/Gibson.json"
  echo
  echo " - Configuring..."
  echo -n " - Symlinking 'Profiles.json' to '$iterm2_config_dir'..."
  ln -sf "$PWD/iterm2/Profiles.json" "$iterm2_config_dir"
  echo "done!"
  echo -n " - Writing iterm configs..."
  defaults write com.googlecode.iterm2 'PrefsCustomFolder' -string "$PWD/iterm2/"
  defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder true
  defaults write com.googlecode.iterm2 SaveChanges -string 'Automatically'
  echo "done!"
fi

##############################
#     VISUAL STUDIO CODE     #
##############################
if [ $install_vscode -eq 2 ]; then
  ask "Install vscode?"
  install_vscode=$?
fi
if [ $install_vscode -eq 1 ]; then
  install_if_missing_brew visual-studio-code
  echo
  echo " - Configuring..."
  vscode_conf_dir="$HOME/Library/Application Support/Code/User/"
  if test -d "$vscode_conf_dir"; then
    echo -n " - Symlinking vscode 'settings.json' to '$vscode_conf_dir'..."
    ln -sf "$PWD/vscode/settings.json" "$vscode_conf_dir"
    echo "done!"
  else
    echo "ERROR: Could not find vscode config path: $vscode_conf_dir"
  fi

  if [ $install_vscode_ext -eq 2 ]; then
    ask "Install vscode extensions?"
    install_vscode_ext=$?
  fi
  if [ $install_vscode_ext -eq 1 ]; then
    cat vscode/extensions.txt | while read -r extension || [[ -n $extension ]];
    do
      code --install-extension "$extension" --force
    done
  fi
fi

##############################
#            ZSH             #
##############################
echo
echo -n " - Symlinking '.zshrc' and '.aliases' in '$HOME/'..."
ln -sf "$PWD/zsh/.zshrc" ~/.zshrc
ln -sf "$PWD/zsh/.aliases" ~/.aliases
echo "done!"

echo
echo
echo "!RELOAD TERMINAL!"
echo
echo
