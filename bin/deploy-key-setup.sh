#!/usr/bin/env bash
echo "Host github.com-utils Hostname github.com IdentityFile=/keys/id_ecsda-gh-MARTe2-utils" >> $HOME/.ssh/config
git config --global user.name "Real User (via docker+key)"
git config --global user.email "real.user@real.domain"
