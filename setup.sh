#!/usr/bin/bash

git clone https://github.com/kortov/pi-midi-host.git
cd pi-midi-host

# Optimize for power efficiency and fast boot
sudo cp config.txt /boot/ -y
sudo cp cmdline.txt /boot/ -y

sudo apt-get install ruby -y

# Install MIDI autoconnect script
sudo cp connectall.rb /usr/local/bin/
sudo cp 33-midiusb.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo service udev restart
sudo cp midi.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable midi.service
sudo systemctl start midi.service

# FW for older Midisport devices
sudo apt-get install midisport-firmware -y

# Setup MIDI bluetooth
git clone https://github.com/oxesoft/bluez
sudo apt-get install -y autotools-dev libtool autoconf
sudo apt-get install -y libasound2-dev
sudo apt-get install -y libusb-dev libdbus-1-dev libglib2.0-dev libudev-dev libical-dev libreadline-dev
cd bluez
./bootstrap
./configure --enable-midi --prefix=/usr --mandir=/usr/share/man --sysconfdir=/etc --localstatedir=/var
make
sudo make install
cd ..
sudo cp 44-bt.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo service udev restart
sudo cp btmidi.service /lib/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable btmidi.service
sudo systemctl start btmidi.service

# Create alias to show connected devices
echo >> ~/.bashrc
echo "alias midi='aconnect -l'" >> ~/.bashrc
echo >> ~/.bashrc

# Create alias to reconnect devices
echo >> ~/.bashrc
echo "alias connectmidi='connectall.rb" >> ~/.bashrc
echo >> ~/.bashrc
