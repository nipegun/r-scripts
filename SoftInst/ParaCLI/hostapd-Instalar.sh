
sudo apt-get -y autoremove hostapd

sudo apt-get -y install build-essential
sudo apt-get -y install pkg-config
sudo apt-get -y install libnl-3-dev
sudo apt-get -y install libssl-dev
sudo apt-get -y install libnl-genl-3-dev

cd /tmp
sudo rm -rf /tmp/hostap
git clone https://w1.fi/hostap.git
cd hostap/hostapd
cp defconfig .config

make -j$(nproc)
sudo cp -fv hostapd /usr/sbin/
