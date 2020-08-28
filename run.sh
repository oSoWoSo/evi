#!/bin/bash
sudo xbps-install -Sy git
mkdir ~/bin
git clone https://gitlab.com/awesome-void/install ~/bin/install
cd ~/bin/install
chmod +x install.sh
./install.sh -l 2>&1 | tee installed.txt
