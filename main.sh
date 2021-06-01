#!/usr/bin/env bash

if [ "$#" -ne 1 ]; then
  exit 1
fi

encryption_key="$1"

if [[ ! -f "$PRIVATE_KEY_PATH.enc" ]]; then
  echo -e "\
The encrypted private key not found. Please include it by running:
  $ ssh-keygen -t rsa -b 4096 -f \"$PRIVATE_KEY_PATH\" -C \"<email_address>\" -N \"\"
  $ openssl aes-256-cbc -in \"$PRIVATE_KEY_PATH\" -out \"$PRIVATE_KEY_PATH.enc\" -pass pass:<encryption_key> -e -pbkdf2

Hints:
1. generate an encryption key by running:
  $ pwgen 32 1
2. set the encryption key in GitHub Secrets.
3. set the public key in the repository's Deploy keys.
4. add unencrypted keys in .gitignore."

  exit 1
fi

openssl aes-256-cbc -in "$PRIVATE_KEY_PATH.enc" -out "$PRIVATE_KEY_PATH" -pass pass:$encryption_key -d -pbkdf2
mkdir -p ~/.ssh
ssh-keyscan github.com >>~/.ssh/known_hosts
ssh-agent -a "$SSH_AUTH_SOCK" >/dev/null
chmod 0600 "$PRIVATE_KEY_PATH"
ssh-add "$PRIVATE_KEY_PATH"
