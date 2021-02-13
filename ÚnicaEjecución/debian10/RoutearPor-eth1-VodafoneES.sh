#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

#---------------------------------------------------------------------------------------
#  Script de NiPeGun para preparar un Debian Buster recién instalado para que pueda
#  conectarse a una ONT que esté recibiendo la fibra de Vodafone ES y pueda rootear
#  una conexión de internet a través la la interfaz LAN
#----------------------------------------------------------------------------------------

InterfazCableada1=eth0
InterfazCableada2=eth1
UsuarioPPPVodafone="xxx"
ClavePPPVodafone="xxx"
MacDelRouterVodafone="00:00:00:00:00:00"

ColorRojo='\033[1;31m'
ColorVerde='\033[1;32m'
FinColor='\033[0m'

echo ""
echo -e "${ColorVerde}---------------------------------------------------------------------------------${FinColor}"
echo -e "${ColorVerde}Iniciando el script de preparación para conectar Debian con la ONT de Vodafone...${FinColor}"
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
echo "  pre-up iptables-restore < /root/ReglasIPTablesIP4RouterVodafone.ipt" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la interfaz WAN...${FinColor}"
echo ""
echo "auto $InterfazCableada1" >> /etc/network/interfaces
echo "  allow-hotplug $InterfazCableada1" >> /etc/network/interfaces
echo "  iface $InterfazCableada1 inet manual" >> /etc/network/interfaces
echo "  #hwaddress ether $MacDelRouterVodafone # Necesario para evitar futuros problemas" >> /etc/network/interfaces
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
echo -e "${ColorVerde}Configurando la vlan de datos (100) y telefonía (100)...${FinColor}"
echo ""
echo "# VLAN de Datos y Telefonía" >> /etc/network/interfaces
echo "auto $InterfazCableada1.100 # Datos y voz" >> /etc/network/interfaces
echo "  iface $InterfazCableada1.100 inet manual" >> /etc/network/interfaces
echo "  vlan-raw-device $InterfazCableada1 # Necesario si la vlan se crea con un nombre no convencional" >> /etc/network/interfaces
echo "  metric 0" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la conexión PPP...${FinColor}"
echo ""
echo "auto VodafoneWAN" >> /etc/network/interfaces
echo "  iface VodafoneWAN inet ppp" >> /etc/network/interfaces
echo "  pre-up /bin/ip link set $InterfazCableada1.100 up" >> /etc/network/interfaces
echo "  provider VodafoneWAN" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Configurando la vlan de televisión (105) y prioridad (4)...${FinColor}"
echo ""
echo "# VLAN de Televisión" >> /etc/network/interfaces
echo "auto $InterfazCableada1.105" >> /etc/network/interfaces
echo "  iface $InterfazCableada1.105 inet dhcp" >> /etc/network/interfaces
echo "  vlan-raw-device $InterfazCableada1 # Necesario si la vlan se crea con un nombre no convencional" >> /etc/network/interfaces
echo "  metric 4" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces

echo ""
echo -e "${ColorVerde}Creando el archivo para el proveedor PPPoE...${FinColor}"
echo ""
echo "noipdefault" > /etc/ppp/peers/VodafoneWAN
echo "defaultroute" >> /etc/ppp/peers/VodafoneWAN
echo "replacedefaultroute" >> /etc/ppp/peers/VodafoneWAN
echo "hide-password" >> /etc/ppp/peers/VodafoneWAN
echo "#lcp-echo-interval 30" >> /etc/ppp/peers/VodafoneWAN
echo "#lcp-echo-failure 4" >> /etc/ppp/peers/VodafoneWAN
echo "noauth" >> /etc/ppp/peers/VodafoneWAN
echo "persist" >> /etc/ppp/peers/VodafoneWAN
echo "#mtu 1492" >> /etc/ppp/peers/VodafoneWAN
echo "#maxfail 0" >> /etc/ppp/peers/VodafoneWAN
echo "#holdoff 20" >> /etc/ppp/peers/VodafoneWAN
echo "plugin rp-pppoe.so" >> /etc/ppp/peers/VodafoneWAN
echo "nic-$InterfazCableada1.100" >> /etc/ppp/peers/VodafoneWAN
echo 'user "'$UsuarioPPPVodafone'"' >> /etc/ppp/peers/VodafoneWAN
echo "usepeerdns" >> /etc/ppp/peers/VodafoneWAN

echo ""
echo -e "${ColorVerde}Creando el archivo chap-secrets...${FinColor}"
echo ""
echo '"'$UsuarioPPPVodafone'" * "'$ClavePPPVodafone'"' > /etc/ppp/chap-secrets

echo ""
echo -e "${ColorVerde}Agregando datos al archivo pap-secrets...${FinColor}"
echo ""
echo '"'$UsuarioPPPVodafone'" * "'$ClavePPPVodafone'"' >> /etc/ppp/pap-secrets

echo ""
echo -e "${ColorVerde}Creando las reglas de IPTables...${FinColor}"
echo ""
echo "*mangle" > /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":PREROUTING ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":INPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":FORWARD ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":OUTPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":POSTROUTING ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo "COMMIT" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo "" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo "*nat" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":PREROUTING ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":INPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":OUTPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":POSTROUTING ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo "-A POSTROUTING -o ppp0 -j MASQUERADE" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo "COMMIT" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo "" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo "*filter" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":INPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":FORWARD ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo ":OUTPUT ACCEPT [0:0]" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo "-A FORWARD -i ppp0 -o $InterfazCableada2 -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo "-A FORWARD -i $InterfazCableada2 -o ppp0 -j ACCEPT" >> /root/ReglasIPTablesIP4RouterVodafone.ipt
echo "COMMIT" >> /root/ReglasIPTablesIP4RouterVodafone.ipt

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
echo -e "${ColorVerde}Agregando la conexión ppp0 a los ComandosPostArranque...${FinColor}"
echo ""
echo "pon VodafoneWAN" >> /root/scripts/ComandosPostArranque.sh

echo ""
echo -e "${ColorVerde}--------------------------------------------------------------------------------------------${FinColor}"
echo -e "${ColorVerde}Ejecución del script de preparación para la fibra de Vodafone, finalizada.${FinColor}"
echo ""
echo -e "${ColorVerde}Apagando el dispositivo...${FinColor}"
echo ""
echo -e "${ColorVerde}Al acabar de apagarse ya podrás conectar un cable desde el puerto eth0 a la ONT de Vodafone ${FinColor}"
echo -e "${ColorVerde}y el puerto eth1 a la WAN de otro router o a cualquier dispositivo que necesite internet.   ${FinColor}"
echo ""
echo -e "${ColorVerde}Si por alguna razónla interfaz ppp0 no se levanta, puedes levantarla manualmente ejecutando:${FinColor}"
echo ""
echo "pon VodafoneWAN"
echo -e "${ColorVerde}--------------------------------------------------------------------------------------------${FinColor}"
echo ""
shutdown -h now

