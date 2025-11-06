#!/bin/bash
msg=${1:-"update"}
folder=${2:-"airprint"}

(
    cd ~/source/homeassistant-addons/"$folder" || exit
    git add .
    git commit -m "$msg"
    git push
)
