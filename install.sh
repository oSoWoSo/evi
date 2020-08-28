#!/bin/bash
# Void Linux post-install script
echo "$(tput setaf 3)Starting Void Linux post-install script$(tput sgr 0)"

# Ask part
echo "$(tput setaf 1)Which CPU do you use?$(tput sgr 0)"
read -p "AMD (a) or INTEL (i)	[a/i] " -n 1 cpu
echo
echo "$(tput setaf 1)Which GPU do you use?$(tput sgr 0)"
read -p "NVIDIA (n), AMD (a), INTEL (i) or QEMU (q)	[n/a/i/q] " -n 1 video
echo
echo "$(tput setaf 1)Do you want to install PCI passthrough?$(tput sgr 0)"
read -p "NO (n) or YES (y)	[n/y] " -n 1 pass
echo
echo "$(tput setaf 1)Which window manager do you want to use?$(tput sgr 0)"
read -p "OPENBOX (o) or AWESOME (a) or SOMETHING ELSE (s)	[o/a/s] " -n 1 vm
echo
echo "$(tput setaf 1)Do you want to install printer support?$(tput sgr 0)"
read -p "NO (n) or YES (y)	[n/y] " -n 1 cups
echo
echo "$(tput setaf 1)Do you want to share package statistics with void devs?$(tput sgr 0)"
read -p "NO (n) or YES (y)	[n/y] " -n 1 pop
echo
echo "$(tput setaf 1)Unncomment desired language(s) $(tput sgr 0)"
sleep 3
sudo micro /etc/default/libc-locales

# Prerequisities-----------------------------------------------------------------------------------------
# Freshly installed base system
# Script will inastall rest..
# git
# And clone this repository

sudo xbps-install -Sy git
mkdir ~/bin
git clone https://gitlab.com/awesome-void/install ~/bin/install
cd ~/bin/install

# Install packages-----------------------------------------------------------------------------------------
# Nonfree and multilib repos
sudo xbps-install -y $(cat INSTALL/1_repos)
sudo xbps-install -Sy $(cat INSTALL/2_base)

# Remember git login information?
#git config --global credential.helper store
# Clone also personal dotfiles from gitlab? 
#git clone https://gitlab.com/awesome-void/awesomeVoid ~/bin/dotfiles

# Choose cpu-----------------------------------------------------------------------------------------
    if [[ $cpu = "a" ]]; then
		echo amd
		if [[ $video = "n" ]]; then
		echo amd nvidia
		sudo xbps-install -y $(cat INSTALL/3_nvidia)
        sudo nvidia-xconfig
			if [[ $pass = "y" ]]; then
			echo amd nvidia yes
			modprobe kvm-amd
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
			fi
		elif [[ $video = "a" ]]; then	
			echo amd amd
			if [[ $pass = "y" ]]; then
			echo amd amd yes
			modprobe kvm-amd
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
			fi
        elif [[ $video = "i" ]]; then	
			echo amd intel
			if [[ $pass = "y" ]]; then
			echo amd intel yes
			modprobe kvm-amd
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
			fi
		elif [[ $video = "q" ]]; then
			echo amd qemu
			sudo xbps-install -y $(cat INSTALL/3_qemu)
		  fi
		     
    elif [[ $cpu = "i" ]]; then
		echo intel
		if [[ $video = "n" ]]; then
		echo intel nvidia
		sudo xbps-install -y $(cat INSTALL/3_nvidia)
        sudo nvidia-xconfig
			if [[ $pass = "y" ]]; then
			echo intel nvidia yes
			modprobe kvm-intel
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
			fi
		elif [[ $video = "a" ]]; then	
			echo intel amd
			if [[ $pass = "y" ]]; then
			echo intel amd yes
			modprobe kvm-intel
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
			fi
        elif [[ $video = "i" ]]; then	
			echo intel intel
			if [[ $pass = "y" ]]; then
			echo intel intel yes
			modprobe kvm-intel
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
			fi
		elif [[ $video = "q" ]]; then
			echo intel qemu
#			sudo xbps-install -y $(cat INSTALL/3_qemu)
		  fi
fi

# Choose gpu-----------------------------------------------------------------------------------------
#    if [[ $video = "n" ]]; then
#        sudo xbps-install -y $(cat INSTALL/3_nvidia)
#        sudo nvidia-xconfig
#            if [[ $pass = "y" ]]; then
#            modprobe kvm-amd
#            sudo cp -r /OVMF /usr/share/ovmf
#            chmod +x /INSTALL/pass.sh
#            sudo ./INSTALL/pass.sh
#        fi
#    elif [[ $video = "a" ]]; then
#        sudo xbps-install -y $(cat INSTALL/3_ati)
#        modprobe kvm-amd
#    elif [[ $video = "i" ]]; then
#        sudo xbps-install -y $(cat INSTALL/3_intel)
#
#    elif [[ $video = "q" ]]; then
#        sudo xbps-install -y $(cat INSTALL/3_qemu)
#fi

# Choose window manager-----------------------------------------------------------------------------------------
    if [[ $vm = "o" ]]; then
        sudo xbps-install -y $(cat INSTALL/4_desktop)
        sudo xbps-install -y $(cat INSTALL/5_openbox)
        sudo -u $USER obmenu-generator -p -i -u -d -c
		echo "autorandr common &
		tint2 &
		setxkbmap cz &
		nitrogen --restore &
		volumeicon &
		conky &" >> ~/.config/openbox/autostart
#        cp ~/bin/dotfiles/home/zen/.config/openbox/rc.xml ~/.config/openbox
    elif [[ $vm = "a" ]]; then
		echo awesome
        sudo xbps-install -y $(cat INSTALL/4_desktop)
        sudo xbps-install -y $(cat INSTALL/5_awesome)
	  fi

sudo xbps-install -Sy $(cat INSTALL/6_media)
#sudo xbps-install -Sy $(cat INSTALL/7_virtual)
#sudo xbps-install -Sy $(cat INSTALL/8_big)
#sudo xbps-install -Sy $(cat INSTALL/)

# printer support-----------------------------------------------------------------------------------------
    if [[ $cups = "y" ]]; then
        sudo xbps-install -y $(cat INSTALL/9_print)
        sudo ln -s /etc/sv/cupsd /var/service
    fi    

# make fish base shell-----------------------------------------------------------------------------------------
sudo usermod --shell /bin/fish $USER
#echo ". ~/.config/fish/aliases.fish" >> ~/.config/fish/config.fish
#echo "alias xterm 'sakura'" >> ~/.config/fish/aliases.fish

# socklog-----------------------------------------------------------------------------------------
sudo usermod -a -G socklog $USER

# čeština-----------------------------------------------------------------------------------------
sudo xbps-reconfigure -f glibc-locales

# creating bare repository-----------------------------------------------------------------------------------------
mkdir ~/.void
cd ~/.void
git init --bare

# Share packages with void devs-----------------------------------------------------------------------------------------
    if [[ $pop = "y" ]]; then
        sudo xbps-install -y PopCorn
        sudo ln -s /etc/sv/popcorn /var/service/
    fi 

# Install services-----------------------------------------------------------------------------------------
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/elogind /var/service/
#sudo ln -s /etc/sv/acpid /var/service/
sudo ln -s /etc/sv/socklog-unix /var/service/
sudo ln -s /etc/sv/nanoklogd /var/service/
sudo ln -s /etc/sv/crond /var/service/
sudo ln -s /etc/sv/chronyd /var/service/

echo "$(tput setaf 1)						Do you want to run lightdm now?$(tput sgr 0)"
read -p "Run lightdm now? YES (y) or NO (n)?          [y/n] " -n 1 lightdm
echo
    if [[ $lightdm = "y" ]]; then
        sudo ln -s /etc/sv/lightdm /var/service/
        echo "$(tput setaf 1)						Enjoy void linux$(tput sgr 0)"
fi
#sudo restart
