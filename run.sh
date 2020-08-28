#!/bin/bash
chmod +x install.sh
./install.sh -l 2>&1 | tee installed.txt
