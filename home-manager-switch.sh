#!/usr/bin/env bash

set -e

cp ./home-manager/home.nix ~/.config/nixpkgs/home.nix
cp ./home-manager/dwm-config-*.patch ~/.config/nixpkgs/
home-manager switch
