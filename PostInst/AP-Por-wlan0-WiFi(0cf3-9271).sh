#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para instalar y configurar xxxxxxxxx en Debian
#
#  Ejecución remota:
#  curl -s x | bash
# ----------

apt-get -y update
apt-get -y install firmware-ath9k-htc
apt-get -y install hostapd
apt-get -y install crda
apt-get -y install bridge-utils
 
cp /etc/sysctl.conf /etc/sysctl.conf.bak
sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

cp /etc/default/hostapd /etc/default/hostapd.bak
sed -i -e 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g' /etc/default/hostapd
sed -i -e 's|#DAEMON_OPTS=""|DAEMON_OPTS="-dd -t -f /var/log/hostapd.log"|g' /etc/default/hostapd

auto eth0
iface eth0 inet manual

allow-hotplug wlan0
iface wlan0 inet manual

auto br0
iface br0 inet dhcp
  bridge_ports eth0 wlan0



echo "-----------------------------------"
echo "  CONFIGURANDO EL DEMONIO HOSTAPD"
echo "-----------------------------------"
echo ""
vInterfazInalambrica="wlan0"
echo "#/etc/hostapd/hostapd.conf"                                                                > /etc/hostapd/hostapd.conf
echo "interface=$vInterfazInalambrica"                                                          >> /etc/hostapd/hostapd.conf
echo "driver=nl80211"                                                                           >> /etc/hostapd/hostapd.conf
echo "bridge=br0"                                                                               >> /etc/hostapd/hostapd.conf
echo "hw_mode=g"                                                                                >> /etc/hostapd/hostapd.conf
echo "wme_enabled=1"                                                                            >> /etc/hostapd/hostapd.conf
echo "ieee80211n=1"                                                                             >> /etc/hostapd/hostapd.conf
echo "ieee80211d=1"                                                                             >> /etc/hostapd/hostapd.conf
echo "channel=1"                                                                                >> /etc/hostapd/hostapd.conf
echo "country_code=ES"                                                                          >> /etc/hostapd/hostapd.conf
echo "wmm_enabled=1"                                                                            >> /etc/hostapd/hostapd.conf
echo "ht_capab=[HT20+][HT40+][SHORT-GI-20][SHORT-GI-40][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]" >> /etc/hostapd/hostapd.conf
echo "ignore_broadcast_ssid=0"                                                                  >> /etc/hostapd/hostapd.conf
echo "ssid=RouterX86"                                                                           >> /etc/hostapd/hostapd.conf
echo "eap_reauth_period=360000000"                                                              >> /etc/hostapd/hostapd.conf
echo "wpa=2"                                                                                    >> /etc/hostapd/hostapd.conf
echo "wpa_key_mgmt=WPA-PSK"                                                                     >> /etc/hostapd/hostapd.conf
echo "wpa_pairwise=TKIP"                                                                        >> /etc/hostapd/hostapd.conf
echo "rsn_pairwise=CCMP"                                                                        >> /etc/hostapd/hostapd.conf
echo "wpa_passphrase=RouterX86"                                                                 >> /etc/hostapd/hostapd.conf

denyinterfaces wlan0 /etc/dhcpd.conf
denyinterfaces eth0 /etc/dhcpd.conf

systemctl unmask hostapd
systemctl enable hostapd --now

