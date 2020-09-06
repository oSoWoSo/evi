#!/bin/bash
# Void Linux post-install script
echo "$(tput setaf 3)Starting Void Linux post-install script$(tput sgr 0)"

# Default Answers
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

# Ask part
echo "$(tput setaf 1)Which CPU do you use?$(tput sgr 0)"
read -p "AMD (a) or INTEL (i)	[A/i]" -n 1 cpu
cpu="${cpu:-a}"
echo
echo "$(tput setaf 1)Which GPU do you use?$(tput sgr 0)"
read -p "NVIDIA (n), AMD (a), INTEL (i) or QEMU (q)	[n/a/i/Q] " -n 1 video
video="${video:-q}"
echo
if [[ $video = "n" ]]; then
	echo "$(tput setaf 1)Do you want to install PCI passthrough?$(tput sgr 0)"
	read -p "NO (n) or YES (y)	[N/y]" -n 1 pass
	pass="${pass:-n}"
	echo
elif [[ $video = "a" ]]; then
	echo "$(tput setaf 1)Do you want to install PCI passthrough?$(tput sgr 0)"
	read -p "NO (n) or YES (y)	[N/y]" -n 1 pass
	pass="${pass:-n}"
	echo
elif [[ $video = "i" ]]; then
	echo "$(tput setaf 1)Do you want to install PCI passthrough?$(tput sgr 0)"
	read -p "NO (n) or YES (y)	[N/y]" -n 1 pass
	pass="${pass:-n}"
fi	
echo
echo "$(tput setaf 1)Which shell do you want to use?$(tput sgr 0)"
read -p "FISH (f) or BASH (b) or ZSH (z)	[F/b/z]" -n 1 shell
shell="${shell:-f}"
echo
echo "$(tput setaf 1)Which window manager do you want to use?$(tput sgr 0)"
read -p "OPENBOX (o) or AWESOME (a) or SOMETHING ELSE (s)	[o/A/s]" -n 1 wm
wm="${wm:-a}"
echo
if [[ $wm = "a" ]]; then
	echo "$(tput setaf 1)Which terminal emulator do you want to use?$(tput sgr 0)"
	read -p "SAKURA (s) or XTERM (x) or TERMINATOR (t)	[S/x/t]" -n 1 term
	term="${term:-s}"
elif [[ $wm = "o" ]]; then
	echo "$(tput setaf 1)Which terminal emulator do you want to use?$(tput sgr 0)"
	read -p "SAKURA (s) or XTERM (x) or TERMINATOR (t)	[S/x/t]" -n 1 term
	term="${term:-s}"	
fi
echo
echo "$(tput setaf 1)Which text editor do you want to use?$(tput sgr 0)"
read -p "NANO (n) or MICRO (m) or VIM (v)	[n/M/v]" -n 1 editor
editor="${editor:-m}"
echo
echo "$(tput setaf 1)Do you want to install printer support?$(tput sgr 0)"
read -p "NO (n) or YES (y)	[n/Y]" -n 1 cups
cups="${cups:-y}"
echo
echo "$(tput setaf 1)Do you want to share package statistics with void devs?$(tput sgr 0)"
read -p "NO (n) or YES (y)	[n/Y]" -n 1 pop
pop="${pop:-y}"
echo
echo "$(tput setaf 1)Do you want to install virt-manager?$(tput sgr 0)"
read -p "NO (n) or YES (y)	[n/Y]" -n 1 virt
virt="${virt:-y}"
echo

# Install packages -----------------------------------------------------------------------------------------
# Nonfree and multilib repos
chmod +x piu
sudo ./piu u
sudo ./piu i -y $(cat INSTALL/01_repos)
sudo ./piu u
sudo ./piu i -y $(cat INSTALL/02_base)

# Remember git login information?
#git config --global credential.helper store
# Clone also personal dotfiles from gitlab? 
#git clone https://gitlab.com/awesome-void/awesomeVoid ~/bin/dotfiles

# Choose editor -----------------------------------------------------------------------------------------
if [[ $editor = "n" ]]; then
	sudo ./piu i -y nano
	export EDITOR=nano
	echo EDITOR=nano > ~/.bashrc
elif [[ $editor = "m" ]]; then
	sudo ./piu i -y micro
	export EDITOR=micro
	echo EDITOR=micro > ~/.bashrc
elif [[ $editor = "v" ]]; then
	export EDITOR=vim
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
	export TERMINAL=sakura
	echo TERM=sakura > ~/.bashrc
elif [[ $term = "x" ]]; then
	sudo ./piu i -y xterm
	export TERMINAL=xterm
	echo TERM=xterm > ~/.bashrc
elif [[ $term = "t" ]]; then		
	sudo ./piu i -y terminator
	export TERMINAL=terminator
	echo TERM=terminator > ~/.bashrc
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
    sudo ./piu i virt-manager qemu
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
echo "$(tput setaf 1)Uncomment desired language(s) $(tput sgr 0)"
sleep 3
sudo $EDITOR /etc/default/libc-locales
sudo xbps-reconfigure -f glibc-locales

# creating bare repository -----------------------------------------------------------------------------------------
mkdir ~/.void
cd ~/.void
git init --bare

# Share packages with void devs -----------------------------------------------------------------------------------------
if [[ $pop = "y" ]]; then
    sudo ./piu i -y PopCorn
    sudo ln -s /etc/sv/popcorn /var/service/
fi 

# Install services -----------------------------------------------------------------------------------------
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/elogind /var/service/
#sudo ln -s /etc/sv/acpid /var/service/
sudo ln -s /etc/sv/socklog-unix /var/service/
sudo ln -s /etc/sv/nanoklogd /var/service/
sudo ln -s /etc/sv/crond /var/service/
sudo ln -s /etc/sv/chronyd /var/service/

if [[ $wm = "o" ]]; then
	echo "$(tput setaf 1)Do you want to run lightdm now?$(tput sgr 0)"
	read -p "Run lightdm now? NO (n) or YES (y)	[n/Y]" -n 1 lightdm
	lightdm="${lightdm:-y}"
	echo
	if [[ $lightdm = "y" ]]; then
    	sudo ln -s /etc/sv/lightdm /var/service/
	else
		sudo touch /etc/sv/lightdm/down
		sudo ln -s /etc/sv/lightdm /var/service/
    	echo "$(tput setaf 3)Remove down file after for run Lightdm..$(tput sgr 0)"
		echo "$(tput setaf 3)Use 'sudo rm /etc/sv/lightdm/down'$(tput sgr 0)"
	fi
elif [[ $wm = "a" ]]; then
	echo "$(tput setaf 1)Do you want to run lightdm now?$(tput sgr 0)"
	read -p "Run lightdm now? NO (n) or YES (y)	[n/Y]" -n 1 lightdm
	lightdm="${lightdm:-y}"
	echo
	if [[ $lightdm = "y" ]]; then
    	sudo ln -s /etc/sv/lightdm /var/service/
	else
		sudo touch /etc/sv/lightdm/down
		sudo ln -s /etc/sv/lightdm /var/service/
    	echo "$(tput setaf 3)Remove down file after for run Lightdm..$(tput sgr 0)"
		echo "$(tput setaf 3)Use 'sudo rm /etc/sv/lightdm/down'$(tput sgr 0)"
	fi
fi	
echo "$(tput setaf 1)Do you want to restart your computer now?$(tput sgr 0)"
read -p "Restart now? NO (n) or YES (y)	[N/y]" -n 1 reboot
reboot="${reboot:-n}"
echo
if [[ $reboot = "n" ]]; then
	echo "$(tput setaf 3)Enjoy void linux$(tput sgr 0)"
else
    sudo reboot
fi
