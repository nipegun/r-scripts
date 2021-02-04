#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

#---------------------------------------------------------------------------------------
#  Script de NiPeGun para preparar un Armbian Buster recién instalado en un NanoPi R2S
#  para que pueda conectarse a una ONT que esté recibiendo la fibra de Movistar ES
#  y pueda rootear una conexión de internet a través la la interfaz LAN
#----------------------------------------------------------------------------------------

InterfazCableada1=eth0
InterfazCableada2=eth1
UsuarioPPPMovistar=adslppp@telefonicanetpa
ClavePPPMovistar=adslppp
MacDelRouterMovistar=00:00:00:00:00:00

ColorRojo='\033[1;31m'
ColorVerde='\033[1;32m'
FinColor='\033[0m'

echo ""
echo -e "${ColorVerde}---------------------------------------------------------------------------------${FinColor}"
echo -e "${ColorVerde}Iniciando el script de preparación para conectar Debian con la ONT de Movistar...${FinColor}"
echo -e "${ColorVerde}---------------------------------------------------------------------------------${FinColor}"
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
echo "auto lo" > /etc/network/interfaces
echo "  iface lo inet loopback" >> /etc/network/interfaces
echo "  pre-up iptables-restore < /root/ReglasIPTablesIP4RouterMovistar.ipt" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la interfaz WAN...${FinColor}"
echo ""
echo "auto $InterfazCableada1" >> /etc/network/interfaces
echo "  allow-hotplug $InterfazCableada1" >> /etc/network/interfaces
echo "  iface $InterfazCableada1 inet dhcp" >> /etc/network/interfaces
echo "  #hwaddress ether $MacDelRouterMovistar # Necesario para evitar futuros problemas" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la interfaz LAN...${FinColor}"
echo ""
echo "auto $InterfazCableada2" >> /etc/network/interfaces
echo "  iface $InterfazCableada2 inet static" >> /etc/network/interfaces
echo "  address 192.168.0.1" >> /etc/network/interfaces
echo "  network 192.168.0.0" >> /etc/network/interfaces
echo "  netmask 255.255.255.0" >> /etc/network/interfaces
echo "  broadcast 192.168.0.255" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la vlan de datos (6) y prioridad (1)...${FinColor}"
echo ""
echo "auto $InterfazCableada1.6 # Datos" >> /etc/network/interfaces
echo "  iface $InterfazCableada1.6 inet manual" >> /etc/network/interfaces
echo "  metric 1" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la conexión PPP...${FinColor}"
echo ""
echo "auto MovistarWAN" >> /etc/network/interfaces
echo "  iface MovistarWAN inet ppp" >> /etc/network/interfaces
echo "  pre-up /bin/ip link set $InterfazCableada1.6 up" >> /etc/network/interfaces
echo "  provider MovistarWAN" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la vlan de televisión (2) y prioridad (4)...${FinColor}"
echo ""
echo "auto $InterfazCableada1.2 # Televisión" >> /etc/network/interfaces
echo "  iface $InterfazCableada1.2 inet dhcp" >> /etc/network/interfaces
echo "  metric 4" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la vlan de voz (3) y prioridad (4)...${FinColor}"
echo ""
echo "auto $InterfazCableada1.3 # Telefonía" >> /etc/network/interfaces
echo "  iface $InterfazCableada1.3 inet dhcp" >> /etc/network/interfaces
echo "  metric 4" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Creando el archivo para el proveedor PPPoE...${FinColor}"
echo ""
echo "noipdefault" > /etc/ppp/peers/MovistarWAN
echo "defaultroute" >> /etc/ppp/peers/MovistarWAN
echo "replacedefaultroute" >> /etc/ppp/peers/MovistarWAN
echo "hide-password" >> /etc/ppp/peers/MovistarWAN
echo "#lcp-echo-interval 30" >> /etc/ppp/peers/MovistarWAN
echo "#lcp-echo-failure 4" >> /etc/ppp/peers/MovistarWAN
echo "noauth" >> /etc/ppp/peers/MovistarWAN
echo "persist" >> /etc/ppp/peers/MovistarWAN
echo "#mtu 1492" >> /etc/ppp/peers/MovistarWAN
echo "#maxfail 0" >> /etc/ppp/peers/MovistarWAN
echo "#holdoff 20" >> /etc/ppp/peers/MovistarWAN
echo "plugin rp-pppoe.so" >> /etc/ppp/peers/MovistarWAN
echo "nic-$InterfazCableada1.6" >> /etc/ppp/peers/MovistarWAN
echo 'user "'$UsuarioPPPMovistar'"' >> /etc/ppp/peers/MovistarWAN
echo "usepeerdns" >> /etc/ppp/peers/MovistarWAN

echo ""
echo -e "${ColorVerde}Creando el archivo chap-secrets...${FinColor}"
echo ""
echo '"'$UsuarioPPPMovistar'" * "'$ClavePPPMovistar'"' > /etc/ppp/chap-secrets

echo ""
echo -e "${ColorVerde}Agregando datos al archivo pap-secrets...${FinColor}"
echo ""
echo '"'$UsuarioPPPMovistar'" * "'$ClavePPPMovistar'"' >> /etc/ppp/pap-secrets

echo ""
echo -e "${ColorVerde}Creando las reglas de IPTables...${FinColor}"
echo ""
echo "*mangle" > /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":PREROUTING ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":INPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":FORWARD ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":OUTPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":POSTROUTING ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo "COMMIT" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo "" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo "*nat" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":PREROUTING ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":INPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":OUTPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":POSTROUTING ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo "-A POSTROUTING -o ppp0 -j MASQUERADE" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo "COMMIT" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo "" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo "*filter" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":INPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":FORWARD ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo ":OUTPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo "-A FORWARD -i ppp0 -o $InterfazCableada2 -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo "-A FORWARD -i $InterfazCableada2 -o ppp0 -j ACCEPT" >> /root/ReglasIPTablesIP4RouterMovistar.ipt
echo "COMMIT" >> /root/ReglasIPTablesIP4RouterMovistar.ipt

echo ""
echo -e "${ColorVerde}Habilitando ip-forwarding...${FinColor}"
echo ""
cp /etc/sysctl.conf /etc/sysctl.conf.bak
sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

echo ""
echo -e "${ColorVerde}Indicando la ubicación del archivo de configuración del demonio dhcpd${FinColor}"
echo -e "${ColorVerde}y la interfaz sobre la que correrá...${FinColor}"
echo ""
cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
sed -i -e 's|#DHCPDv4_CONF=/etc/dhcp/dhcpd.conf|DHCPDv4_CONF=/etc/dhcp/dhcpd.conf|g' /etc/default/isc-dhcp-server
sed -i -e 's|INTERFACESv4=""|INTERFACESv4="'$InterfazCableada2'"|g' /etc/default/isc-dhcp-server

echo ""
echo -e "${ColorVerde}Configurando el servidor DHCP...${FinColor}"
echo ""
cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
echo "authoritative;" > /etc/dhcp/dhcpd.conf
echo "subnet 192.168.0.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
echo "  range 192.168.0.100 192.168.0.199;" >> /etc/dhcp/dhcpd.conf
echo "  option routers 192.168.0.1;" >> /etc/dhcp/dhcpd.conf
echo "  option domain-name-servers 1.1.1.1, 1.0.0.1;" >> /etc/dhcp/dhcpd.conf
echo "  default-lease-time 600;" >> /etc/dhcp/dhcpd.conf
echo "  max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf
echo "" >> /etc/dhcp/dhcpd.conf
echo "  host PrimeraReserva {" >> /etc/dhcp/dhcpd.conf
echo "    hardware ethernet 00:00:00:00:00:01;" >> /etc/dhcp/dhcpd.conf
echo "    fixed-address 192.168.0.10;" >> /etc/dhcp/dhcpd.conf
echo "  }" >> /etc/dhcp/dhcpd.conf
echo "}" >> /etc/dhcp/dhcpd.conf

echo ""
echo -e "${ColorVerde}Descargando archivos de nombres de fabricantes...${FinColor}"
echo ""
wget -O /usr/local/etc/oui.txt http://standards-oui.ieee.org/oui/oui.txt


echo ""
echo -e "${ColorVerde}--------------------------------------------------------------------------${FinColor}"
echo -e "${ColorVerde}Ejecución del script de preparación para la fibra de Movistar, finalizada.${FinColor}"
echo ""

echo -e "${ColorVerde}--------------------------------------------------------------------------${FinColor}"
echo ""


echo ""
echo "----------------------------------------------------------------------"
echo "  FINALIZADO."
echo "  AHORA, EL CABLE ETHERNET QUE VA DEL ORDENADOR AL ROUTER SERCOMM,"
echo "  DESCONÉCTALO DEL ROUTER Y CONÉCTASELO DIRECTAMENTE A LA ONT"
echo ""
echo "  DESPUÉS DE HACERLO REINICIA EL SISTEMA EJECUTANDO:"
echo "  shutdown -r now"
echo "  Y DESPUÉS DE REINICIAR TU DEBIAN DEBERÍA ESTAR CONECTADO A LA RED"
echo "  DE VODAFONE Y YA ESTAR OPERANDO COMO ROUTER."
echo "  PODRÁS CONECTARLE AL 2DO PUERTO ETHERNET TANTO UN PUNTO DE ACCESO"
echo "  COMO UN ROUTER EN MODO PUENTE Y YA PODRÄS TENER WIFI"
echo "----------------------------------------------------------------------"
echo ""
