#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para crear un punto de acceso en modo puente en Debian con el adaptador WiFi USB TP-Link TL-WN722N (Atheros AR9271)
#
#  Ejecución remota:
#  curl -s https://raw.githubusercontent.com/nipegun/r-scripts/master/PostInst/PuntoDeAcceso-br0-(eth0-y-wlan0)-WiFi(0cf3-9271).sh | bash
# ----------

# Actualizar lista de paquetes
  apt-get -y update

# Instalar paquetes necesarios
  apt-get -y install hostapd
  apt-get -y install crda
  apt-get -y install bridge-utils

# Instalar controlador para el firmware
  apt-get -y install firmware-ath9k-htc

# Activar forwarding
  cp /etc/sysctl.conf /etc/sysctl.conf.bak
  sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

# Configurar opciones por defecto para hostapd
  cp /etc/default/hostapd /etc/default/hostapd.bak
  sed -i -e 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g'      /etc/default/hostapd
  sed -i -e 's|#DAEMON_OPTS=""|DAEMON_OPTS="-dd -t -f /var/log/hostapd.log"|g' /etc/default/hostapd

vMacEth0=$(cat /sys/class/net/eth0/address)

# Configurar interfaces de red
  echo "auto lo"                     > /etc/network/interfaces
  echo "  iface lo inet loopback"   >> /etc/network/interfaces
  echo ""                           >> /etc/network/interfaces
  echo "auto eth0"                  >> /etc/network/interfaces
  echo "  iface eth0 inet manual"   >> /etc/network/interfaces
  echo ""                           >> /etc/network/interfaces
  echo "allow-hotplug wlan0"        >> /etc/network/interfaces
  echo "  iface wlan0 inet manual"  >> /etc/network/interfaces
  echo ""                           >> /etc/network/interfaces
  echo "auto br0"                   >> /etc/network/interfaces
  echo "  iface br0 inet dhcp"      >> /etc/network/interfaces
  echo "  bridge_ports eth0 wlan0"  >> /etc/network/interfaces
  echo "  bridge_stp off"           >> /etc/network/interfaces
  echo "  bridge_fd 0"              >> /etc/network/interfaces
  echo "  bridge_maxwait 0"         >> /etc/network/interfaces
  echo "  hwaddress $vMacEth0"      >> /etc/network/interfaces
  echo ""                           >> /etc/network/interfaces
  echo "#auto br0"                  >> /etc/network/interfaces
  echo "  #iface br0 inet static"   >> /etc/network/interfaces
  echo "  #bridge_ports eth0 wlan0" >> /etc/network/interfaces
  echo "  #bridge_stp off"          >> /etc/network/interfaces
  echo "  #bridge_fd 0"             >> /etc/network/interfaces
  echo "  #bridge_maxwait 0"        >> /etc/network/interfaces
  echo "  #hwaddress $vMacEth0"     >> /etc/network/interfaces
  echo "  #address 192.168.1.2"     >> /etc/network/interfaces
  echo "  #netmask 255.255.255.0"   >> /etc/network/interfaces
  echo "  #gateway 192.168.1.1"     >> /etc/network/interfaces
  echo "  #network 192.168.1.0"     >> /etc/network/interfaces
  echo "  #broadcast 192.168.1.255" >> /etc/network/interfaces

# Capacidades HT y VHT del adaptador (Para saber las capacidades ejecutar iw list)
  # HT:
    # HT20/HT40
    # SM Power Save disabled
    # RX HT20 SGI                                    :[SHORT-GI-20]
    # RX HT40 SGI                                    :[SHORT-GI-40]
    # RX STBC 1-stream                               :[RX-STBC1]
    # Max AMSDU length: 3839 bytes                   :[MAX-AMSDU-3839]
    # No DSSS/CCK HT40                               :[DSSS_CCK-40]

# Configurar el demonio hostapd
  echo ""
  echo "    Configurando el demonio hostapd..."
  echo ""
  echo "#/etc/hostapd/hostapd.conf"                                                                                   > /etc/hostapd/hostapd.conf
  echo ""                                                                                                            >> /etc/hostapd/hostapd.conf
  echo "# Punto de acceso abierto"                                                                                   >> /etc/hostapd/hostapd.conf
  echo "  bridge=br0"                                                                                                >> /etc/hostapd/hostapd.conf
  echo "  interface=wlan0"                                                                                           >> /etc/hostapd/hostapd.conf
  echo "  ssid=HostAPD"                                                                                              >> /etc/hostapd/hostapd.conf
  echo ""                                                                                                            >> /etc/hostapd/hostapd.conf
  echo "# Firmware Atheros AR9271"                                                                                   >> /etc/hostapd/hostapd.conf
  echo "  driver=nl80211"                                                                                            >> /etc/hostapd/hostapd.conf
  echo "  channel=0                               # El canal a usar. 0 buscará el canal con menos interferencias"    >> /etc/hostapd/hostapd.conf
  echo "  hw_mode=g"                                                                                                 >> /etc/hostapd/hostapd.conf
  echo "  ieee80211n=1"                                                                                              >> /etc/hostapd/hostapd.conf
  echo "  wme_enabled=1"                                                                                             >> /etc/hostapd/hostapd.conf
  echo "  wmm_enabled=1                           # Soporte para QoS"                                                >> /etc/hostapd/hostapd.conf
  echo "  ieee80211d=1                            # Limitar las frecuencias sólo a las disponibles en el país"       >> /etc/hostapd/hostapd.conf
  echo "  country_code=ES"                                                                                           >> /etc/hostapd/hostapd.conf
  echo "  ht_capab=[SHORT-GI-40][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]"                                             >> /etc/hostapd/hostapd.conf
  echo "  #[HT20][SHORT-GI-20] dejados fuera para forzar que la red n se cree en el canal de 40Mhz"                  >> /etc/hostapd/hostapd.conf

# Asegurarse que eth0 y wlan0 no reciban direcciones IP por DHCP. Só queremos que el br0 las reciba.
  touch /etc/dhcpd.conf
  echo "denyinterfaces wlan0" >> /etc/dhcpd.conf
  echo "denyinterfaces eth0"  >> /etc/dhcpd.conf

# Desenmascarar, activar e iniciar el servicio
  systemctl unmask hostapd
  systemctl enable hostapd --now

# Crear regla del cortafuegos
  iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Reglas con NFTables
  # Crear la tabla nat
  #  nft add table nat
  # Crear las cadenas de la tabla nat
  #  nft add chain nat prerouting { type nat hook prerouting priority 0 \; }
  #  nft add chain nat postrouting { type nat hook postrouting priority 100 \; }
  # Crear regla
  #  nft add rule ip nat POSTROUTING oifname "eth0" counter masquerade
