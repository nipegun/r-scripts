#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para conectar un Armbian recién instalado en la NanoPi R2S con una ONT de movistar.
#  para que pueda conectarse a una ONT que esté recibiendo la fibra de Movistar ES
#  y pueda routear una conexión de internet a través la la interfaz LAN
#
#  Ejecución remota:
#  curl -s x | bash
# ----------

vInterfazWAN=eth0
vInterfazLAN=lan0
vUsuarioPPPMovistar="adslppp@telefonicanetpa"
vClavePPPMovistar="adslppp"
vIPDeIPTV="2.2.2.2"
vMacWANDelRouterMovistar="00:00:00:00:00:00"
vMacDelRouterAConectarAlPuertoLAN="00:00:00:00:00:00"

vColorAzul="\033[0;34m"
vColorAzulClaro="\033[1;34m"
vColorVerde='\033[1;32m'
vColorRojo='\033[1;31m'
vFinColor='\033[0m'

# Determinar la versión de Debian
  if [ -f /etc/os-release ]; then # Para systemd y freedesktop.org
    . /etc/os-release
    OS_NAME=$NAME
    OS_VERS=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then # linuxbase.org
    OS_NAME=$(lsb_release -si)
    OS_VERS=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then # Para algunas versiones de Debian sin el comando lsb_release
    . /etc/lsb-release
    OS_NAME=$DISTRIB_ID
    OS_VERS=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then # Para versiones viejas de Debian.
    OS_NAME=Debian
    OS_VERS=$(cat /etc/debian_version)
  else # Para el viejo uname (También funciona para BSD)
    OS_NAME=$(uname -s)
    OS_VERS=$(uname -r)
  fi

if [ $OS_VERS == "7" ]; then

  echo ""
  echo -e "${vColorAzulClaro}Iniciando el script para conectar Debian 7 (Wheezy) con la ONT de Movistar...${vFinColor}"
  echo ""

  echo ""
  echo -e "${vColorRojo}  Comandos para Debian 7 todavía no preparados. Prueba ejecutar el script en otra versión de Debian.${vFinColor}"
  echo ""

elif [ $OS_VERS == "8" ]; then

  echo ""
  echo -e "${vColorAzulClaro}Iniciando el script para conectar Debian 8 (Jessie) con la ONT de Movistar...${vFinColor}"
  echo ""

  echo ""
  echo -e "${vColorRojo}  Comandos para Debian 8 todavía no preparados. Prueba ejecutar el script en otra versión de Debian.${vFinColor}"
  echo ""

elif [ $OS_VERS == "9" ]; then

  echo ""
  echo -e "${vColorAzulClaro}Iniciando el script para conectar Debian 9 (Stretch) con la ONT de Movistar...${vFinColor}"
  echo ""

  echo ""
  echo -e "${vColorRojo}  Comandos para Debian 9 todavía no preparados. Prueba ejecutar el script en otra versión de Debian.${vFinColor}"
  echo ""

elif [ $OS_VERS == "10" ]; then

  echo ""
  echo -e "${vColorAzulClaro}Iniciando el script para conectar Debian 10 (Buster) con la ONT de Movistar...${vFinColor}"
  echo ""

  echo ""
  echo "  Instalando paquetes de red..."
  echo ""
  apt-get -y update
  apt-get -y install vlan
  apt-get -y install pppoe
  apt-get -y install isc-dhcp-server wget

  echo ""
  echo "  Activando el módulo 8021q para VLANs..."
  echo ""
  if grep -Fxq "8021q" /etc/modules
    then
      echo ""
      echo "    El módulo ya está activado en /etc/modules. No hace falta activarlo."
      echo ""
    else
      echo "8021q" >> /etc/modules
    fi

  echo ""
  echo "  Configurando la interfaz loopback..."
  echo ""
  echo "auto lo"                   > /etc/network/interfaces
  echo "  iface lo inet loopback" >> /etc/network/interfaces
  echo ""                         >> /etc/network/interfaces

  echo ""
  echo "  Configurando la interfaz WAN..."
  echo ""
  echo "auto $vInterfazWAN"                                                                     >> /etc/network/interfaces
  echo "  allow-hotplug $vInterfazWAN"                                                          >> /etc/network/interfaces
  echo "  iface $vInterfazWAN inet manual"                                                      >> /etc/network/interfaces
  echo "  #hwaddress ether $vMacWANDelRouterMovistar # Necesario para evitar futuros problemas" >> /etc/network/interfaces
  echo ""                                                                                       >> /etc/network/interfaces

  echo ""
  echo "  Configurando la vlan de datos (6) y prioridad (1)..."
  echo ""
  echo "# VLAN de Datos"                                                                               >> /etc/network/interfaces
  echo "auto $vInterfazWAN.6"                                                                          >> /etc/network/interfaces
  echo "  iface $vInterfazWAN.6 inet manual"                                                           >> /etc/network/interfaces
  echo "  vlan-raw-device $vInterfazWAN # Necesario si la vlan se crea con un nombre no convencional"  >> /etc/network/interfaces
  echo "  metric 1"                                                                                    >> /etc/network/interfaces
  echo ""                                                                                              >> /etc/network/interfaces

  echo ""
  echo "  Configurando la vlan de voz (3) y prioridad (4)..."
  echo ""
  echo "# VLAN de VoIP"                                                                                >> /etc/network/interfaces
  echo "#auto $vInterfazWAN.3"                                                                         >> /etc/network/interfaces
  echo "#  iface $vInterfazWAN.3 inet dhcp"                                                            >> /etc/network/interfaces
  echo "#  vlan-raw-device $vInterfazWAN # Necesario si la vlan se crea con un nombre no convencional" >> /etc/network/interfaces
  echo "#  metric 4"                                                                                   >> /etc/network/interfaces
  echo ""                                                                                              >> /etc/network/interfaces

  echo ""
  echo "  Configurando la vlan de televisión (2) y prioridad (4)..."
  echo ""
  echo "# VLAN de IPTV"                                                                                 >> /etc/network/interfaces
  echo "#auto $vInterfazWAN.2"                                                                          >> /etc/network/interfaces
  echo "#  iface $vInterfazWAN.2 inet static"                                                           >> /etc/network/interfaces
  echo "#  address $vIPDeIPTV"                                                                          >> /etc/network/interfaces
  echo "#  vlan-raw-device $vInterfazWAN # Necesario si la vlan se crea con un nombre no convencional"  >> /etc/network/interfaces
  echo "#  metric 4"                                                                                    >> /etc/network/interfaces
  echo ""                                                                                               >> /etc/network/interfaces

  echo ""
  echo "  Configurando la interfaz LAN..."
  echo ""
  echo "auto $vInterfazLAN"                                                                                                >> /etc/network/interfaces
  echo "  iface $vInterfazLAN inet static"                                                                                 >> /etc/network/interfaces
  echo "  address 192.168.0.1"                                                                                             >> /etc/network/interfaces
  echo "  network 192.168.0.0"                                                                                             >> /etc/network/interfaces
  echo "  netmask 255.255.255.0"                                                                                           >> /etc/network/interfaces
  echo "  broadcast 192.168.0.255"                                                                                         >> /etc/network/interfaces
  echo "  post-up   echo 1 > /proc/sys/net/ipv4/ip_forward"                                                                >> /etc/network/interfaces
  echo "  post-down echo 0 > /proc/sys/net/ipv4/ip_forward"                                                                >> /etc/network/interfaces
  echo "  post-up   iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE"                                                  >> /etc/network/interfaces
  echo "  post-down iptables -t nat -D POSTROUTING -o ppp0 -j MASQUERADE"                                                  >> /etc/network/interfaces
  echo "  post-up   iptables -t filter -A FORWARD -i ppp0 -o $vInterfazLAN -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /etc/network/interfaces
  echo "  post-down iptables -t filter -D FORWARD -i ppp0 -o $vInterfazLAN -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /etc/network/interfaces
  echo "  post-up   iptables -t filter -A FORWARD -i $vInterfazLAN -o ppp0 -j ACCEPT"                                      >> /etc/network/interfaces
  echo "  post-down iptables -t filter -D FORWARD -i $vInterfazLAN -o ppp0 -j ACCEPT"                                      >> /etc/network/interfaces
  echo ""                                                                                                                  >> /etc/network/interfaces

  echo ""
  echo "  Configurando la conexión PPP..."
  echo ""
  echo "#auto MovistarWAN"                             >> /etc/network/interfaces
  echo "#  iface MovistarWAN inet ppp"                 >> /etc/network/interfaces
  echo "#  pre-up /bin/ip link set $vInterfazWAN.6 up" >> /etc/network/interfaces
  echo "#  provider MovistarWAN"                       >> /etc/network/interfaces
  echo ""                                              >> /etc/network/interfaces
  echo ""
  echo '#!/bin/bash'                           > /root/scripts/LevantarInterfazPPP.sh
  echo ""                                     >> /root/scripts/LevantarInterfazPPP.sh
  echo "pon MovistarWAN"                      >> /root/scripts/LevantarInterfazPPP.sh
  echo ""                                     >> /root/scripts/LevantarInterfazPPP.sh
  chmod +x                                       /root/scripts/LevantarInterfazPPP.sh
  echo "/root/scripts/LevantarInterfazPPP.sh" >> /root/scripts/ComandosPostArranque.sh

  echo ""
  echo "  Configurando la rutas..."
  echo ""
  echo '#!/bin/bash'                                                                                  > /root/scripts/ConfigurarRutas.sh
  echo ""                                                                                            >> /root/scripts/ConfigurarRutas.sh
  echo "vIPMovistarWAN="'$'"(ifconfig ppp0 | grep inet | cut -dt -f2 | cut -d' ' -f2)"               >> /root/scripts/ConfigurarRutas.sh
  echo ""                                                                                            >> /root/scripts/ConfigurarRutas.sh
  echo "ip route flush table main"                                                                   >> /root/scripts/ConfigurarRutas.sh
  echo "ip route add default dev ppp0 scope link"                                                    >> /root/scripts/ConfigurarRutas.sh
  echo "ip route add 192.168.0.0/24 dev $vInterfazLAN proto kernel scope link src 192.168.0.1"       >> /root/scripts/ConfigurarRutas.sh
  echo "#ip route add 192.168.144.1 dev ppp0 proto kernel scope link src "'$'"vIPMovistarWAN"        >> /root/scripts/ConfigurarRutas.sh
  echo "#ip route add 192.168.1.0/24 via 192.168.0.2"                                                >> /root/scripts/ConfigurarRutas.sh
  echo 'echo ""'                                                                                     >> /root/scripts/ConfigurarRutas.sh
  echo "ip route"                                                                                    >> /root/scripts/ConfigurarRutas.sh
  echo 'echo ""'                                                                                     >> /root/scripts/ConfigurarRutas.sh
  echo "/root/scripts/ConfigurarRutas.sh" >> /root/scripts/ComandosPostArranque.sh

  echo ""
  echo "  Creando el archivo para el proveedor PPPoE..."
  echo ""
  echo "connect /bin/true"              > /etc/ppp/peers/MovistarWAN
  echo "default-asyncmap"              >> /etc/ppp/peers/MovistarWAN
  echo "defaultroute"                  >> /etc/ppp/peers/MovistarWAN
  echo "hide-password"                 >> /etc/ppp/peers/MovistarWAN
  echo "holdoff 3"                     >> /etc/ppp/peers/MovistarWAN
  echo "ipcp-accept-local"             >> /etc/ppp/peers/MovistarWAN
  echo "ipcp-accept-remote"            >> /etc/ppp/peers/MovistarWAN
  echo "lcp-echo-interval 15"          >> /etc/ppp/peers/MovistarWAN
  echo "lcp-echo-failure 3"            >> /etc/ppp/peers/MovistarWAN
  echo "lock"                          >> /etc/ppp/peers/MovistarWAN
  echo "mru 1492"                      >> /etc/ppp/peers/MovistarWAN
  echo "mtu 1492"                      >> /etc/ppp/peers/MovistarWAN
  echo "noaccomp"                      >> /etc/ppp/peers/MovistarWAN
  echo "noauth"                        >> /etc/ppp/peers/MovistarWAN
  echo "nobsdcomp"                     >> /etc/ppp/peers/MovistarWAN
  echo "noccp"                         >> /etc/ppp/peers/MovistarWAN
  echo "nodeflate"                     >> /etc/ppp/peers/MovistarWAN
  echo "noipdefault"                   >> /etc/ppp/peers/MovistarWAN
  echo "nopcomp"                       >> /etc/ppp/peers/MovistarWAN
  echo "novj"                          >> /etc/ppp/peers/MovistarWAN
  echo "novjccomp"                     >> /etc/ppp/peers/MovistarWAN
  echo "persist"                       >> /etc/ppp/peers/MovistarWAN
  echo "plugin rp-pppoe.so"            >> /etc/ppp/peers/MovistarWAN
  echo "nic-$vInterfazWAN.6"           >> /etc/ppp/peers/MovistarWAN
  echo "updetach"                      >> /etc/ppp/peers/MovistarWAN
  echo "usepeerdns"                    >> /etc/ppp/peers/MovistarWAN
  echo 'user "'$vUsuarioPPPMovistar'"' >> /etc/ppp/peers/MovistarWAN

  echo ""
  echo "  Creando el archivo chap-secrets..."
  echo ""
  echo '"'$vUsuarioPPPMovistar'" * "'$vClavePPPMovistar'"' > /etc/ppp/chap-secrets

  echo ""
  echo "  Agregando datos al archivo pap-secrets..."
  echo ""
  echo '"'$vUsuarioPPPMovistar'" * "'$vClavePPPMovistar'"' >> /etc/ppp/pap-secrets

  echo ""
  echo "  Indicando la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá..."
  echo ""
  cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
  echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'   > /etc/default/isc-dhcp-server
  echo 'INTERFACESv4='"$vInterfazLAN"''     >> /etc/default/isc-dhcp-server
  echo 'INTERFACESv6=""'                    >> /etc/default/isc-dhcp-server

  echo ""
  echo "  Configurando el servidor DHCP..."
  echo ""
  cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
  echo "authoritative;"                                             > /etc/dhcp/dhcpd.conf
  echo "subnet 192.168.0.0 netmask 255.255.255.0 {"                >> /etc/dhcp/dhcpd.conf
  echo "  range 192.168.0.100 192.168.0.199;"                      >> /etc/dhcp/dhcpd.conf
  echo "  option routers 192.168.0.1;"                             >> /etc/dhcp/dhcpd.conf
  echo "  option domain-name-servers 1.1.1.1, 1.0.0.1;"            >> /etc/dhcp/dhcpd.conf
  echo "  default-lease-time 600;"                                 >> /etc/dhcp/dhcpd.conf
  echo "  max-lease-time 7200;"                                    >> /etc/dhcp/dhcpd.conf
  echo ""                                                          >> /etc/dhcp/dhcpd.conf
  echo "  host PrimeraReserva {"                                   >> /etc/dhcp/dhcpd.conf
  echo "    hardware ethernet $vMacDelRouterAConectarAlPuertoLAN;" >> /etc/dhcp/dhcpd.conf
  echo "    fixed-address 192.168.0.2;"                            >> /etc/dhcp/dhcpd.conf
  echo "  }"                                                       >> /etc/dhcp/dhcpd.conf
  echo "}"                                                         >> /etc/dhcp/dhcpd.conf

  echo ""
  echo -e "${vColorVerde}Ejecución del script de conexión de Debian con la fibra de Movistar, finalizada.${vFinColor}"
  echo ""
  echo -e "${vColorVerde}Ya puedes apagar la NanoPi ejecutando:${vFinColor}"
  echo "shutdown -h now"
  echo -e "${vColorVerde}y conectarle el cable ethernet desde el puerto WAN a la ONT the Movistar.${vFinColor}"
  echo ""
  echo -e "${vColorVerde}Después de encenderla de nuevo, debería tener internet a través de la interfaz ppp0${vFinColor}"
  echo ""

elif [ $OS_VERS == "11" ]; then

  echo ""
  echo -e "${vColorAzulClaro}Iniciando el script para conectar Debian 11 (Bullseye) con la ONT de Movistar...${vFinColor}"
  echo ""

  echo ""
  echo -e "${vColorRojo}  Comandos para Debian 11 todavía no preparados. Prueba ejecutar el script en otra versión de Debian.${vFinColor}"
  echo ""

fi

