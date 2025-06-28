#!/usr/bin/env bash

{ pkgs, ... }:
let
  rbw-choose = pkgs.writeShellApplication {
    name = "rbw-choose";
    runtimeInputs = with pkgs; [
      # choose-gui in ./homebrew.nix
      rbw
    ];
    text = ''
      item="$(rbw list | choose)"
      field="$(echo -e 'password\ntotp\nusername' | choose -p 'Field')"
      rbw get "$item" -f "$field" --clipboard
    '';
  };
in
{
  home.packages = [
    rbw-choose
  ];
}
