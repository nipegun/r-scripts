
apt-get -y autoremove hostapd

cd /tmp
git clone https://w1.fi/hostap.git
cd hostap/hostapd
cp defconfig .config
sudo apt-get -y install pkg-config
make -j$(nproc)
sudo cp hostapd /usr/local/bin/
