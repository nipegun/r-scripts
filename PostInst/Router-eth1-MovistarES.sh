#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para preparar un Debian recién instalado para que pueda conectarse
#  a una ONT que esté recibiendo la fibra de Movistar ES y pueda routear una conexión
#  de internet a través la la interfaz LAN
#
#  Ejecución remota:
#  curl -s x | bash
# ----------

InterfazCableada1=eth0
InterfazCableada2=eth1
UsuarioPPPMovistar="adslppp@telefonicanetpa"
ClavePPPMovistar="adslppp"
IPDeIPTV="2.2.2.2"
MacWANDelRouterMovistar="00:00:00:00:00:00"

ColorRojo='\033[1;31m'
ColorVerde='\033[1;32m'
FinColor='\033[0m'

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
  echo "-----------------------------------------------------------------------------"
  echo "  Iniciando el script de instalación de xxxxxxxxx para Debian 7 (Wheezy)..."
  echo "-----------------------------------------------------------------------------"
  echo ""

  echo ""
  echo "  Comandos para Debian 7 todavía no preparados. Prueba ejecutar el script en otra versión de Debian."
  echo ""

elif [ $OS_VERS == "8" ]; then

  echo ""
  echo "-----------------------------------------------------------------------------"
  echo "  Iniciando el script de instalación de xxxxxxxxx para Debian 8 (Jessie)..."
  echo "-----------------------------------------------------------------------------"
  echo ""

  echo ""
  echo "  Comandos para Debian 8 todavía no preparados. Prueba ejecutar el script en otra versión de Debian."
  echo ""

elif [ $OS_VERS == "9" ]; then

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "  Iniciando el script de instalación de xxxxxxxxx para Debian 9 (Stretch)..."
  echo "------------------------------------------------------------------------------"
  echo ""

  echo ""
  echo "  Comandos para Debian 9 todavía no preparados. Prueba ejecutar el script en otra versión de Debian."
  echo ""

elif [ $OS_VERS == "10" ]; then

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "  Iniciando el script de instalación de xxxxxxxxx para Debian 10 (Buster)..."
  echo "------------------------------------------------------------------------------"
  echo ""

  echo ""
  echo -e "${ColorVerde}------------------------------------------------------------------${FinColor}"
  echo -e "${ColorVerde}Iniciando el script para conectar Debian con la ONT de Movistar...${FinColor}"
  echo -e "${ColorVerde}------------------------------------------------------------------${FinColor}"
  echo ""

  echo ""
  echo -e "${ColorVerde}Instalando el servidor SSH...${FinColor}"
  echo ""
  apt-get update
  apt-get -y install tasksel
  tasksel install ssh-server

  echo ""
  echo -e "${ColorVerde}Instalando paquetes de red...${FinColor}"
  echo ""
  apt-get -y install vlan pppoe isc-dhcp-server wget

  echo ""
  echo -e "${ColorVerde}Activando el módulo 8021q para VLANs...${FinColor}"
  echo ""
  echo 8021q >> /etc/modules

  echo ""
  echo -e "${ColorVerde}Configurando la interfaz loopback...${FinColor}"
  echo ""
  echo "auto lo"                                                                > /etc/network/interfaces
  echo "  iface lo inet loopback"                                              >> /etc/network/interfaces
  echo "  pre-up iptables-restore < /root/ReglasIPTablesIP4RouterMovistar.ipt" >> /etc/network/interfaces
  echo ""                                                                      >> /etc/network/interfaces

  echo ""
  echo -e "${ColorVerde}Configurando la interfaz WAN...${FinColor}"
  echo ""
  echo "auto $InterfazCableada1"                                                               >> /etc/network/interfaces
  echo "  allow-hotplug $InterfazCableada1"                                                    >> /etc/network/interfaces
  echo "  iface $InterfazCableada1 inet manual"                                                >> /etc/network/interfaces
  echo "  #hwaddress ether $MacWANDelRouterMovistar # Necesario para evitar futuros problemas" >> /etc/network/interfaces
  echo ""                                                                                      >> /etc/network/interfaces

  echo ""
  echo -e "${ColorVerde}Configurando la vlan de datos (6) y prioridad (1)...${FinColor}"
  echo ""
  echo "# VLAN de Datos"                                                                                    >> /etc/network/interfaces
  echo "auto $InterfazCableada1.6"                                                                          >> /etc/network/interfaces
  echo "  iface $InterfazCableada1.6 inet manual"                                                           >> /etc/network/interfaces
  echo "  #vlan-raw-device $InterfazCableada1 # Necesario si la vlan se crea con un nombre no convencional" >> /etc/network/interfaces
  echo "  metric 1"                                                                                         >> /etc/network/interfaces
  echo ""                                                                                                   >> /etc/network/interfaces

  echo ""
  echo -e "${ColorVerde}Configurando la conexión PPP...${FinColor}"
  echo ""
  echo "auto MovistarWAN"                                  >> /etc/network/interfaces
  echo "  iface MovistarWAN inet ppp"                      >> /etc/network/interfaces
  echo "  pre-up /bin/ip link set $InterfazCableada1.6 up" >> /etc/network/interfaces
  echo "  provider MovistarWAN"                            >> /etc/network/interfaces
  echo ""                                                  >> /etc/network/interfaces

  echo ""
  echo -e "${ColorVerde}Configurando la vlan de voz (3) y prioridad (4)...${FinColor}"
  echo ""
  echo "# VLAN de VoIP"                                                                                     >> /etc/network/interfaces
  echo "auto $InterfazCableada1.3"                                                                          >> /etc/network/interfaces
  echo "  iface $InterfazCableada1.3 inet dhcp"                                                             >> /etc/network/interfaces
  echo "  #vlan-raw-device $InterfazCableada1 # Necesario si la vlan se crea con un nombre no convencional" >> /etc/network/interfaces
  echo "  metric 4"                                                                                         >> /etc/network/interfaces
  echo ""                                                                                                   >> /etc/network/interfaces

  echo ""
  echo -e "${ColorVerde}Configurando la vlan de televisión (2) y prioridad (4)...${FinColor}"
  echo ""
  echo "# VLAN de IPTV"                                                                                     >> /etc/network/interfaces
  echo "auto $InterfazCableada1.2"                                                                          >> /etc/network/interfaces
  echo "  iface $InterfazCableada1.2 inet static"                                                           >> /etc/network/interfaces
  echo "  address $IPDeIPTV"                                                                                >> /etc/network/interfaces
  echo "  #vlan-raw-device $InterfazCableada1 # Necesario si la vlan se crea con un nombre no convencional" >> /etc/network/interfaces
  echo "  metric 4"                                                                                         >> /etc/network/interfaces
  echo ""                                                                                                   >> /etc/network/interfaces

  echo ""
  echo -e "${ColorVerde}Configurando la interfaz LAN...${FinColor}"
  echo ""
  echo "auto $InterfazCableada2"                                                                                                >> /etc/network/interfaces
  echo "  iface $InterfazCableada2 inet static"                                                                                 >> /etc/network/interfaces
  echo "  address 192.168.0.1"                                                                                                  >> /etc/network/interfaces
  echo "  network 192.168.0.0"                                                                                                  >> /etc/network/interfaces
  echo "  netmask 255.255.255.0"                                                                                                >> /etc/network/interfaces
  echo "  broadcast 192.168.0.255"                                                                                              >> /etc/network/interfaces
  echo "  post-up   echo 1 > /proc/sys/net/ipv4/ip_forward"                                                                     >> /etc/network/interfaces
  echo "  post-down echo 0 > /proc/sys/net/ipv4/ip_forward"                                                                     >> /etc/network/interfaces
  echo "  post-up   iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE"                                                       >> /etc/network/interfaces 
  echo "  post-down iptables -t nat -D POSTROUTING -o ppp0 -j MASQUERADE"                                                       >> /etc/network/interfaces
  echo "  post-up   iptables -t filter -A FORWARD -i ppp0 -o $InterfazCableada2 -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /etc/network/interfaces
  echo "  post-down iptables -t filter -D FORWARD -i ppp0 -o $InterfazCableada2 -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /etc/network/interfaces
  echo "  post-up   iptables -t filter -A FORWARD -i $InterfazCableada2 -o ppp0 -j ACCEPT"                                      >> /etc/network/interfaces
  echo "  post-down iptables -t filter -D FORWARD -i $InterfazCableada2 -o ppp0 -j ACCEPT"                                      >> /etc/network/interfaces
  echo ""                                                                                                                       >> /etc/network/interfaces

  echo ""
  echo -e "${ColorVerde}Creando el archivo para el proveedor PPPoE...${FinColor}"
  echo ""
  echo "connect /bin/true"                        > /etc/ppp/peers/MovistarWAN
  echo "default-asyncmap"                        >> /etc/ppp/peers/MovistarWAN
  echo "defaultroute"                            >> /etc/ppp/peers/MovistarWAN
  echo "hide-password"                           >> /etc/ppp/peers/MovistarWAN
  echo "holdoff 3"                               >> /etc/ppp/peers/MovistarWAN
  echo "ipcp-accept-local"                       >> /etc/ppp/peers/MovistarWAN
  echo "ipcp-accept-remote"                      >> /etc/ppp/peers/MovistarWAN
  echo "lcp-echo-interval 15"                    >> /etc/ppp/peers/MovistarWAN
  echo "lcp-echo-failure 3"                      >> /etc/ppp/peers/MovistarWAN
  echo "lock"                                    >> /etc/ppp/peers/MovistarWAN
  echo "mru 1492"                                >> /etc/ppp/peers/MovistarWAN
  echo "mtu 1492"                                >> /etc/ppp/peers/MovistarWAN
  echo "noaccomp"                                >> /etc/ppp/peers/MovistarWAN
  echo "noauth"                                  >> /etc/ppp/peers/MovistarWAN
  echo "nobsdcomp"                               >> /etc/ppp/peers/MovistarWAN
  echo "noccp"                                   >> /etc/ppp/peers/MovistarWAN
  echo "nodeflate"                               >> /etc/ppp/peers/MovistarWAN
  echo "noipdefault"                             >> /etc/ppp/peers/MovistarWAN
  echo "nopcomp"                                 >> /etc/ppp/peers/MovistarWAN
  echo "novj"                                    >> /etc/ppp/peers/MovistarWAN
  echo "novjccomp"                               >> /etc/ppp/peers/MovistarWAN
  echo "persist"                                 >> /etc/ppp/peers/MovistarWAN
  echo "plugin rp-pppoe.so"                      >> /etc/ppp/peers/MovistarWAN
  echo "nic-$InterfazCableada1.6"                >> /etc/ppp/peers/MovistarWAN
  echo "updetach"                                >> /etc/ppp/peers/MovistarWAN
  echo "usepeerdns"                              >> /etc/ppp/peers/MovistarWAN
  echo 'user "'$UsuarioPPPMovistar'"'            >> /etc/ppp/peers/MovistarWAN

  echo ""
  echo -e "${ColorVerde}Creando el archivo chap-secrets...${FinColor}"
  echo ""
  echo '"'$UsuarioPPPMovistar'" * "'$ClavePPPMovistar'"' > /etc/ppp/chap-secrets

  echo ""
  echo -e "${ColorVerde}Agregando datos al archivo pap-secrets...${FinColor}"
  echo ""
  echo '"'$UsuarioPPPMovistar'" * "'$ClavePPPMovistar'"' >> /etc/ppp/pap-secrets

  echo ""
  echo -e "${ColorVerde}Indicando la ubicación del archivo de configuración del demonio dhcpd${FinColor}"
  echo -e "${ColorVerde}y la interfaz sobre la que correrá...${FinColor}"
  echo ""
  cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
  echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'  > /etc/default/isc-dhcp-server
  echo 'INTERFACESv4="$InterfazCableada2"' >> /etc/default/isc-dhcp-server
  echo 'INTERFACESv6=""'                   >> /etc/default/isc-dhcp-server

  echo ""
  echo -e "${ColorVerde}Configurando el servidor DHCP...${FinColor}"
  echo ""
  cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
  echo "authoritative;"                                  > /etc/dhcp/dhcpd.conf
  echo "subnet 192.168.0.0 netmask 255.255.255.0 {"     >> /etc/dhcp/dhcpd.conf
  echo "  range 192.168.0.100 192.168.0.199;"           >> /etc/dhcp/dhcpd.conf
  echo "  option routers 192.168.0.1;"                  >> /etc/dhcp/dhcpd.conf
  echo "  option domain-name-servers 1.1.1.1, 1.0.0.1;" >> /etc/dhcp/dhcpd.conf
  echo "  default-lease-time 600;"                      >> /etc/dhcp/dhcpd.conf
  echo "  max-lease-time 7200;"                         >> /etc/dhcp/dhcpd.conf
  echo ""                                               >> /etc/dhcp/dhcpd.conf
  echo "  host PrimeraReserva {"                        >> /etc/dhcp/dhcpd.conf
  echo "    hardware ethernet 00:00:00:00:00:01;"       >> /etc/dhcp/dhcpd.conf
  echo "    fixed-address 192.168.0.10;"                >> /etc/dhcp/dhcpd.conf
  echo "  }"                                            >> /etc/dhcp/dhcpd.conf
  echo "}"                                              >> /etc/dhcp/dhcpd.conf

  echo ""
  echo -e "${ColorVerde}Descargando archivos de nombres de fabricantes...${FinColor}"
  echo ""
  wget -O /usr/local/etc/oui.txt http://standards-oui.ieee.org/oui/oui.txt

  #echo ""
  #echo -e "${ColorVerde}Agregando la conexión ppp0 a los ComandosPostArranque...${FinColor}"
  #echo ""
  #echo "pon MovistarWAN" >> /root/scripts/ComandosPostArranque.sh

  echo ""
  echo -e "${ColorVerde}--------------------------------------------------------------------------------------------${FinColor}"
  echo -e "${ColorVerde}Ejecución del script de conexión de Debian con la fibra de Movistar, finalizada.${FinColor}"
  echo ""
  echo -e "${ColorVerde}Ya puedes apagar Debian ejecutando:${FinColor}"
  echo "shutdown -h now"
  echo -e "${ColorVerde}y conectarle el cable ethernet a la ONT the Movistar.${FinColor}"
  echo ""
  echo -e "${ColorVerde}Después de encenderlo de nuevo, PVE debería tener internet a través de la interfaz ppp0${FinColor}"
  echo -e "${ColorVerde}Si por alguna razón la interfaz ppp0 no se levanta, puedes levantarla manualmente ejecutando:${FinColor}"
  echo "pon MovistarWAN"
  echo -e "${ColorVerde}--------------------------------------------------------------------------------------------${FinColor}"
  echo ""

elif [ $OS_VERS == "11" ]; then

  echo ""
  echo "--------------------------------------------------------------------------------"
  echo "  Iniciando el script de instalación de xxxxxxxxx para Debian 11 (Bullseye)..."
  echo "--------------------------------------------------------------------------------"
  echo ""

  echo ""
  echo "  Comandos para Debian 11 todavía no preparados. Prueba ejecutar el script en otra versión de Debian."
  echo ""

fi

