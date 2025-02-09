#!/usr/bin/env bash

nix flake update
nvim --headless "+Lazy! sync" +qa
sudo nixos-rebuild switch --flake .#
