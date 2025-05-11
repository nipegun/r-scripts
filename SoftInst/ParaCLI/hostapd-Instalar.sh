
apt-get -y autoremove hostapd

cd /tmp
git clone https://w1.fi/hostap.git
cd hostap/hostapd
cp defconfig .config
make -j$(nproc)
sudo cp hostapd /usr/local/bin/
