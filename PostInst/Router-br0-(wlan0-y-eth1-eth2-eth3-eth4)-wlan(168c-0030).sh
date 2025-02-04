#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para poner a Debian a routear via el puente br0 (wlan0 y eth1, eth2, eth3, eth4)
#
#  Ejecución remota:
#  curl -s "https://raw.githubusercontent.com/nipegun/r-scripts/master/PostInst/RoutearPor-br0-(wlan0-y-eth1-eth2-eth3-eth4)-wlan(168c-0030).sh" | bash
# ----------

# ----------
#  Este script transforma un Debian recién instalado en un router WiFi que sirve IPs en una interfaz puente
#  comprendida por la primera interfaz inalámbrica y la primera interfaz ethernet LAN.
#  Es necesario que el ordenador cuente con, al menos, una interfaz cableada y una interfaz inalámbrica Atheros AR9380.
#  El script tiene en cuenta que el router al que está conectado el ordenador está en una subred distinta de 192.168.2.0/24
#  porque al finalizar su ejecución el sistema resultante proporcionará IPs desde la 192.168.1.100 hasta 192.168.1.255.
#
#  Debes reemplazar los valores de las 3 variables de abajo antes de ejecutar el script.
# ----------

vInterfazWAN=eth0
vInterfazWLAN1=wlan0
vInterfazLAN1=eth1
vInterfazLAN2=eth2
vInterfazLAN3=eth3
vInterfazLAN4=eth4

ColorAzul="\033[0;34m"
ColorAzulClaro="\033[1;34m"
ColorVerde='\033[1;32m'
ColorRojo='\033[1;31m'
FinColor='\033[0m'

# Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${ColorRojo}curl no está instalado. Iniciando su instalación...${FinColor}"
    echo ""
    apt-get -y update
    apt-get -y install curl
    echo ""
  fi

# Determinar la versión de Debian
  if [ -f /etc/os-release ]; then
    # Para systemd y freedesktop.org
      . /etc/os-release
      OS_NAME=$NAME
      OS_VERS=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
      OS_NAME=$(lsb_release -si)
      OS_VERS=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    # Para algunas versiones de Debian sin el comando lsb_release
      . /etc/lsb-release
      OS_NAME=$DISTRIB_ID
      OS_VERS=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    # Para versiones viejas de Debian.
      OS_NAME=Debian
      OS_VERS=$(cat /etc/debian_version)
  else
    # Para el viejo uname (También funciona para BSD)
      OS_NAME=$(uname -s)
      OS_VERS=$(uname -r)
  fi

if [ $OS_VERS == "7" ]; then

  echo ""
  echo -e "${ColorAzulClaro}Iniciando el script de preparación de Debian 7 (Wheezy) para que routee por br0...${FinColor}"
  echo ""

  echo ""
  echo -e "${ColorRojo}  Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${FinColor}"
  echo ""

elif [ $OS_VERS == "8" ]; then

  echo ""
  echo -e "${ColorAzulClaro}Iniciando el script de preparación de Debian 8 (Jessie) para que routee por br0...${FinColor}"
  echo ""

  echo ""
  echo -e "${ColorRojo}  Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${FinColor}"
  echo ""

elif [ $OS_VERS == "9" ]; then

  echo ""
  echo -e "${ColorAzulClaro}Iniciando el script de preparación de Debian 9 (Stretch) para que routee por br0...${FinColor}"
  echo ""

  # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${ColorRojo}  dialog no está instalado. Iniciando su instalación...${FinColor}"
      echo ""
      apt-get -y update && apt-get -y install dialog
      echo ""
    fi

  cmd=(dialog --checklist "Opciones del script:" 22 76 16)
  options=(
    1 "Agregar todos los repositorios" on
    2 "Actualizar el sistema" on
    3 "Instalar paquetes necesarios" on
    4 "Crear o reemplazar archivos de configuración" on
    5 "Instalar servidor DNS" on
    6 "Reiniciar el sistema" on
  )
  choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
  for choice in $choices
    do
      case $choice in

        1)
          echo ""
          echo "  Agregando todos los repositorios..."
          echo ""
          cp /etc/apt/sources.list /etc/apt/sources.list.bak
          echo "deb http://ftp.debian.org/debian/ stretch main contrib non-free"              > /etc/apt/sources.list
          echo "deb-src http://ftp.debian.org/debian/ stretch main contrib non-free"         >> /etc/apt/sources.list
          echo ""                                                                            >> /etc/apt/sources.list
          echo "deb http://ftp.debian.org/debian/ stretch-updates main contrib non-free"     >> /etc/apt/sources.list
          echo "deb-src http://ftp.debian.org/debian/ stretch-updates main contrib non-free" >> /etc/apt/sources.list
          echo ""                                                                            >> /etc/apt/sources.list
          echo "deb http://security.debian.org/ stretch/updates main contrib non-free"       >> /etc/apt/sources.list
          echo "deb-src http://security.debian.org/ stretch/updates main contrib non-free"   >> /etc/apt/sources.list
          echo ""                                                                            >> /etc/apt/sources.list
        ;;

        2)
          echo ""
          echo "  Actualizando el sistema..."
          echo ""
          apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade && apt-get autoremove
        ;;

        3)
          echo ""
          echo "  Instalando paquetes necesarios..."
          echo ""
          apt-get -y install isc-dhcp-server
          apt-get -y install hostapd
          apt-get -y install bridge-utils
          apt-get -y install crda
          apt-get -y install firmware-linux-nonfree
        ;;

        4)
          echo ""
          echo "  Creando o reemplazando archivos de configuración..."
          echo ""

          echo ""
          echo "    Creando las reglas de IPTables..."
          echo ""
          echo "*mangle"                                                                            > /root/ReglasIPTablesV4RouterBR0
          echo ":PREROUTING ACCEPT [0:0]"                                                          >> /root/ReglasIPTablesV4RouterBR0
          echo ":INPUT ACCEPT [0:0]"                                                               >> /root/ReglasIPTablesV4RouterBR0
          echo ":FORWARD ACCEPT [0:0]"                                                             >> /root/ReglasIPTablesV4RouterBR0
          echo ":OUTPUT ACCEPT [0:0]"                                                              >> /root/ReglasIPTablesV4RouterBR0
          echo ":POSTROUTING ACCEPT [0:0]"                                                         >> /root/ReglasIPTablesV4RouterBR0
          echo "COMMIT"                                                                            >> /root/ReglasIPTablesV4RouterBR0
          echo ""                                                                                  >> /root/ReglasIPTablesV4RouterBR0
          echo "*nat"                                                                              >> /root/ReglasIPTablesV4RouterBR0
          echo ":PREROUTING ACCEPT [0:0]"                                                          >> /root/ReglasIPTablesV4RouterBR0
          echo ":INPUT ACCEPT [0:0]"                                                               >> /root/ReglasIPTablesV4RouterBR0
          echo ":OUTPUT ACCEPT [0:0]"                                                              >> /root/ReglasIPTablesV4RouterBR0
          echo ":POSTROUTING ACCEPT [0:0]"                                                         >> /root/ReglasIPTablesV4RouterBR0
          echo "-A POSTROUTING -o $vInterfazWAN -j MASQUERADE"                                     >> /root/ReglasIPTablesV4RouterBR0
          echo "COMMIT"                                                                            >> /root/ReglasIPTablesV4RouterBR0
          echo ""                                                                                  >> /root/ReglasIPTablesV4RouterBR0
          echo "*filter"                                                                           >> /root/ReglasIPTablesV4RouterBR0
          echo ":INPUT ACCEPT [0:0]"                                                               >> /root/ReglasIPTablesV4RouterBR0
          echo ":FORWARD ACCEPT [0:0]"                                                             >> /root/ReglasIPTablesV4RouterBR0
          echo ":OUTPUT ACCEPT [0:0]"                                                              >> /root/ReglasIPTablesV4RouterBR0
          echo "-A FORWARD -i $vInterfazWAN -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /root/ReglasIPTablesV4RouterBR0
          echo "-A FORWARD -i br0 -o $vInterfazWAN -j ACCEPT"                                      >> /root/ReglasIPTablesV4RouterBR0
          echo "COMMIT"                                                                            >> /root/ReglasIPTablesV4RouterBR0

          echo ""
          echo "    Habilitando el forwarding IPv4 entre interfaces..."
          echo ""
          cp /etc/sysctl.conf /etc/sysctl.conf.bak
          sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

          echo ""
          echo "    Indicando la ubicación del archivo de configuración del daemon hostapd..."
          echo ""
          cp /etc/default/hostapd /etc/default/hostapd.bak
          sed -i -e 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g' /etc/default/hostapd
          sed -i -e 's|#DAEMON_OPTS=""|DAEMON_OPTS="-dd -t -f /var/log/hostapd.log"|g' /etc/default/hostapd
          echo ""

          echo ""
          echo "    Indicando la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá..."
          echo ""
          cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
          echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'  > /etc/default/isc-dhcp-server
          echo 'INTERFACESv4="br0"'                >> /etc/default/isc-dhcp-server
          echo 'INTERFACESv6=""'                   >> /etc/default/isc-dhcp-server

          echo ""
          echo "    Configurando el servidor DHCP..."
          echo ""
          cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
          echo "authoritative;"                                  > /etc/dhcp/dhcpd.conf
          echo "subnet 192.168.2.0 netmask 255.255.255.0 {"     >> /etc/dhcp/dhcpd.conf
          echo "  range 192.168.2.100 192.168.2.199;"           >> /etc/dhcp/dhcpd.conf
          echo "  option routers 192.168.2.1;"                  >> /etc/dhcp/dhcpd.conf
          echo "  option domain-name-servers 1.1.1.1, 1.0.0.1;" >> /etc/dhcp/dhcpd.conf
          echo "  default-lease-time 600;"                      >> /etc/dhcp/dhcpd.conf
          echo "  max-lease-time 7200;"                         >> /etc/dhcp/dhcpd.conf
          echo ""                                               >> /etc/dhcp/dhcpd.conf
          echo "  host PrimeraReserva {"                        >> /etc/dhcp/dhcpd.conf
          echo "    hardware ethernet 00:00:00:00:00:10;"       >> /etc/dhcp/dhcpd.conf
          echo "    fixed-address 192.168.2.10;"                >> /etc/dhcp/dhcpd.conf
          echo "  }"                                            >> /etc/dhcp/dhcpd.conf
          echo "}"                                              >> /etc/dhcp/dhcpd.conf

          echo ""
          echo "    Configurando el demonio hostapd..."
          echo ""
          echo "#/etc/hostapd/hostapd.conf"                                                                                 > /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "# Punto de acceso básico"                                                                                  >> /etc/hostapd/hostapd.conf
          echo "#bridge=br0"                                                                                               >> /etc/hostapd/hostapd.conf
          echo "#interface=wlan0"                                                                                          >> /etc/hostapd/hostapd.conf
          echo "#ssid=BasicAP"                                                                                             >> /etc/hostapd/hostapd.conf
          echo "#channel=0"                                                                                                >> /etc/hostapd/hostapd.conf
          echo "#hw_mode=a"                                                                                                >> /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "# Primer punto de acceso"                                                                                  >> /etc/hostapd/hostapd.conf
          echo "bridge=br0"                                                                                                >> /etc/hostapd/hostapd.conf
          echo "interface=$vInterfazWLAN1"                                                                                 >> /etc/hostapd/hostapd.conf
          echo "wpa=2"                                                                                                     >> /etc/hostapd/hostapd.conf
          echo "wpa_key_mgmt=WPA-PSK"                                                                                      >> /etc/hostapd/hostapd.conf
          echo "wpa_pairwise=TKIP"                                                                                         >> /etc/hostapd/hostapd.conf
          echo "rsn_pairwise=CCMP"                                                                                         >> /etc/hostapd/hostapd.conf
          echo "ignore_broadcast_ssid=0"                                                                                   >> /etc/hostapd/hostapd.conf
          echo "eap_reauth_period=360000000"                                                                               >> /etc/hostapd/hostapd.conf
          echo "ssid=RouterX86"                                                                                            >> /etc/hostapd/hostapd.conf
          echo "wpa_passphrase=RouterX86"                                                                                  >> /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "#Tarjeta TP-LINK TL-WDN4800 Atheros 9380 (168c:0030)"                                                      >> /etc/hostapd/hostapd.conf
          echo "driver=nl80211"                                                                                            >> /etc/hostapd/hostapd.conf
          echo "channel=0                               # El canal a usar. 0 buscará el canal con menos interferencias"    >> /etc/hostapd/hostapd.conf
          echo "hw_mode=a"                                                                                                 >> /etc/hostapd/hostapd.conf
          echo "ieee80211n=1"                                                                                              >> /etc/hostapd/hostapd.conf
          echo "wme_enabled=1"                                                                                             >> /etc/hostapd/hostapd.conf
          echo "wmm_enabled=1                           # Soporte para QoS"                                                >> /etc/hostapd/hostapd.conf
          echo "ieee80211d=1                            # Limitar las frecuencias sólo a las disponibles en el país"       >> /etc/hostapd/hostapd.conf
          echo "country_code=ES"                                                                                           >> /etc/hostapd/hostapd.conf
          echo "ht_capab=[RXLDPC][HT20+][HT40+][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]" >> /etc/hostapd/hostapd.conf

          echo ""
          echo "    Configurando interfaces de red..."
          echo ""
          cp /etc/network/interfaces /etc/network/interfaces.bak
          echo "auto lo"                                                                                     > /etc/network/interfaces
          echo "  iface lo inet loopback"                                                                   >> /etc/network/interfaces
          echo "  pre-up iptables-restore < /root/ReglasIPTablesV4RouterBR0"                                >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazWAN"                                                                         >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazWAN"                                                              >> /etc/network/interfaces
          echo "  iface $vInterfazWAN inet dhcp"                                                            >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazWLAN1"                                                                       >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazWLAN1"                                                            >> /etc/network/interfaces
          echo "  iface $vInterfazWLAN1 inet manual"                                                        >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN1"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN1"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN1 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN2"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN2"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN2 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN3"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN3"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN3 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN4"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN4"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN4 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto br0"                                                                                   >> /etc/network/interfaces
          echo "  iface br0 inet static"                                                                    >> /etc/network/interfaces
          echo "  network 192.168.2.0"                                                                      >> /etc/network/interfaces
          echo "  address 192.168.2.1"                                                                      >> /etc/network/interfaces
          echo "  broadcast 192.168.2.255"                                                                  >> /etc/network/interfaces
          echo "  netmask 255.255.255.0"                                                                    >> /etc/network/interfaces
          echo "  bridge-ports $vInterfazWLAN1 $vInterfazLAN1 $vInterfazLAN2 $vInterfazLAN3 $vInterfazLAN4" >> /etc/network/interfaces

          echo ""
          echo "    Descargando archivo de nombres de fabricantes..."
          echo ""
          wget -O /usr/local/etc/oui.txt http://standards-oui.ieee.org/oui/oui.txt
        ;;

        5)
          echo ""
          echo "  Instalando el servidor DNS..."
          echo ""
          apt-get -y update
          apt-get -y install bind9
          apt-get -y install dnsutils
          service bind9 restart
          sed -i "1s|^|nameserver 127.0.0.1\n|" /etc/resolv.conf
          sed -i -e 's|// forwarders {|forwarders {|g' /etc/bind/named.conf.options
          sed -i "/0.0.0.0;/c\1.1.1.1;"                /etc/bind/named.conf.options
          sed -i -e 's|// };|};|g'                     /etc/bind/named.conf.options
          echo 'zone "prueba.com" {'               >> /etc/bind/named.conf.local
          echo "  type master;"                    >> /etc/bind/named.conf.local
          echo '  file "/etc/bind/db.prueba.com";' >> /etc/bind/named.conf.local
          echo "};"                                >> /etc/bind/named.conf.local
          service bind9 restart
        ;;

        6)
          echo ""
          echo "  Reiniciando el sistema..."
          echo ""
          shutdown -r now
        ;;

      esac

    done

elif [ $OS_VERS == "10" ]; then

  echo ""
  echo -e "${ColorAzulClaro}Iniciando el script de preparación de Debian 10 (Buster) para que routee por br0...${FinColor}"
  echo ""

  # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${ColorRojo}  dialog no está instalado. Iniciando su instalación...${FinColor}"
      echo ""
      apt-get -y update && apt-get -y install dialog
      echo ""
    fi

  cmd=(dialog --checklist "Opciones del script:" 22 76 16)
  options=(
    1 "Agregar todos los repositorios" on
    2 "Actualizar el sistema" on
    3 "Instalar paquetes necesarios" on
    4 "Crear o reemplazar archivos de configuración" on
    5 "Instalar servidor DNS" on
    6 "Reiniciar el sistema" on
  )
  choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
  for choice in $choices
    do
      case $choice in
        1)
          echo ""
          echo "    Agregando todos los repositorios..."
          echo ""
          cp /etc/apt/sources.list /etc/apt/sources.list.bak
          echo "deb http://deb.debian.org/debian/ buster main contrib non-free"              > /etc/apt/sources.list
          echo "deb-src http://deb.debian.org/debian/ buster main contrib non-free"         >> /etc/apt/sources.list
          echo ""                                                                           >> /etc/apt/sources.list
          echo "deb http://deb.debian.org/debian/ buster-updates main contrib non-free"     >> /etc/apt/sources.list
          echo "deb-src http://deb.debian.org/debian/ buster-updates main contrib non-free" >> /etc/apt/sources.list
          echo ""                                                                           >> /etc/apt/sources.list
          echo "deb http://security.debian.org/ buster/updates main contrib non-free"       >> /etc/apt/sources.list
          echo "deb-src http://security.debian.org/ buster/updates main contrib non-free"   >> /etc/apt/sources.list
          echo ""                                                                           >> /etc/apt/sources.list
        ;;

        2)
          echo ""
          echo "   Actualizando el sistema..."
          echo ""
          apt-get update && apt-get -y upgrade && apt-get -y dist-upgrade && apt-get autoremove
        ;;

        3)
          echo ""
          echo "   Instalando paquetes necesarios..."
          echo ""
          apt-get -y install isc-dhcp-server
          apt-get -y install hostapd
          apt-get -y install bridge-utils
          apt-get -y install crda
          apt-get -y install firmware-linux-nonfree
        ;;

        4)
          echo ""
          echo "  Creando o reemplazando archivos de configuración..."
          echo ""

          echo ""
          echo "    Creando las reglas de IPTables..."
          echo ""
          echo "*mangle"                                                                            > /root/ReglasIPTablesV4RouterBR0
          echo ":PREROUTING ACCEPT [0:0]"                                                          >> /root/ReglasIPTablesV4RouterBR0
          echo ":INPUT ACCEPT [0:0]"                                                               >> /root/ReglasIPTablesV4RouterBR0
          echo ":FORWARD ACCEPT [0:0]"                                                             >> /root/ReglasIPTablesV4RouterBR0
          echo ":OUTPUT ACCEPT [0:0]"                                                              >> /root/ReglasIPTablesV4RouterBR0
          echo ":POSTROUTING ACCEPT [0:0]"                                                         >> /root/ReglasIPTablesV4RouterBR0
          echo "COMMIT"                                                                            >> /root/ReglasIPTablesV4RouterBR0
          echo ""                                                                                  >> /root/ReglasIPTablesV4RouterBR0
          echo "*nat"                                                                              >> /root/ReglasIPTablesV4RouterBR0
          echo ":PREROUTING ACCEPT [0:0]"                                                          >> /root/ReglasIPTablesV4RouterBR0
          echo ":INPUT ACCEPT [0:0]"                                                               >> /root/ReglasIPTablesV4RouterBR0
          echo ":OUTPUT ACCEPT [0:0]"                                                              >> /root/ReglasIPTablesV4RouterBR0
          echo ":POSTROUTING ACCEPT [0:0]"                                                         >> /root/ReglasIPTablesV4RouterBR0
          echo "-A POSTROUTING -o $vInterfazWAN -j MASQUERADE"                                     >> /root/ReglasIPTablesV4RouterBR0
          echo "COMMIT"                                                                            >> /root/ReglasIPTablesV4RouterBR0
          echo ""                                                                                  >> /root/ReglasIPTablesV4RouterBR0
          echo "*filter"                                                                           >> /root/ReglasIPTablesV4RouterBR0
          echo ":INPUT ACCEPT [0:0]"                                                               >> /root/ReglasIPTablesV4RouterBR0
          echo ":FORWARD ACCEPT [0:0]"                                                             >> /root/ReglasIPTablesV4RouterBR0
          echo ":OUTPUT ACCEPT [0:0]"                                                              >> /root/ReglasIPTablesV4RouterBR0
          echo "-A FORWARD -i $vInterfazWAN -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /root/ReglasIPTablesV4RouterBR0
          echo "-A FORWARD -i br0 -o $vInterfazWAN -j ACCEPT"                                      >> /root/ReglasIPTablesV4RouterBR0
          echo "COMMIT"                                                                            >> /root/ReglasIPTablesV4RouterBR0

          echo ""
          echo "    Habilitando el forwarding IPv4 entre interfaces..."
          echo ""
          cp /etc/sysctl.conf /etc/sysctl.conf.bak
          sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

          echo ""
          echo "    Indicando la ubicación de la configuración del daemon hostapd..."
          echo ""
          cp /etc/default/hostapd /etc/default/hostapd.bak
          sed -i -e 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g'      /etc/default/hostapd
          sed -i -e 's|#DAEMON_OPTS=""|DAEMON_OPTS="-dd -t -f /var/log/hostapd.log"|g' /etc/default/hostapd
          echo ""

          echo ""
          echo "    Indicando la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá..."
          echo ""
          cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
          echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'  > /etc/default/isc-dhcp-server
          echo 'INTERFACESv4="br0"'                >> /etc/default/isc-dhcp-server
          echo 'INTERFACESv6=""'                   >> /etc/default/isc-dhcp-server

          echo ""
          echo "    Configurando el servidor DHCP..."
          echo ""
          cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
          echo "authoritative;"                                  > /etc/dhcp/dhcpd.conf
          echo "subnet 192.168.2.0 netmask 255.255.255.0 {"     >> /etc/dhcp/dhcpd.conf
          echo "  range 192.168.2.100 192.168.2.199;"           >> /etc/dhcp/dhcpd.conf
          echo "  option routers 192.168.2.1;"                  >> /etc/dhcp/dhcpd.conf
          echo "  option domain-name-servers 1.1.1.1, 1.0.0.1;" >> /etc/dhcp/dhcpd.conf
          echo "  default-lease-time 600;"                      >> /etc/dhcp/dhcpd.conf
          echo "  max-lease-time 7200;"                         >> /etc/dhcp/dhcpd.conf
          echo ""                                               >> /etc/dhcp/dhcpd.conf
          echo "  host PrimeraReserva {"                        >> /etc/dhcp/dhcpd.conf
          echo "    hardware ethernet 00:00:00:00:00:10;"       >> /etc/dhcp/dhcpd.conf
          echo "    fixed-address 192.168.2.10;"                >> /etc/dhcp/dhcpd.conf
          echo "  }"                                            >> /etc/dhcp/dhcpd.conf
          echo "}"                                              >> /etc/dhcp/dhcpd.conf

          echo ""
          echo "    Configurando el demonio hostapd..."
          echo ""
          echo "#/etc/hostapd/hostapd.conf"                                                                                 > /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "# Punto de acceso básico"                                                                                  >> /etc/hostapd/hostapd.conf
          echo "#bridge=br0"                                                                                               >> /etc/hostapd/hostapd.conf
          echo "#interface=wlan0"                                                                                          >> /etc/hostapd/hostapd.conf
          echo "#ssid=BasicAP"                                                                                             >> /etc/hostapd/hostapd.conf
          echo "#channel=0"                                                                                                >> /etc/hostapd/hostapd.conf
          echo "#hw_mode=a"                                                                                                >> /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "# Primer punto de acceso"                                                                                  >> /etc/hostapd/hostapd.conf
          echo "bridge=br0"                                                                                                >> /etc/hostapd/hostapd.conf
          echo "interface=$vInterfazWLAN1"                                                                                 >> /etc/hostapd/hostapd.conf
          echo "wpa=2"                                                                                                     >> /etc/hostapd/hostapd.conf
          echo "wpa_key_mgmt=WPA-PSK"                                                                                      >> /etc/hostapd/hostapd.conf
          echo "wpa_pairwise=TKIP"                                                                                         >> /etc/hostapd/hostapd.conf
          echo "rsn_pairwise=CCMP"                                                                                         >> /etc/hostapd/hostapd.conf
          echo "ignore_broadcast_ssid=0"                                                                                   >> /etc/hostapd/hostapd.conf
          echo "eap_reauth_period=360000000"                                                                               >> /etc/hostapd/hostapd.conf
          echo "ssid=RouterX86"                                                                                            >> /etc/hostapd/hostapd.conf
          echo "wpa_passphrase=RouterX86"                                                                                  >> /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "#Tarjeta TP-LINK TL-WDN4800 Atheros 9380 (168c:0030)"                                                      >> /etc/hostapd/hostapd.conf
          echo "driver=nl80211"                                                                                            >> /etc/hostapd/hostapd.conf
          echo "channel=0                               # El canal a usar. 0 buscará el canal con menos interferencias"    >> /etc/hostapd/hostapd.conf
          echo "hw_mode=a"                                                                                                 >> /etc/hostapd/hostapd.conf
          echo "ieee80211n=1"                                                                                              >> /etc/hostapd/hostapd.conf
          echo "wme_enabled=1"                                                                                             >> /etc/hostapd/hostapd.conf
          echo "wmm_enabled=1                           # Soporte para QoS"                                                >> /etc/hostapd/hostapd.conf
          echo "ieee80211d=1                            # Limitar las frecuencias sólo a las disponibles en el país"       >> /etc/hostapd/hostapd.conf
          echo "country_code=ES"                                                                                           >> /etc/hostapd/hostapd.conf
          echo "ht_capab=[RXLDPC][HT20+][HT40+][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]" >> /etc/hostapd/hostapd.conf
          systemctl unmask hostapd
          systemctl enable hostapd
          systemctl start hostapd

          echo ""
          echo "    Configurando interfaces de red..."
          echo ""
          cp /etc/network/interfaces /etc/network/interfaces.bak
          echo "auto lo"                                                                                     > /etc/network/interfaces
          echo "  iface lo inet loopback"                                                                   >> /etc/network/interfaces
          echo "  pre-up iptables-restore < /root/ReglasIPTablesV4RouterBR0"                                >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazWAN"                                                                         >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazWAN"                                                              >> /etc/network/interfaces
          echo "  iface $vInterfazWAN inet dhcp"                                                            >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazWLAN1"                                                                       >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazWLAN1"                                                            >> /etc/network/interfaces
          echo "  iface $vInterfazWLAN1 inet manual"                                                        >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN1"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN1"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN1 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN2"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN2"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN2 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN3"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN3"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN3 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN4"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN4"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN4 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto br0"                                                                                   >> /etc/network/interfaces
          echo "  iface br0 inet static"                                                                    >> /etc/network/interfaces
          echo "  network 192.168.2.0"                                                                      >> /etc/network/interfaces
          echo "  address 192.168.2.1"                                                                      >> /etc/network/interfaces
          echo "  broadcast 192.168.2.255"                                                                  >> /etc/network/interfaces
          echo "  netmask 255.255.255.0"                                                                    >> /etc/network/interfaces
          echo "  bridge-ports $vInterfazWLAN1 $vInterfazLAN1 $vInterfazLAN2 $vInterfazLAN3 $vInterfazLAN4" >> /etc/network/interfaces

          echo ""
          echo "    Descargando archivo de nombres de fabricantes..."
          echo ""
          wget -O /usr/local/etc/oui.txt http://standards-oui.ieee.org/oui/oui.txt
        ;;

        5)
          echo ""
          echo "  Instalando el servidor DNS..."
          echo ""
          apt-get -y update
          apt-get -y install bind9
          apt-get -y install dnsutils
          service bind9 restart
          sed -i "1s|^|nameserver 127.0.0.1\n|" /etc/resolv.conf
          sed -i -e 's|// forwarders {|forwarders {|g' /etc/bind/named.conf.options
          sed -i "/0.0.0.0;/c\1.1.1.1;"                /etc/bind/named.conf.options
          sed -i -e 's|// };|};|g'                     /etc/bind/named.conf.options
          echo 'zone "prueba.com" {'               >> /etc/bind/named.conf.local
          echo "  type master;"                    >> /etc/bind/named.conf.local
          echo '  file "/etc/bind/db.prueba.com";' >> /etc/bind/named.conf.local
          echo "};"                                >> /etc/bind/named.conf.local
          service bind9 restart
        ;;

        6)
          echo ""
          echo "  Reiniciando el sistema..."
          echo ""
          shutdown -r now
        ;;

      esac

    done

elif [ $OS_VERS == "11" ]; then

  echo ""
  echo -e "${ColorAzulClaro}Iniciando el script de preparación de Debian 11 (Bullseye) para que routee por br0...${FinColor}"
  echo ""

  # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${ColorRojo}  dialog no está instalado. Iniciando su instalación...${FinColor}"
      echo ""
      apt-get -y update && apt-get -y install dialog
      echo ""
    fi

  cmd=(dialog --checklist "Opciones del script:" 22 76 16)
  options=(
    1 "Agregar todos los repositorios" on
    2 "Actualizar el sistema" on
    3 "Instalar paquetes necesarios" on
    4 "Crear o reemplazar archivos de configuración" on
    5 "Instalar servidor DNS" on
    6 "Reiniciar el sistema" on
  )
  choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear
  for choice in $choices
    do
      case $choice in
        1)
          echo ""
          echo "  Agregando todos los repositorios..."
          echo ""
          cp /etc/apt/sources.list /etc/apt/sources.list.bak
          echo "deb http://deb.debian.org/debian bullseye main contrib non-free"                         > /etc/apt/sources.list
          echo "deb-src http://deb.debian.org/debian bullseye main contrib non-free"                    >> /etc/apt/sources.list
          echo ""                                                                                       >> /etc/apt/sources.list
          echo "deb http://deb.debian.org/debian-security/ bullseye-security main contrib non-free"     >> /etc/apt/sources.list
          echo "deb-src http://deb.debian.org/debian-security/ bullseye-security main contrib non-free" >> /etc/apt/sources.list
          echo ""                                                                                       >> /etc/apt/sources.list
          echo "deb http://deb.debian.org/debian bullseye-updates main contrib non-free"                >> /etc/apt/sources.list
          echo "deb-src http://deb.debian.org/debian bullseye-updates main contrib non-free"            >> /etc/apt/sources.list
          echo ""                                                                                       >> /etc/apt/sources.list
        ;;

        2)
          echo ""
          echo "   Actualizando el sistema..."
          echo ""
          apt-get update
          apt-get -y upgrade
          apt-get -y dist-upgrade
          apt-get autoremove
        ;;

        3)
          echo ""
          echo "   Instalando paquetes necesarios..."
          echo ""
          apt-get -y install isc-dhcp-server
          apt-get -y install hostapd
          apt-get -y install bridge-utils
          apt-get -y install crda
          apt-get -y install firmware-linux-nonfree
        ;;

        4)
          echo ""
          echo "  Creando o reemplazando archivos de configuración..."
          echo ""

          echo ""
          echo "    Creando las reglas NFTables..."
          echo ""
          echo "table inet filter {"                                                               > /root/ReglasNFTablesV4RouterBR0
          echo "}"                                                                                >> /root/ReglasNFTablesV4RouterBR0
          echo ""                                                                                 >> /root/ReglasNFTablesV4RouterBR0
          echo "table ip nat {"                                                                   >> /root/ReglasNFTablesV4RouterBR0
          echo "  chain postrouting {"                                                            >> /root/ReglasNFTablesV4RouterBR0
          echo "    type nat hook postrouting priority 100; policy accept;"                       >> /root/ReglasNFTablesV4RouterBR0
          echo '    oifname "'"$vInterfazWAN"'" ip saddr 192.168.2.0/24 counter masquerade'       >> /root/ReglasNFTablesV4RouterBR0
          echo "  }"                                                                              >> /root/ReglasNFTablesV4RouterBR0
          echo ""                                                                                 >> /root/ReglasNFTablesV4RouterBR0
          echo "  chain prerouting {"                                                             >> /root/ReglasNFTablesV4RouterBR0
          echo "    type nat hook prerouting priority 0; policy accept;"                          >> /root/ReglasNFTablesV4RouterBR0
          echo '    iifname "'"$vInterfazWAN"'" tcp dport 33892 counter dnat to 192.168.2.2:3389' >> /root/ReglasNFTablesV4RouterBR0
          echo '    iifname "'"$vInterfazWAN"'" tcp dport 33893 counter dnat to 192.168.2.3:3389' >> /root/ReglasNFTablesV4RouterBR0
          echo '    iifname "'"$vInterfazWAN"'" tcp dport 33894 counter dnat to 192.168.2.4:3389' >> /root/ReglasNFTablesV4RouterBR0
          echo "  }"                                                                              >> /root/ReglasNFTablesV4RouterBR0
          echo "}"                                                                                >> /root/ReglasNFTablesV4RouterBR0
          # Agregar las reglas al archivo de configuración de NFTables
            sed -i '/^flush ruleset/a include "/root/ReglasNFTablesV4RouterBR0"' /etc/nftables.conf
            sed -i -e 's|flush ruleset|flush ruleset\n|g'                        /etc/nftables.conf
          # Recargar las reglas generales de NFTables
            nft --file /etc/nftables.conf
          # Agregar las reglas a los ComandosPostArranque
            sed -i -e 's|nft --file /etc/nftables.conf||g' /root/scripts/ComandosPostArranque.sh
            echo "nft --file /etc/nftables.conf" >>        /root/scripts/ComandosPostArranque.sh

          echo ""
          echo "    Habilitando el forwarding IPv4 entre interfaces..."
          echo ""
          cp /etc/sysctl.conf /etc/sysctl.conf.bak
          sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

          echo ""
          echo "    Indicando la ubicación de la configuración del daemon hostapd..."
          echo ""
          cp /etc/default/hostapd /etc/default/hostapd.bak
          sed -i -e 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g'      /etc/default/hostapd
          sed -i -e 's|#DAEMON_OPTS=""|DAEMON_OPTS="-dd -t -f /var/log/hostapd.log"|g' /etc/default/hostapd
          echo ""

          echo ""
          echo "    Indicando la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá..."
          echo ""
          cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
          echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'  > /etc/default/isc-dhcp-server
          echo 'INTERFACESv4="br0"'                >> /etc/default/isc-dhcp-server
          echo 'INTERFACESv6=""'                   >> /etc/default/isc-dhcp-server

          echo ""
          echo "    Configurando el servidor DHCP..."
          echo ""
          cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
          echo "authoritative;"                                  > /etc/dhcp/dhcpd.conf
          echo "subnet 192.168.2.0 netmask 255.255.255.0 {"     >> /etc/dhcp/dhcpd.conf
          echo "  range 192.168.2.100 192.168.2.199;"           >> /etc/dhcp/dhcpd.conf
          echo "  option routers 192.168.2.1;"                  >> /etc/dhcp/dhcpd.conf
          echo "  option domain-name-servers 1.1.1.1, 1.0.0.1;" >> /etc/dhcp/dhcpd.conf
          echo "  default-lease-time 600;"                      >> /etc/dhcp/dhcpd.conf
          echo "  max-lease-time 7200;"                         >> /etc/dhcp/dhcpd.conf
          echo ""                                               >> /etc/dhcp/dhcpd.conf
          echo "  host PrimeraReserva {"                        >> /etc/dhcp/dhcpd.conf
          echo "    hardware ethernet 00:00:00:00:00:10;"       >> /etc/dhcp/dhcpd.conf
          echo "    fixed-address 192.168.2.10;"                >> /etc/dhcp/dhcpd.conf
          echo "  }"                                            >> /etc/dhcp/dhcpd.conf
          echo "}"                                              >> /etc/dhcp/dhcpd.conf

          echo ""
          echo "    Configurando el demonio hostapd..."
          echo ""
          echo "#/etc/hostapd/hostapd.conf"                                                                                 > /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "# Punto de acceso básico"                                                                                  >> /etc/hostapd/hostapd.conf
          echo "#bridge=br0"                                                                                               >> /etc/hostapd/hostapd.conf
          echo "#interface=wlan0"                                                                                          >> /etc/hostapd/hostapd.conf
          echo "#ssid=BasicAP"                                                                                             >> /etc/hostapd/hostapd.conf
          echo "#channel=0"                                                                                                >> /etc/hostapd/hostapd.conf
          echo "#hw_mode=a"                                                                                                >> /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "# Primer punto de acceso"                                                                                  >> /etc/hostapd/hostapd.conf
          echo "bridge=br0"                                                                                                >> /etc/hostapd/hostapd.conf
          echo "interface=$vInterfazWLAN1"                                                                                 >> /etc/hostapd/hostapd.conf
          echo "wpa=2"                                                                                                     >> /etc/hostapd/hostapd.conf
          echo "wpa_key_mgmt=WPA-PSK"                                                                                      >> /etc/hostapd/hostapd.conf
          echo "wpa_pairwise=TKIP"                                                                                         >> /etc/hostapd/hostapd.conf
          echo "rsn_pairwise=CCMP"                                                                                         >> /etc/hostapd/hostapd.conf
          echo "ignore_broadcast_ssid=0"                                                                                   >> /etc/hostapd/hostapd.conf
          echo "eap_reauth_period=360000000"                                                                               >> /etc/hostapd/hostapd.conf
          echo "ssid=RouterX86"                                                                                            >> /etc/hostapd/hostapd.conf
          echo "wpa_passphrase=RouterX86"                                                                                  >> /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "#Tarjeta TP-LINK TL-WDN4800 Atheros 9380 (168c:0030)"                                                      >> /etc/hostapd/hostapd.conf
          echo "driver=nl80211"                                                                                            >> /etc/hostapd/hostapd.conf
          echo "channel=0                               # El canal a usar. 0 buscará el canal con menos interferencias"    >> /etc/hostapd/hostapd.conf
          echo "hw_mode=a"                                                                                                 >> /etc/hostapd/hostapd.conf
          echo "ieee80211n=1"                                                                                              >> /etc/hostapd/hostapd.conf
          echo "wme_enabled=1"                                                                                             >> /etc/hostapd/hostapd.conf
          echo "wmm_enabled=1                           # Soporte para QoS"                                                >> /etc/hostapd/hostapd.conf
          echo "ieee80211d=1                            # Limitar las frecuencias sólo a las disponibles en el país"       >> /etc/hostapd/hostapd.conf
          echo "country_code=ES"                                                                                           >> /etc/hostapd/hostapd.conf
          echo "ht_capab=[RXLDPC][HT20+][HT40+][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]" >> /etc/hostapd/hostapd.conf
          systemctl unmask hostapd
          systemctl enable hostapd
          systemctl start hostapd

          echo ""
          echo "    Configurando interfaces de red..."
          echo ""
          cp /etc/network/interfaces /etc/network/interfaces.bak
          echo "auto lo"                                                                                     > /etc/network/interfaces
          echo "  iface lo inet loopback"                                                                   >> /etc/network/interfaces
          echo "  pre-up nft --file /etc/nftables.conf"                                                     >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazWAN"                                                                         >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazWAN"                                                              >> /etc/network/interfaces
          echo "  iface $vInterfazWAN inet dhcp"                                                            >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazWLAN1"                                                                       >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazWLAN1"                                                            >> /etc/network/interfaces
          echo "  iface $vInterfazWLAN1 inet manual"                                                        >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN1"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN1"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN1 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN2"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN2"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN2 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN3"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN3"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN3 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto $vInterfazLAN4"                                                                        >> /etc/network/interfaces
          echo "  allow-hotplug $vInterfazLAN4"                                                             >> /etc/network/interfaces
          echo "  iface $vInterfazLAN4 inet manual"                                                         >> /etc/network/interfaces
          echo ""                                                                                           >> /etc/network/interfaces
          echo "auto br0"                                                                                   >> /etc/network/interfaces
          echo "  iface br0 inet static"                                                                    >> /etc/network/interfaces
          echo "  network 192.168.2.0"                                                                      >> /etc/network/interfaces
          echo "  address 192.168.2.1"                                                                      >> /etc/network/interfaces
          echo "  broadcast 192.168.2.255"                                                                  >> /etc/network/interfaces
          echo "  netmask 255.255.255.0"                                                                    >> /etc/network/interfaces
          echo "  bridge-ports $vInterfazWLAN1 $vInterfazLAN1 $vInterfazLAN2 $vInterfazLAN3 $vInterfazLAN4" >> /etc/network/interfaces

          echo ""
          echo "    Descargando archivo de nombres de fabricantes..."
          echo ""
          wget -O /usr/local/etc/oui.txt http://standards-oui.ieee.org/oui/oui.txt
        ;;

        5)
          echo ""
          echo "  Instalando el servidor DNS..."
          echo ""
          apt-get -y update
          apt-get -y install bind9
          apt-get -y install dnsutils
          service bind9 restart
          sed -i "1s|^|nameserver 127.0.0.1\n|" /etc/resolv.conf
          sed -i -e 's|// forwarders {|forwarders {|g' /etc/bind/named.conf.options
          sed -i "/0.0.0.0;/c\1.1.1.1;"                /etc/bind/named.conf.options
          sed -i -e 's|// };|};|g'                     /etc/bind/named.conf.options
          echo 'zone "prueba.com" {'               >> /etc/bind/named.conf.local
          echo "  type master;"                    >> /etc/bind/named.conf.local
          echo '  file "/etc/bind/db.prueba.com";' >> /etc/bind/named.conf.local
          echo "};"                                >> /etc/bind/named.conf.local
          service bind9 restart
        ;;

        6)
          echo ""
          echo "  Reiniciando el sistema..."
          echo ""
          shutdown -r now
        ;;

      esac

    done

fi

