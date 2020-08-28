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
	echo amd CPU
	if [[ $video = "n" ]]; then
		sudo xbps-install -y $(cat INSTALL/3_nvidia)
    	sudo nvidia-xconfig
		if [[ $pass = "y" ]]; then
			modprobe kvm-amd
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
		fi
	elif [[ $video = "a" ]]; then	
		sudo xbps-install -y $(cat INSTALL/3_ati)
		if [[ $pass = "y" ]]; then
			modprobe kvm-amd
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
		fi
	elif [[ $video = "i" ]]; then	
		sudo xbps-install -y $(cat INSTALL/3_intel)
		if [[ $pass = "y" ]]; then
			modprobe kvm-amd
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
		fi
	elif [[ $video = "q" ]]; then
		sudo xbps-install -y $(cat INSTALL/3_qemu)
	fi
elif [[ $cpu = "i" ]]; then
	echo intel CPU
	if [[ $video = "n" ]]; then
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
		sudo xbps-install -y $(cat INSTALL/3_ati)
		if [[ $pass = "y" ]]; then
			echo intel amd yes
			modprobe kvm-intel
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
		fi
    elif [[ $video = "i" ]]; then	
		sudo xbps-install -y $(cat INSTALL/3_intel)
		if [[ $pass = "y" ]]; then
			echo intel intel yes
			modprobe kvm-intel
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
		fi
	elif [[ $video = "q" ]]; then
		sudo xbps-install -y $(cat INSTALL/3_qemu)
	fi
fi
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

echo "$(tput setaf 1)Do you want to run lightdm now?$(tput sgr 0)"
read -p "Run lightdm now? YES (y) or NO (n)?          [y/n] " -n 1 lightdm
echo
if [[ $lightdm = "y" ]]; then
    sudo ln -s /etc/sv/lightdm /var/service/
else
	sudo touch /etc/sv/lightdm/down
	sudo ln -s /etc/sv/lightdm /var/service/
    echo "$(tput setaf 1)Remove down file after for run Lightdm..$(tput sgr 0)"
	echo "$(tput setaf 1)Use 'sudo rm /etc/sv/lightdm/down'$(tput sgr 0)"
fi
read -p "Do you want to restart computer now? YES (y) or NO (n)?	[y/n] " -n 1 restart
echo
if [[ $restart = "y" ]]; then
	sudo restart
else
    echo "$(tput setaf 3)Enjoy void linux$(tput sgr 0)"
fi
