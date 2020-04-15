passwd --delete pi

# INSTALL REQUIRED PACKAGES
sudo apt install npm libudev-dev chromium-browser xorg

# MAIN APP INSTALLATION
npm i
npm run build
sudo cp -rf ./dist/linux-armv7l-unpacked/** /usr/share/solar-energy-uisolar-energy-ui

# MAIN APP AUTOSTART
sudo echo 'su -s /bin/bash -c startx pi&' > /etc/rc.local
sudo echo 'exit 0' > /etc/rc.local
sudo echo 'allowed_users=anybody' >> /etc/X11/Xwrapper.config
echo '/usr/share/solar-energy-ui/solar-energy-ui' > ~/.xinitrc
chmod +x ~/.xinitrc


# BOOT SPEED OPTIMIZATIONS
sudo cat <<EOT >> /boot/config.txt
enable_uart=1

# Disable the rainbow splash screen
disable_splash=1

# Disable bluetooth
dtoverlay=pi3-disable-bt

#Disable Wifi
dtoverlay=pi3-disable-wifi
 
# Overclock the SD Card from 50 to 100MHz
# This can only be done with at least a UHS Class 1 card
dtoverlay=sdtweak,overclock_50=100
 
# Set the bootloader delay to 0 seconds. The default is 1s if not specified.
boot_delay=0

# Overclock the raspberry pi. This voids its warranty. Make sure you have a good power supply.
force_turbo=1
EOT

sudo echo "quiet" >> /boot/cmdline.txt

sudo systemctl disable dhcpcd.service networking.service ssh.service ntp.service dphys-swapfile.service keyboard-setup.service apt-daily.service wifi-country.service hciuart.service raspi-config.service avahi-daemon.service triggerhappy.service

sudo apt-get purge --remove plymouth
