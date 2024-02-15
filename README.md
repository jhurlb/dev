# VSCode Helpful Commands

### Export Extensions
`code --list-extensions > vscode/extensions.txt`

# Clean Uninstalls

### Remove everything installed via brew
```shell
brew remove --force $(brew list --formula)
brew remove --cask --force $(brew list)
```

### Remove Iterm2 Fully
```shell
defaults delete com.googlecode.iterm2
rm ~/Library/Preferences/com.googlecode.iterm2.plist
rm -r "~/Library/Application Support/iTerm2"
brew uninstall iterm2
```

### Remove VSCode Fully
```shell
rm -r "$HOME/Library/Application Support/Code" "~/.vscode"
brew uninstall visual-studio-code
```

# Using GPG
_credit to https://gist.github.com/troyfontaine/18c9146295168ee9ca2b30c00bd1b41e_
 

## Step 1: Install software
We use the Homebrew package manager for this step.
    
    brew install gpg2 gnupg pinentry-mac       

## Step 2: Create the .gnupg Directory
If this directory does not exist, create it.  EDIT: June 2022 - Fixes single quotes to allow expansion of the subshell
    
    # Make the directory
    mkdir ~/.gnupg

    # Tells GPG which pinentry program to use
    echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" > ~/.gnupg/gpg-agent.conf

## Step 3: Update or Create ~/.gnupg/gpg.conf
If this file does not exist, create it.
    
    # This tells gpg to use the gpg-agent
    echo 'use-agent' > ~/.gnupg/gpg.conf
    
## Step 4: Modify your Shell
Append the following to your ~/.bash_profile or ~/.bashrc or ~/.zshrc
    
    ...
    export GPG_TTY=$(tty)

## Step 5: Restart your Terminal or source your ~/.*rc file

    # on the built-in bash on macos use
    source ~/.bash_profile
    # if using bash through homebrew over ssh use
    source ~/.bashrc
    # and if using zsh
    source ~/.zshrc

## Step 6: Update the Permissions on your ~/.gnupg Directory
You will need to modify the permissions to 700 to secure this directory.  

    chmod 700 ~/.gnupg

## Step 7: Kill the GPG Agent
To ensure that you don't run into issues, run the below command to ensure a freshly configured gpg-agent is launched.

    killall gpg-agent

## Step 8: Create your GPG Key
Run the following command to generate your key, note we have to use the `--expert` flag so as to generate a 4096-bit key.  If you receive a timeout at this step-please go back and verify that you did run the command in Step 7.  Otherwise, go back and double check that you followed the preceding steps.
    
    gpg --full-gen-key

## Step 9: Answer the Questions
Once you have entered your options, pinentry will prompt you for a password for the new PGP key.  There are a number of arguments on the topic of expiration dates with GPG Keys, for brevity and the sake of keeping this explanation simple we're not using Subkeys in this example and showing a non-expiring example.  If you want to follow best practices, you will want to look into generating a Primary key and then Subkeys and the secure handling involved with that.
    
    Please select what kind of key you want:
       (1) RSA and RSA (default)
       (2) DSA and Elgamal
       (3) DSA (sign only)
       (4) RSA (sign only)
    Your selection? 4
    RSA keys may be between 1024 and 4096 bits long.
    What keysize do you want? (2048) 4096
    Requested keysize is 4096 bits
    Please specify how long the key should be valid.
             0 = key does not expire
          <n>  = key expires in n days
          <n>w = key expires in n weeks
          <n>m = key expires in n months
          <n>y = key expires in n years
    Key is valid for? (0) 0
    Key does not expire at all
    Is this correct? (y/N) y

    You need a user ID to identify your key; the software constructs the user ID
    from the Real Name, Comment and Email Address in this form:
        "Heinrich Heine (Der Dichter) <heinrichh@duesseldorf.de>"

    Real name: John Smith
    Email address: john.smith@fictionaladdress.com
    Comment:
    You selected this USER-ID:
        "John Smith <john.smith@fictionaladdress.com>"

    Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
    You need a Passphrase to protect your secret key.
    
## Step 10: Get your key info for Git, etc.

    # List your keys
    gpg -k

## Step 11: Get your key id
Use the next command to generate a short form of the key fingerprint.

Copy the text after the `rsa4096/` and before the date generated and use the copied id in step 13:  

    gpg -K --keyid-format SHORT
    sec rsa4096/######## YYYY-MM-DD [SC] [expires: YYYY-MM-DD]
    
*You need to copy the output from your terminal similar to the example above where the ######## is following the slash. *

## Step 12: Export the fingerprint
After running `gpg -k` step 10 above, looking inside the output, below the row that says 'pub', you will find a fingerprint-this is what you use in the <your key id> placeholder.  The output from below is what you copy to Github.  Documentation on how to do that is [here](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-new-gpg-key-to-your-github-account)

    # The export command below gives you the key you add to GitHub
    gpg --armor --export <your key id>
    
## Step 13: Configure Git to use gpg
    
    git config --global gpg.program $(which gpg)

## Step 14: Configure Git to use your signing key
The below command needs the fingerprint from step 10 above:  

    git config --global user.signingkey 1111111

## Step 15: Configure Git to sign all commits (Optional-you can configure this per repository too)
This tells Git to sign all commits using the key you specified in step 13.  

    git config --global commit.gpgsign true
    
## Step 16: Perform a Commit
This performs an empty commit-but lets us test signing it with GPG-thanks @rickschubert for the suggestion!

    git commit -S -s -m "My Signed Commit" --allow-empty
    
## Step 17: Pinentry Prompt
You will now be prompted by Pinentry for the password for your signing key.  You can enter it into the Dialog box-with the option of saving the password to the macOS X Keychain.

## Step 18: Submit your PGP key to Github to verify your Commits
Login into Github.com and go to your settings, SSH and GPG Keys, and add your GPG key from the page.

## Step 19: Submitting Your Key to a Public Keyserver (very optional)
Before you jump on submitting your key to a service such as the [MIT PGP Key Server](https://pgp.mit.edu), you should consider the following:
- You cannot delete your key once submitted
- Spammers have been known to harvest email addresses from these servers
- If you're only signing your Git commits to Github this isn't necessary

# Import existing keys from another system (Optional)

If you already have set up GPG keys on a previous Mac, or elsewhere, you can re-use them by exporting them from that host by following the steps below (Special thanks to [@megahirt](https://gist.github.com/megahirt) for the suggestion).  Please note: keep in mind the method that you use to transfer your GPG keys!  Because of the sensitive nature of GPG keys, you will want to ensure that you use a highly secured means of transferring them.  I won't suggest a specific method as it is outside of the scope of this Gist-but be paranoid is what I can say.

## Step 8a: Export the GPG Key Materials

On the host you want to move/duplicate the keys from, run the following and then copy the resulting files to your "new" host.  Substitute your key's keyid for the ${ID} in the example.  You will be prompted to enter the passphrase you set during the generation of the key to export the private key.
    
    gpg --export ${ID} > my_key_public.key
    gpg --export-secret-key ${ID} > my_key_private.key

## Step 9a: Import the GPG Key Materials

On the host you want to import the keys, move them to an accessible location and then run the following commands from that folder.  When you go to import the private key, you will be prompted for the password you specified when you generated/exported it.
    
    gpg --import my_key_public.key
    gpg --import my_key_private.key

# Troubleshooting

## Error No pinentry

This is caused by an incorrectly configured pinentry program.  Review Step 2 and complete the second part again.
    
## Error No such file or directory

This is caused by a missing configuration to specify the pinentry program.  If you were following an earlier version of this gist that said you did not need to specify a pinentry program, you will need to re-do the second part of Step 2.
    
## Other Errors
If you have any errors when generating a key regarding gpg-agent, try the following command to see what error it generates:

    gpg-agent --daemon


## VSCode Helpful Commands

### Export Extensions
`code --list-extensions > vscode/extensions.txt`

## Clean Uninstalls

### Remove everything installed via brew
```shell
brew remove --force $(brew list --formula)
brew remove --cask --force $(brew list)
```

### Remove Iterm2 Fully
```shell
defaults delete com.googlecode.iterm2
rm ~/Library/Preferences/com.googlecode.iterm2.plist
rm -r "~/Library/Application Support/iTerm2"
brew uninstall iterm2
```

### Remove VSCode Fully
```shell
rm -r "$HOME/Library/Application Support/Code" "~/.vscode"
brew uninstall visual-studio-code
```

# Using GPG __credit to https://gist.github.com/troyfontaine/18c9146295168ee9ca2b30c00bd1b41e__
 

## Step 1: Install software
We use the Homebrew package manager for this step.
    
    brew install gpg2 gnupg pinentry-mac       

## Step 2: Create the .gnupg Directory
If this directory does not exist, create it.  EDIT: June 2022 - Fixes single quotes to allow expansion of the subshell
    
    # Make the directory
    mkdir ~/.gnupg

    # Tells GPG which pinentry program to use
    echo "pinentry-program $(brew --prefix)/bin/pinentry-mac" > ~/.gnupg/gpg-agent.conf

## Step 3: Update or Create ~/.gnupg/gpg.conf
If this file does not exist, create it.
    
    # This tells gpg to use the gpg-agent
    echo 'use-agent' > ~/.gnupg/gpg.conf
    
## Step 4: Modify your Shell
Append the following to your ~/.bash_profile or ~/.bashrc or ~/.zshrc
    
    ...
    export GPG_TTY=$(tty)

## Step 5: Restart your Terminal or source your ~/.*rc file

    # on the built-in bash on macos use
    source ~/.bash_profile
    # if using bash through homebrew over ssh use
    source ~/.bashrc
    # and if using zsh
    source ~/.zshrc

## Step 6: Update the Permissions on your ~/.gnupg Directory
You will need to modify the permissions to 700 to secure this directory.  

    chmod 700 ~/.gnupg

## Step 7: Kill the GPG Agent
To ensure that you don't run into issues, run the below command to ensure a freshly configured gpg-agent is launched.

    killall gpg-agent

## Step 8: Create your GPG Key
Run the following command to generate your key, note we have to use the `--expert` flag so as to generate a 4096-bit key.  If you receive a timeout at this step-please go back and verify that you did run the command in Step 7.  Otherwise, go back and double check that you followed the preceding steps.
    
    gpg --full-gen-key

## Step 9: Answer the Questions
Once you have entered your options, pinentry will prompt you for a password for the new PGP key.  There are a number of arguments on the topic of expiration dates with GPG Keys, for brevity and the sake of keeping this explanation simple we're not using Subkeys in this example and showing a non-expiring example.  If you want to follow best practices, you will want to look into generating a Primary key and then Subkeys and the secure handling involved with that.
    
    Please select what kind of key you want:
       (1) RSA and RSA (default)
       (2) DSA and Elgamal
       (3) DSA (sign only)
       (4) RSA (sign only)
    Your selection? 4
    RSA keys may be between 1024 and 4096 bits long.
    What keysize do you want? (2048) 4096
    Requested keysize is 4096 bits
    Please specify how long the key should be valid.
             0 = key does not expire
          <n>  = key expires in n days
          <n>w = key expires in n weeks
          <n>m = key expires in n months
          <n>y = key expires in n years
    Key is valid for? (0) 0
    Key does not expire at all
    Is this correct? (y/N) y

    You need a user ID to identify your key; the software constructs the user ID
    from the Real Name, Comment and Email Address in this form:
        "Heinrich Heine (Der Dichter) <heinrichh@duesseldorf.de>"

    Real name: John Smith
    Email address: john.smith@fictionaladdress.com
    Comment:
    You selected this USER-ID:
        "John Smith <john.smith@fictionaladdress.com>"

    Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
    You need a Passphrase to protect your secret key.
    
## Step 10: Get your key info for Git, etc.

    # List your keys
    gpg -k

## Step 11: Get your key id
Use the next command to generate a short form of the key fingerprint.

Copy the text after the `rsa4096/` and before the date generated and use the copied id in step 13:  

    gpg -K --keyid-format SHORT
    sec rsa4096/######## YYYY-MM-DD [SC] [expires: YYYY-MM-DD]
    
*You need to copy the output from your terminal similar to the example above where the ######## is following the slash. *

## Step 12: Export the fingerprint
After running `gpg -k` step 10 above, looking inside the output, below the row that says 'pub', you will find a fingerprint-this is what you use in the <your key id> placeholder.  The output from below is what you copy to Github.  Documentation on how to do that is [here](https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-new-gpg-key-to-your-github-account)

    # The export command below gives you the key you add to GitHub
    gpg --armor --export <your key id>
    
## Step 13: Configure Git to use gpg
    
    git config --global gpg.program $(which gpg)

## Step 14: Configure Git to use your signing key
The below command needs the fingerprint from step 10 above:  

    git config --global user.signingkey 1111111

## Step 15: Configure Git to sign all commits (Optional-you can configure this per repository too)
This tells Git to sign all commits using the key you specified in step 13.  

    git config --global commit.gpgsign true
    
## Step 16: Perform a Commit
This performs an empty commit-but lets us test signing it with GPG-thanks @rickschubert for the suggestion!

    git commit -S -s -m "My Signed Commit" --allow-empty
    
## Step 17: Pinentry Prompt
You will now be prompted by Pinentry for the password for your signing key.  You can enter it into the Dialog box-with the option of saving the password to the macOS X Keychain.

## Step 18: Submit your PGP key to Github to verify your Commits
Login into Github.com and go to your settings, SSH and GPG Keys, and add your GPG key from the page.

## Step 19: Submitting Your Key to a Public Keyserver (very optional)
Before you jump on submitting your key to a service such as the [MIT PGP Key Server](https://pgp.mit.edu), you should consider the following:
- You cannot delete your key once submitted
- Spammers have been known to harvest email addresses from these servers
- If you're only signing your Git commits to Github this isn't necessary

# Import existing keys from another system (Optional)

If you already have set up GPG keys on a previous Mac, or elsewhere, you can re-use them by exporting them from that host by following the steps below (Special thanks to [@megahirt](https://gist.github.com/megahirt) for the suggestion).  Please note: keep in mind the method that you use to transfer your GPG keys!  Because of the sensitive nature of GPG keys, you will want to ensure that you use a highly secured means of transferring them.  I won't suggest a specific method as it is outside of the scope of this Gist-but be paranoid is what I can say.

## Step 8a: Export the GPG Key Materials

On the host you want to move/duplicate the keys from, run the following and then copy the resulting files to your "new" host.  Substitute your key's keyid for the ${ID} in the example.  You will be prompted to enter the passphrase you set during the generation of the key to export the private key.
    
    gpg --export ${ID} > my_key_public.key
    gpg --export-secret-key ${ID} > my_key_private.key

## Step 9a: Import the GPG Key Materials

On the host you want to import the keys, move them to an accessible location and then run the following commands from that folder.  When you go to import the private key, you will be prompted for the password you specified when you generated/exported it.
    
    gpg --import my_key_public.key
    gpg --import my_key_private.key

# Troubleshooting

## Error No pinentry

This is caused by an incorrectly configured pinentry program.  Review Step 2 and complete the second part again.
    
## Error No such file or directory

This is caused by a missing configuration to specify the pinentry program.  If you were following an earlier version of this gist that said you did not need to specify a pinentry program, you will need to re-do the second part of Step 2.
    
## Other Errors
If you have any errors when generating a key regarding gpg-agent, try the following command to see what error it generates:

    gpg-agent --daemon

