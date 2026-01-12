#!/bin/bash
#
# Can enable check to enable keychain
# I've disabled this by default
# It only needs to run once
CHECK_KEYCHAIN_ENABLE=1
if [ $CHECK_KEYCHAIN_ENABLE -eq 0 ]
then
    USE_KEYCHAIN=$(defaults read org.gpgtools.common UseKeychain)
    if [ $USE_KEYCHAIN -eq 0 ]
    then
        defaults write org.gpgtools.common UseKeychain -bool yes
    fi
    DISABLE_KEYCHAIN=$(defaults read org.gpgtools.common DisableKeychain)
    if [ $DISABLE_KEYCHAIN -eq 1 ]
    then
        defaults write org.gpgtools.common DisableKeychain -bool no
    fi
fi

# We want to ignore confirmations for user presence
if [[ "$1" == "Confirm user presence"* ]]
then
    echo
else
    # Check if this is a yubikey request
    if [[ "$1" == *"yubikey"* ]]
    then
        # Grab the actual hash
        SHA256="MlH8j2KwL8zz71lP5Sb/fXFzR7I00UxNU8Me9DYUufw"
        PROMPT="SETDESC $1\nOPTION allow-external-password-cache\nSETKEYINFO $SHA256\nGETPIN"
    else
        # Otherwise don't include the keyinfo
        PROMPT="SETDESC $1\nGETPIN"
    fi

    echo $PROMPT > /Users/harryday/Developer/testing/ssh-out.log
    # Prompt the user for their pin
    PIN=$(echo -e $PROMPT | pinentry-mac | grep D | tr -d '\n')
    # Return the pin to ssh-agent starting after 'D '
    echo "${PIN:2}"
fi
