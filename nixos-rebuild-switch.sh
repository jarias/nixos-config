#!/usr/bin/env bash

set -e

if [ $# -eq 0 ]
  then
    echo "Usage: nixos-rebuild-switch.sh HOST"
    echo "Available hosts: $(ls -1 ./hosts)"
    exit 1
fi

sudo cp ./hosts/$1/configuration.nix /etc/nixos/configuration.nix
sudo nixos-rebuild switch
