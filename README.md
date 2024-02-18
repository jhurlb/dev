# All Together
![All Together](https://raw.githubusercontent.com/jhurlb/dev/main/ansible/roles/configure/files/img/Screenshot-Everything.png)

# Wallpaper
![Astronaut Jellyfish](https://raw.githubusercontent.com/jhurlb/dev/main/ansible/roles/configure/files/img/astronaut_jellyfish.jpg)

# iTerm2
![iTerm2](https://raw.githubusercontent.com/jhurlb/dev/main/ansible/roles/configure/files/img/Screenshot-iTerm2.png)

# VSCode
![VSCode](https://raw.githubusercontent.com/jhurlb/dev/main/ansible/roles/configure/files/img/Screenshot-VSCode.png)

# Useful

## Export Extensions
`code --list-extensions > vscode/extensions.txt`

## Remove everything installed via brew
```shell
brew remove --force $(brew list --formula)
brew remove --cask --force $(brew list)
```

## Remove Iterm2 Fully
```shell
defaults delete com.googlecode.iterm2
rm ~/Library/Preferences/com.googlecode.iterm2.plist
rm -r "~/Library/Application Support/iTerm2"
brew uninstall iterm2
```

## Remove VSCode Fully
```shell
rm -r "$HOME/Library/Application Support/Code" "$HOME/.vscode"
which code && sudo rm -r "$(which code)"
brew list visual-studio-code || rm -r "/Applications/Visual Studio Code.app"
brew list visual-studio-code && brew uninstall visual-studio-code
```
