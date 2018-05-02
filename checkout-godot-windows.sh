#!/bin/bash

rm -rf godot 
git clone https://github.com/godotengine/godot.git 
 
cd godot 
git config --global user.email "you@example.com" 
git config --global user.name "Your Name" 
git checkout -b 3.0 origin/3.0 || git checkout 3.0 
git branch --set-upstream-to=origin/3.0 3.0 
git reset --hard 
git pull
