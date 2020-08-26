#!/bin/bash
# Void Linux post-install script
echo "$(tput setaf 1)						Starting Void Linux post-install script$(tput sgr 0)"

# Install packages-----------------------------------------------------------------------------------------
sudo xbps-install -Su
sudo xbps-install -Sy $(cat INSTALL/1_repos)
sudo xbps-install -Sy $(cat INSTALL/2_base)

git config --global credential.helper store
git clone https://gitlab.com/awesome-void/awesomeVoid ~/bin/dotfiles

# Choose gpu-----------------------------------------------------------------------------------------
echo "$(tput setaf 1)						Which GPU you using?$(tput sgr 0)"
read -p "NVIDIA (n), AMD (a), INTEL (i) or QEMU (q)      [n/a/i/q] " -n 1 video
echo
    if [[ $video = "n" ]]; then
        sudo xbps-install -Sy $(cat INSTALL/3_nvidia)
        sudo nvidia-xconfig
        
        read -p "Want install PCI passthrough? NO (n) or YES (y)      [n/y] " -n 1 pass
        echo
            if [[ $pass = "y" ]]; then
            modprobe kvm-amd
            chmod +x /INSTALL/pass.sh
            sudo ./INSTALL/pass.sh
        fi
    elif [[ $video = "a" ]]; then
        sudo xbps-install -Sy $(cat INSTALL/3_ati)
        modprobe kvm-amd

    elif [[ $video = "i" ]]; then
        sudo xbps-install -Sy $(cat INSTALL/3_intel)

    elif [[ $video = "q" ]]; then
        sudo xbps-install -Sy $(cat INSTALL/3_qemu)
fi
sudo xbps-install -Sy $(cat INSTALL/4_desktop)

# Choose window manager-----------------------------------------------------------------------------------------
echo "$(tput setaf 1)						Which windows manager you want use?$(tput sgr 0)"
read -p "OPENBOX (o) or AWESOME (a) or SOMETHING ELSE (s)          [o/a/s] " -n 1 vm
echo
    if [[ $vm = "o" ]]; then
        sudo xbps-install -Sy $(cat INSTALL/5_openbox)
        sudo -u $USER obmenu-generator -p -i -u -d -c
echo
"autorandr common &
tint2 &
setxkbmap cz &
nitrogen --restore &
volumeicon &
conky &" >> ~/.config/openbox/autostart
#        cp ~/bin/dotfiles/home/zen/.config/openbox/rc.xml ~/.config/openbox
    elif [[ $vm = "a" ]]; then
        sudo xbps-install -Sy $(cat INSTALL/5_awesome)

    elif [[ $vm = "s" ]]; then
        echo "$(tput setaf 1) Install something else after..$(tput sgr 0)"
fi

#sudo xbps-install -Sy $(cat INSTALL/6_media)
#sudo xbps-install -Sy $(cat INSTALL/7_virtual)
#sudo xbps-install -Sy $(cat INSTALL/8_big)

# printer support-----------------------------------------------------------------------------------------
echo "$(tput setaf 1)						Want install printer support?$(tput sgr 0)"
read -p "NO (n) or YES (y)      [n/y] " -n 1 cups
echo
    if [[ $cups = "y" ]]; then
        sudo xbps-install -Sy $(cat INSTALL/9_print)
    fi    

#sudo xbps-install -Sy $(cat INSTALL/)

# make fish base shell-----------------------------------------------------------------------------------------
sudo usermod --shell /bin/fish zen
#echo ". ~/.config/fish/aliases.fish" >> ~/.config/fish/config.fish
#echo "alias xterm 'sakura'" >> ~/.config/fish/aliases.fish

# socklog-----------------------------------------------------------------------------------------
sudo usermod -a -G socklog $USER

# čeština-----------------------------------------------------------------------------------------
sudo micro /etc/default/libc-locales
sudo xbps-reconfigure -f glibc-locales

# creating bare repository-----------------------------------------------------------------------------------------
mkdir ~/.void
cd ~/.void
git init --bare

# Share packages with void devs-----------------------------------------------------------------------------------------
echo "$(tput setaf 1)						Want share packages with void devs?$(tput sgr 0)"
read -p "NO (n) or YES (y)      [n/y] " -n 1 pop
echo
    if [[ $pop = "y" ]]; then
        sudo xbps-install -Sy popcorn
        sudo ln -s /etc/sv/popcorn /var/service
    fi 

# Install services-----------------------------------------------------------------------------------------
sudo ln -s /etc/sv/dbus /var/service
sudo ln -s /etc/sv/elogind /var/service
#sudo ln -s /etc/sv/acpid /var/service
sudo ln -s /etc/sv/socklog-unix /var/service
sudo ln -s /etc/sv/nanoklogd /var/service
sudo ln -s /etc/sv/crond /var/service
sudo ln -s /etc/sv/chronyd /var/service

echo "$(tput setaf 1)						Want run lightdm now?$(tput sgr 0)"
read -p "Run lightdm now? YES (y) or NO (n)?          [y/n] " -n 1 lightdm
echo
    if [[ $lightdm = "y" ]]; then
        sudo ln -s /etc/sv/lightdm /var/service
        echo "$(tput setaf 1)						Enjoy void linux$(tput sgr 0)"
    elif [[ $lightdm = "n" ]]; then
    sudo ln -s /etc/sv/lightdm /etc/runit/runsvdir/default/
    echo "$(tput setaf 1)						Enjoy void linux$(tput sgr 0)"
fi