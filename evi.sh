#!/bin/bash
# Void Linux post-install script
echo
echo "$(red)Dont't run as ROOT user!$(none)"
echo	You will be asked for sudo password if needed...
echo "$(orange)Starting Void Linux post-install script$(none)"
echo

# Default Answers ------------------------------------------------------------------------------------------------
cpu="${cpu:-a}"
video="${video:-q}"
shell="${shell:-f}"
pass="${pass:-n}"
wm="${wm:-a}"
term="${term:-s}"
editor="${editor:-m}"
cups="${cups:-y}"
pop="${pop:-y}"
lightdm="${lightdm:-y}"
reboot="${reboot:-n}"
virt="${virt:-y}"

# Color definitions

blue=$(tput setaf 4)
green=$(tput setaf 2)
orange=$(tput setaf 3)
red=$(tput setaf 1)
none=$(tput sgr 0)

# Ask part -----------------------------------------------------------------------------------------------------------
echo "$(red)Which CPU do you use?$(none)"
read -p "AMD (a) , INTEL (i) or you change your mind? QUIT(q)	[A/i/q]" cpu
cpu="${cpu:-a}"
if [[ $cpu = "q" ]]; then
	exit
fi
echo
echo "$(red)Which GPU do you use?$(none)"
read -p "NVIDIA (n), AMD (a), INTEL (i) or QEMU (q)	[n/a/i/Q] " video
video="${video:-q}"
if [[ $video = "n" ]]; then
	echo "$(red)Do you want to install PCI passthrough?$(none)"
	read -p "NO (n) or YES (y)	[N/y]" pass
	pass="${pass:-n}"
elif [[ $video = "a" ]]; then
	echo "$(red)Do you want to install PCI passthrough?$(none)"
	read -p "NO (n) or YES (y)	[N/y]" pass
	pass="${pass:-n}"
elif [[ $video = "i" ]]; then
	echo "$(red)Do you want to install PCI passthrough?$(none)"
	read -p "NO (n) or YES (y)	[N/y]" pass
	pass="${pass:-n}"
fi	
echo
echo "$(red)Which shell do you want to use?$(none)"
read -p "FISH (f) or BASH (b) or ZSH (z)	[F/b/z]" shell
shell="${shell:-f}"
echo
echo "$(red)Which window manager do you want to use?$(none)"
read -p "OPENBOX (o) or AWESOME (a) or SOMETHING ELSE (s)	[o/A/s]" wm
wm="${wm:-a}"
echo
if [[ $wm = "a" ]]; then
	echo "$(red)Which terminal emulator do you want to use?$(none)"
	read -p "SAKURA (s) or XTERM (x) or TERMINATOR (t)	[S/x/t]" term
	term="${term:-s}"
elif [[ $wm = "o" ]]; then
	echo "$(red)Which terminal emulator do you want to use?$(none)"
	read -p "SAKURA (s) or XTERM (x) or TERMINATOR (t)	[S/x/t]" term
	term="${term:-s}"	
fi
echo
echo "$(red)Which text editor do you want to use?$(none)"
read -p "NANO (n) or MICRO (m) or VIM (v)	[n/M/v]" editor
editor="${editor:-m}"
echo
echo "$(red)Do you want to install printer support?$(none)"
read -p "NO (n) or YES (y)	[n/Y]" cups
cups="${cups:-y}"
echo
echo "$(red)Do you want to share package statistics with void devs?$(none)"
read -p "NO (n) or YES (y)	[n/Y]" pop
pop="${pop:-y}"
echo
echo "$(red)Do you want to install virt-manager?$(none)"
read -p "NO (n) or YES (y)	[n/Y]" virt
virt="${virt:-y}"
echo

# Install packages -----------------------------------------------------------------------------------------
# Nonfree and multilib repos
chmod +x piu
sudo ./piu u -y
sudo ./piu i -y $(cat INSTALL/01_repos)
sudo ./piu u -y
sudo ./piu i -y $(cat INSTALL/02_base)

# Remember git login information?
#git config --global credential.helper store
# Clone also personal dotfiles from gitlab? 
#git clone https://gitlab.com/awesome-void/awesomeVoid ~/bin/dotfiles

# Choose editor -----------------------------------------------------------------------------------------
if [[ $editor = "n" ]]; then
	sudo ./piu i -y nano
	export EDITOR="nano"
	echo EDITOR=nano > ~/.bashrc
elif [[ $editor = "m" ]]; then
	sudo ./piu i -y micro
	export EDITOR="micro"
	echo EDITOR=micro > ~/.bashrc
elif [[ $editor = "v" ]]; then
	export EDITOR="vim"
	echo EDITOR=vim > ~/.bashrc
fi
# Choose CPU, GPU, pasthrough -----------------------------------------------------------------------------------------
if [[ $cpu = "a" ]]; then
	if [[ $video = "n" ]]; then
		sudo ./piu i -y $(cat INSTALL/03_nvidia)
    	sudo nvidia-xconfig
		if [[ $pass = "y" ]]; then
			modprobe kvm-amd
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
		fi
	elif [[ $video = "a" ]]; then	
		sudo ./piu i -y $(cat INSTALL/03_ati)
		if [[ $pass = "y" ]]; then
			modprobe kvm-amd
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
		fi
	elif [[ $video = "i" ]]; then	
		sudo ./piu i -y $(cat INSTALL/03_intel)
		if [[ $pass = "y" ]]; then
			modprobe kvm-amd
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
		fi
	elif [[ $video = "q" ]]; then
		sudo ./piu i -y $(cat INSTALL/03_qemu)
	fi
elif [[ $cpu = "i" ]]; then
	if [[ $video = "n" ]]; then
		sudo ./piu i -y $(cat INSTALL/03_nvidia)
    	sudo nvidia-xconfig
		if [[ $pass = "y" ]]; then
			echo intel nvidia yes
			modprobe kvm-intel
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
		fi
	elif [[ $video = "a" ]]; then	
		sudo ./piu i -y $(cat INSTALL/03_ati)
		if [[ $pass = "y" ]]; then
			echo intel amd yes
			modprobe kvm-intel
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
		fi
    elif [[ $video = "i" ]]; then	
		sudo ./piu i -y $(cat INSTALL/03_intel)
		if [[ $pass = "y" ]]; then
			echo intel intel yes
			modprobe kvm-intel
			sudo cp -r OVMF /usr/share/ovmf
			chmod +x INSTALL/pass.sh
			sudo ./INSTALL/pass.sh
		fi
	elif [[ $video = "q" ]]; then
		sudo ./piu i -y $(cat INSTALL/03_qemu)
	fi
fi
# Choose default shell -----------------------------------------------------------------------------------------
if [[ $shell = "f" ]]; then
	sudo ./piu i -y fish-shell
	sudo usermod --shell /bin/fish $USER
elif [[ $shell = "b" ]]; then	
	sudo ./piu i -y bash-completion
	sudo usermod --shell /bin/bash $USER
elif [[ $shell = "z" ]]; then	
	sudo ./piu i -y zsh zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting
	sudo usermod --shell /bin/zsh $USER
fi	
# Choose terminal emulator --------------------------------------------------------------------------------------
if [[ $term = "s" ]]; then
	sudo ./piu i -y sakura
	export TERMINAL="sakura"
	echo TERM="sakura" > ~/.bashrc
elif [[ $term = "x" ]]; then
	sudo ./piu i -y xterm
	export TERMINAL="xterm"
	echo TERM="xterm" > ~/.bashrc
elif [[ $term = "t" ]]; then		
	sudo ./piu i -y terminator
	export TERMINAL="terminator"
	echo TERM="terminator" > ~/.bashrc
fi
# Choose window manager -----------------------------------------------------------------------------------------
if [[ $wm = "o" ]]; then
    sudo ./piu i -y $(cat INSTALL/04_desktop)
    sudo ./piu i -y $(cat INSTALL/05_openbox)
	sudo -u $USER obmenu-generator -p -i -u -d -c
	echo "tint2 &
	setxkbmap cz &
	nitrogen --restore &
	volumeicon &
	conky &" >> ~/.config/openbox/autostart
#   cp ~/bin/dotfiles/home/zen/.config/openbox/rc.xml ~/.config/openbox
elif [[ $wm = "a" ]]; then
	echo awesome
    sudo ./piu i -y $(cat INSTALL/04_desktop)
    sudo ./piu i -y $(cat INSTALL/05_awesome)
	cp -r /etc/xdg/awesome ~/.config
	if [[ $term = "s" ]]; then
		sed -i 's/xterm/sakura/g' ~/.config/awesome/rc.lua
	elif [[ $term = "t" ]]; then
		sed -i 's/xterm/terminator/g' ~/.config/awesome/rc.lua
	fi
fi
sudo ./piu i -y $(cat INSTALL/06_media)
#sudo xbps-install -Sy $(cat INSTALL/07_virtual)
#sudo xbps-install -Sy $(cat INSTALL/08_big)
#sudo xbps-install -Sy $(cat INSTALL/)

# printer support -----------------------------------------------------------------------------------------
if [[ $cups = "y" ]]; then
    sudo ./piu i -y $(cat INSTALL/09_print)
    sudo ln -s /etc/sv/cupsd /var/service
fi    

# Virtualization support -----------------------------------------------------------------------------------------
if [[ $virt = "y" ]]; then
    sudo ./piu i -y $(cat INSTALL/07_virtual)
	sudo ln -s /etc/sv/libvirtd /var/service
	sudo ln -s /etc/sv/virtlockd /var/service
	sudo ln -s /etc/sv/virtlogd /var/service
	sudo usermod -aG kvm $USER
	if [[ $cpu = "a" ]]; then
		modprobe kvm-amd
	elif [[ $cpu = "i" ]]; then
		modprobe kvm-intel
	fi
fi  

# make fish base shell-----------------------------------------------------------------------------------------
#echo ". ~/.config/fish/aliases.fish" >> ~/.config/fish/config.fish
#echo "alias xterm 'sakura'" >> ~/.config/fish/aliases.fish

# socklog-----------------------------------------------------------------------------------------
sudo usermod -a -G socklog $USER

# Language -----------------------------------------------------------------------------------------
echo "$(red)Uncomment desired language(s) $(none)"
sleep 3
sudo $EDITOR /etc/default/libc-locales
sudo xbps-reconfigure -f glibc-locales

# creating bare repository -----------------------------------------------------------------------------------------
mkdir ~/.void
cd ~/.void
git init --bare
cd ~/bin/install

# Share packages with void devs -----------------------------------------------------------------------------------------
if [[ $pop = "y" ]]; then
    sudo ./piu i -y PopCorn
    sudo ln -s /etc/sv/popcorn /var/service/
fi 

# Install services -----------------------------------------------------------------------------------------
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/elogind /var/service/
#sudo ln -s /etc/sv/acpid /var/service/
#sudo ln -s /etc/sv/socklog-unix /var/service/
#sudo ln -s /etc/sv/nanoklogd /var/service/
#sudo ln -s /etc/sv/crond /var/service/
#sudo ln -s /etc/sv/chronyd /var/service/

if [[ $wm = "o" ]]; then
	echo "$(red)Do you want to run lightdm now?$(none)"
	read -p "Run lightdm now? NO (n) or YES (y)	[n/Y]" lightdm
	lightdm="${lightdm:-y}"
	echo
	if [[ $lightdm = "y" ]]; then
    	sudo ln -s /etc/sv/lightdm /var/service/
	else
		sudo touch /etc/sv/lightdm/down
		sudo ln -s /etc/sv/lightdm /var/service/
    	echo "$(orange)Remove down file after for run Lightdm..$(none)"
		echo "$(orange)Use 'sudo rm /etc/sv/lightdm/down'$(none)"
	fi
elif [[ $wm = "a" ]]; then
	echo "$(red)Do you want to run lightdm now?$(none)"
	read -p "Run lightdm now? NO (n) or YES (y)	[n/Y]" lightdm
	lightdm="${lightdm:-y}"
	echo
	if [[ $lightdm = "y" ]]; then
    	sudo ln -s /etc/sv/lightdm /var/service/
	else
		sudo touch /etc/sv/lightdm/down
		sudo ln -s /etc/sv/lightdm /var/service/
    	echo "$(orange)Remove down file after for run Lightdm..$(none)"
		echo "$(orange)Use 'sudo rm /etc/sv/lightdm/down'$(none)"
	fi
fi	
echo "$(red)Do you want to restart your computer now?$(none)"
read -p "Restart now? NO (n) or YES (y)	[N/y]" reboot
reboot="${reboot:-n}"
echo
if [[ $reboot = "n" ]]; then
	echo "$(orange)Enjoy void linux$(none)"
else
    sudo reboot
fi
# Enjoy Void linux ----------------------------------------------------------------------------------------------------------------
