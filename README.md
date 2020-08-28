Void linux post install script

WORK IN PROGRESS!!

possible options

 Nvidia Qemu Amd Intel
 passthrough
 awesome openbox
 printer
 popcorn

Scripted questions - answers:

CPU - AMD or Intel - a/i

GPU - Nvidia, AMD, Intel or Qemu - n/a/i/q

PCI passthrough - No or Yes - n/y
(Asked only if GPU isn't Qemu)

WM - Openbox, Awesome or Something else - o/a/s

Editor - Nano, Micro or Vi - n/m/v

Printer - No or Yes - n/y

Share packages stats - No or Yes - n/y

Run Lightdm - Yes or No - n/y
(Asked only if WM is choosed)

Restart - Yes or No - n/y

So you can use answers with script:
./install.sh a i n s m n n n

TODO:

