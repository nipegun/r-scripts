#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

#---------------------------------------------------------------------------------------
#  Script de NiPeGun para preparar un Armbian Buster recién instalado en un NanoPi R2S
#  para que pueda conectarse a una ONT que esté recibiendo la fibra de Movistar ES
#  y pueda routear una conexión de internet a través la la interfaz LAN
#----------------------------------------------------------------------------------------

InterfazWAN=eth0
InterfazLAN=lan0
UsuarioPPPMovistar="adslppp@telefonicanetpa"
ClavePPPMovistar="adslppp"
IPDeIPTV="2.2.2.2"
MacWANDelRouterMovistar="00:00:00:00:00:00"
MacDelRouterAConectarAlPuertoLAN="00:00:00:00:00:00"

ColorRojo='\033[1;31m'
ColorVerde='\033[1;32m'
FinColor='\033[0m'

echo ""
echo -e "${ColorVerde}------------------------------------------------------------------${FinColor}"
echo -e "${ColorVerde}Iniciando el script para conectar Debian con la ONT de Movistar...${FinColor}"
echo -e "${ColorVerde}------------------------------------------------------------------${FinColor}"
echo ""

echo ""
echo -e "${ColorVerde}Instalando paquetes de red...${FinColor}"
echo ""
#apt-get -y install vlan pppoe isc-dhcp-server wget

echo ""
echo -e "${ColorVerde}Activando el módulo 8021q para VLANs...${FinColor}"
echo ""
if grep -Fxq "8021q" /etc/modules
  then
    echo ""
    echo "El módulo ya está activado en /etc/modules. No hace falta activarlo."
    echo ""
  else
    echo "8021q" >> /etc/modules
  fi

echo ""
echo -e "${ColorVerde}Configurando la interfaz loopback...${FinColor}"
echo ""
echo "auto lo"                   > /etc/network/interfaces
echo "  iface lo inet loopback" >> /etc/network/interfaces
echo ""                         >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la interfaz WAN...${FinColor}"
echo ""
echo "auto $InterfazWAN"                                                                     >> /etc/network/interfaces
echo "  allow-hotplug $InterfazWAN"                                                          >> /etc/network/interfaces
echo "  iface $InterfazWAN inet manual"                                                      >> /etc/network/interfaces
echo "  #hwaddress ether $MacWANDelRouterMovistar # Necesario para evitar futuros problemas" >> /etc/network/interfaces
echo ""                                                                                      >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la vlan de datos (6) y prioridad (1)...${FinColor}"
echo ""
echo "# VLAN de Datos"                                                                              >> /etc/network/interfaces
echo "auto $InterfazWAN.6"                                                                          >> /etc/network/interfaces
echo "  iface $InterfazWAN.6 inet manual"                                                           >> /etc/network/interfaces
echo "  vlan-raw-device $InterfazWAN # Necesario si la vlan se crea con un nombre no convencional"  >> /etc/network/interfaces
echo "  metric 1"                                                                                   >> /etc/network/interfaces
echo ""                                                                                             >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la vlan de voz (3) y prioridad (4)...${FinColor}"
echo ""
echo "# VLAN de VoIP"                                                                               >> /etc/network/interfaces
echo "#auto $InterfazWAN.3"                                                                         >> /etc/network/interfaces
echo "#  iface $InterfazWAN.3 inet dhcp"                                                            >> /etc/network/interfaces
echo "#  vlan-raw-device $InterfazWAN # Necesario si la vlan se crea con un nombre no convencional" >> /etc/network/interfaces
echo "#  metric 4"                                                                                  >> /etc/network/interfaces
echo ""                                                                                             >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la vlan de televisión (2) y prioridad (4)...${FinColor}"
echo ""
echo "# VLAN de IPTV"                                                                               >> /etc/network/interfaces
echo "#auto $InterfazWAN.2"                                                                          >> /etc/network/interfaces
echo "#  iface $InterfazWAN.2 inet static"                                                           >> /etc/network/interfaces
echo "#  address $IPDeIPTV"                                                                          >> /etc/network/interfaces
echo "#  vlan-raw-device $InterfazWAN # Necesario si la vlan se crea con un nombre no convencional"  >> /etc/network/interfaces
echo "#  metric 4"                                                                                   >> /etc/network/interfaces
echo ""                                                                                             >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la interfaz LAN...${FinColor}"
echo ""
echo "auto $InterfazLAN"                                                                                                >> /etc/network/interfaces
echo "  iface $InterfazLAN inet static"                                                                                 >> /etc/network/interfaces
echo "  address 192.168.0.1"                                                                                            >> /etc/network/interfaces
echo "  network 192.168.0.0"                                                                                            >> /etc/network/interfaces
echo "  netmask 255.255.255.0"                                                                                          >> /etc/network/interfaces
echo "  broadcast 192.168.0.255"                                                                                        >> /etc/network/interfaces
echo "  post-up   echo 1 > /proc/sys/net/ipv4/ip_forward"                                                               >> /etc/network/interfaces
echo "  post-down echo 0 > /proc/sys/net/ipv4/ip_forward"                                                               >> /etc/network/interfaces
echo "  post-up   iptables -t nat -A POSTROUTING -o ppp0 -j MASQUERADE"                                                 >> /etc/network/interfaces
echo "  post-down iptables -t nat -D POSTROUTING -o ppp0 -j MASQUERADE"                                                 >> /etc/network/interfaces
echo "  post-up   iptables -t filter -A FORWARD -i ppp0 -o $InterfazLAN -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /etc/network/interfaces
echo "  post-down iptables -t filter -D FORWARD -i ppp0 -o $InterfazLAN -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /etc/network/interfaces
echo "  post-up   iptables -t filter -A FORWARD -i $InterfazLAN -o ppp0 -j ACCEPT"                                      >> /etc/network/interfaces
echo "  post-down iptables -t filter -D FORWARD -i $InterfazLAN -o ppp0 -j ACCEPT"                                      >> /etc/network/interfaces
echo ""                                                                                                                 >> /etc/network/interfaces


echo ""
echo -e "${ColorVerde}Configurando la conexión PPP...${FinColor}"
echo ""
echo "#auto MovistarWAN"                            >> /etc/network/interfaces
echo "#  iface MovistarWAN inet ppp"                >> /etc/network/interfaces
echo "#  pre-up /bin/ip link set $InterfazWAN.6 up" >> /etc/network/interfaces
echo "#  provider MovistarWAN"                      >> /etc/network/interfaces
echo ""                                             >> /etc/network/interfaces
echo ""
echo '#!/bin/bash'                           > /root/scripts/LevantarInterfazPPP.sh
echo ""                                     >> /root/scripts/LevantarInterfazPPP.sh
echo "pon MovistarWAN"                      >> /root/scripts/LevantarInterfazPPP.sh
echo ""                                     >> /root/scripts/LevantarInterfazPPP.sh
chmod +x                                       /root/scripts/LevantarInterfazPPP.sh
echo "/root/scripts/LevantarInterfazPPP.sh" >> /root/scripts/ComandosPostArranque.sh

echo ""
echo -e "${ColorVerde}Configurando la rutas...${FinColor}"
echo ""
echo '#!/bin/bash'                                                                                 > /root/scripts/ConfigurarRutas.sh
echo ""                                                                                           >> /root/scripts/ConfigurarRutas.sh
echo "IPMovistarWAN="'$'"(ifconfig ppp0 | grep inet | cut -dt -f2 | cut -d' ' -f2)"               >> /root/scripts/ConfigurarRutas.sh
echo "IPLAN="'$'"(ifconfig $InterfazLAN | grep inet | cut -dt -f2 | cut -d' ' -f2)"               >> /root/scripts/ConfigurarRutas.sh
echo ""                                                                                           >> /root/scripts/ConfigurarRutas.sh
echo "ip route flush table main"                                                                  >> /root/scripts/ConfigurarRutas.sh
echo "ip route add default dev ppp0 scope link"                                                   >> /root/scripts/ConfigurarRutas.sh
echo "ip route add 192.168.0.0/24 dev $InterfazLAN proto kernel scope link src "'$'"IPLAN"        >> /root/scripts/ConfigurarRutas.sh
echo "ip route add 192.168.144.1 dev ppp0 proto kernel scope link src "'$'"IPMovistarWAN"         >> /root/scripts/ConfigurarRutas.sh
echo "ip route add 192.168.1.0/24 via 192.168.0.2"                                                >> /root/scripts/ConfigurarRutas.sh
echo 'echo ""'                                                                                    >> /root/scripts/ConfigurarRutas.sh
echo "ip route"                                                                                   >> /root/scripts/ConfigurarRutas.sh
echo 'echo ""'                                                                                    >> /root/scripts/ConfigurarRutas.sh
echo "#/root/scripts/ConfigurarRutas.sh" >> /root/scripts/ComandosPostArranque.sh

echo ""
echo -e "${ColorVerde}Creando el archivo para el proveedor PPPoE...${FinColor}"
echo ""
echo "connect /bin/true"             > /etc/ppp/peers/MovistarWAN
echo "default-asyncmap"             >> /etc/ppp/peers/MovistarWAN
echo "defaultroute"                 >> /etc/ppp/peers/MovistarWAN
echo "hide-password"                >> /etc/ppp/peers/MovistarWAN
echo "holdoff 3"                    >> /etc/ppp/peers/MovistarWAN
echo "ipcp-accept-local"            >> /etc/ppp/peers/MovistarWAN
echo "ipcp-accept-remote"           >> /etc/ppp/peers/MovistarWAN
echo "lcp-echo-interval 15"         >> /etc/ppp/peers/MovistarWAN
echo "lcp-echo-failure 3"           >> /etc/ppp/peers/MovistarWAN
echo "lock"                         >> /etc/ppp/peers/MovistarWAN
echo "mru 1492"                     >> /etc/ppp/peers/MovistarWAN
echo "mtu 1492"                     >> /etc/ppp/peers/MovistarWAN
echo "noaccomp"                     >> /etc/ppp/peers/MovistarWAN
echo "noauth"                       >> /etc/ppp/peers/MovistarWAN
echo "nobsdcomp"                    >> /etc/ppp/peers/MovistarWAN
echo "noccp"                        >> /etc/ppp/peers/MovistarWAN
echo "nodeflate"                    >> /etc/ppp/peers/MovistarWAN
echo "noipdefault"                  >> /etc/ppp/peers/MovistarWAN
echo "nopcomp"                      >> /etc/ppp/peers/MovistarWAN
echo "novj"                         >> /etc/ppp/peers/MovistarWAN
echo "novjccomp"                    >> /etc/ppp/peers/MovistarWAN
echo "persist"                      >> /etc/ppp/peers/MovistarWAN
echo "plugin rp-pppoe.so"           >> /etc/ppp/peers/MovistarWAN
echo "nic-$InterfazWAN.6"           >> /etc/ppp/peers/MovistarWAN
echo "updetach"                     >> /etc/ppp/peers/MovistarWAN
echo "usepeerdns"                   >> /etc/ppp/peers/MovistarWAN
echo 'user "'$UsuarioPPPMovistar'"' >> /etc/ppp/peers/MovistarWAN

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
echo 'INTERFACESv4='"$InterfazLAN"''     >> /etc/default/isc-dhcp-server
echo 'INTERFACESv6=""'                   >> /etc/default/isc-dhcp-server

echo ""
echo -e "${ColorVerde}Configurando el servidor DHCP...${FinColor}"
echo ""
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
echo "authoritative;"                                            > /etc/dhcp/dhcpd.conf
echo "subnet 192.168.0.0 netmask 255.255.255.0 {"               >> /etc/dhcp/dhcpd.conf
echo "  range 192.168.0.100 192.168.0.199;"                     >> /etc/dhcp/dhcpd.conf
echo "  option routers 192.168.0.1;"                            >> /etc/dhcp/dhcpd.conf
echo "  option domain-name-servers 1.1.1.1, 1.0.0.1;"           >> /etc/dhcp/dhcpd.conf
echo "  default-lease-time 600;"                                >> /etc/dhcp/dhcpd.conf
echo "  max-lease-time 7200;"                                   >> /etc/dhcp/dhcpd.conf
echo ""                                                         >> /etc/dhcp/dhcpd.conf
echo "  host PrimeraReserva {"                                  >> /etc/dhcp/dhcpd.conf
echo "    hardware ethernet $MacDelRouterAConectarAlPuertoLAN;" >> /etc/dhcp/dhcpd.conf
echo "    fixed-address 192.168.0.2;"                           >> /etc/dhcp/dhcpd.conf
echo "  }"                                                      >> /etc/dhcp/dhcpd.conf
echo "}"                                                        >> /etc/dhcp/dhcpd.conf

echo ""
echo -e "${ColorVerde}--------------------------------------------------------------------------------------------${FinColor}"
echo -e "${ColorVerde}Ejecución del script de conexión de Debian con la fibra de Movistar, finalizada.${FinColor}"
echo ""
echo -e "${ColorVerde}Ya puedes apagar la NanoPi ejecutando:${FinColor}"
echo "shutdown -h now"
echo -e "${ColorVerde}y conectarle el cable ethernet desde el puerto WAN a la ONT the Movistar.${FinColor}"
echo ""
echo -e "${ColorVerde}Después de encenderla de nuevo, debería tener internet a través de la interfaz ppp0${FinColor}"
echo -e "${ColorVerde}--------------------------------------------------------------------------------------------${FinColor}"
echo ""

