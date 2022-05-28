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

#-------------------------------------------------------------------
#  SCRIPT DE NIPEGUN PARA TRANSFORMAR UN DEBIAN 9 RECIÉN INSTALADO
#  EN UN ROUTER QUE SIRVA IPs EN LA SEGUNDA INTERFAZ CABLEADA.
#        ES NECESARIO QUE EL ORDENADOR CUENTE CON, AL MENOS,
#                     DOS INTERFACES CABLEADAS.
#  ESTE SCRIPT TIENE EN CUENTA QUE EL ROUTER AL QUE ESTÁ CONECTADO
#  EL ORDENADOR ESTÁ EN UNA SUBRED DISTINTA DE 192.168.1 PORQUE AL
#  FINALIZAR LA EJECUCIÓN DEL SCRIPT, EL ORDENADOR PROPORCIONARÁ
#  IPS EN ESA SUBRED (de 192.168.1.100 hasta 192.168.1.255)
#-------------------------------------------------------------------

# !!!! DEBES REEMPLAZAR LOS VALORES DE LAS 2 VARIABLES DE ABAJO !!!!
# !!!!!!!!!!!!!!!!!!! ANTES DE EJECUTAR EL SCRIPT !!!!!!!!!!!!!!!!!!

interfazcableada1=eth0
interfazcableada2=eth1
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

  apt-get update

  echo ""
  echo "----------------------------------"
  echo "  INSTALANDO HERRAMIENTAS DE RED"
  echo "----------------------------------"
  echo ""
  apt-get -y install isc-dhcp-server

  echo ""
  echo "-------------------------------------"
  echo "  CONFIGURANDO LA INTERFAZ LOOPBACK"
  echo "-------------------------------------"
  echo ""
  echo "auto lo" > /etc/network/interfaces
  echo "  iface lo inet loopback" >> /etc/network/interfaces
  echo "  pre-up iptables-restore < /root/ReglasIPTablesIP4Router" >> /etc/network/interfaces
  echo "" >> /etc/network/interfaces

  echo ""
  echo "---------------------------------------------"
  echo "  CONFIGURANDO LA PRIMERA INTERFAZ CABLEADA"
  echo "---------------------------------------------"
  echo ""
  echo "auto $interfazcableada1" >> /etc/network/interfaces
  echo "  allow-hotplug $interfazcableada1" >> /etc/network/interfaces
  echo "  iface $interfazcableada1 inet dhcp" >> /etc/network/interfaces
  echo "" >> /etc/network/interfaces

  echo ""
  echo "---------------------------------------------"
  echo "  CONFIGURANDO LA SEGUNDA INTERFAZ CABLEADA"
  echo "---------------------------------------------"
  echo ""
  echo "auto $interfazcableada2" >> /etc/network/interfaces
  echo "  iface $interfazcableada2 inet static" >> /etc/network/interfaces
  echo "  address 192.168.1.1" >> /etc/network/interfaces
  echo "  network 192.168.1.0" >> /etc/network/interfaces
  echo "  netmask 255.255.255.0" >> /etc/network/interfaces
  echo "  broadcast 192.168.1.255" >> /etc/network/interfaces
  echo "" >> /etc/network/interfaces

  echo ""
  echo "------------------------------"
  echo "  INSTALANDO EL SERVIDOR SSH"
  echo "------------------------------"
  echo ""
  apt-get -y install tasksel
  tasksel install ssh-server

  echo ""
  echo "-----------------------------"
  echo "  DESHABILITANDO EL SPEAKER"
  echo "-----------------------------"
  echo ""
  cp /etc/inputrc /etc/inputrc.bak
  sed -i 's|^# set bell-style none|set bell-style none|g' /etc/inputrc

  echo ""
  echo "----------------------------------"
  echo "  CREANDO LAS REGLAS DE IPTABLES"
  echo "----------------------------------"
  echo ""
  echo "*mangle"                                                                                                > /root/ReglasIPTablesIP4Router
  echo ":PREROUTING ACCEPT [0:0]"                                                                              >> /root/ReglasIPTablesIP4Router
  echo ":INPUT ACCEPT [0:0]"                                                                                   >> /root/ReglasIPTablesIP4Router
  echo ":FORWARD ACCEPT [0:0]"                                                                                 >> /root/ReglasIPTablesIP4Router
  echo ":OUTPUT ACCEPT [0:0]"                                                                                  >> /root/ReglasIPTablesIP4Router
  echo ":POSTROUTING ACCEPT [0:0]"                                                                             >> /root/ReglasIPTablesIP4Router
  echo "COMMIT"                                                                                                >> /root/ReglasIPTablesIP4Router
  echo ""                                                                                                      >> /root/ReglasIPTablesIP4Router
  echo "*nat"                                                                                                  >> /root/ReglasIPTablesIP4Router
  echo ":PREROUTING ACCEPT [0:0]"                                                                              >> /root/ReglasIPTablesIP4Router
  echo ":INPUT ACCEPT [0:0]"                                                                                   >> /root/ReglasIPTablesIP4Router
  echo ":OUTPUT ACCEPT [0:0]"                                                                                  >> /root/ReglasIPTablesIP4Router
  echo ":POSTROUTING ACCEPT [0:0]"                                                                             >> /root/ReglasIPTablesIP4Router
  echo "-A POSTROUTING -o $interfazcableada1 -j MASQUERADE"                                                    >> /root/ReglasIPTablesIP4Router
  echo "COMMIT"                                                                                                >> /root/ReglasIPTablesIP4Router
  echo ""                                                                                                      >> /root/ReglasIPTablesIP4Router
  echo "*filter"                                                                                               >> /root/ReglasIPTablesIP4Router
  echo ":INPUT ACCEPT [0:0]"                                                                                   >> /root/ReglasIPTablesIP4Router
  echo ":FORWARD ACCEPT [0:0]"                                                                                 >> /root/ReglasIPTablesIP4Router
  echo ":OUTPUT ACCEPT [0:0]"                                                                                  >> /root/ReglasIPTablesIP4Router
  echo "-A FORWARD -i $interfazcableada1 -o $interfazcableada2 -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /root/ReglasIPTablesIP4Router
  echo "-A FORWARD -i $interfazcableada2 -o $interfazcableada1 -j ACCEPT"                                      >> /root/ReglasIPTablesIP4Router
  echo "COMMIT"                                                                                                >> /root/ReglasIPTablesIP4Router

  echo ""
  echo "-----------------------------"
  echo "  HABILITANDO IP FORWARDING"
  echo "-----------------------------"
  echo ""
  cp /etc/sysctl.conf /etc/sysctl.conf.bak
  sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

  echo ""
  echo ""
  echo -e "${ColorVerde}Indicando la ubicación del archivo de configuración del demonio dhcpd${FinColor}"
  echo -e "${ColorVerde}y la interfaz sobre la que correrá...${FinColor}"
  echo ""
  cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
  echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'  > /etc/default/isc-dhcp-server
  echo 'INTERFACESv4="$interfazcableada2"' >> /etc/default/isc-dhcp-server
  echo 'INTERFACESv6=""'                   >> /etc/default/isc-dhcp-server

  echo ""
  echo "---------------------------------"
  echo "  CONFIGURANDO EL SERVIDOR DHCP"
  echo "---------------------------------"
  echo ""
  cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
  echo "authoritative;" > /etc/dhcp/dhcpd.conf
  echo "subnet 192.168.1.0 netmask 255.255.255.0 {" >> /etc/dhcp/dhcpd.conf
  echo "  range 192.168.1.100 192.168.1.199;" >> /etc/dhcp/dhcpd.conf
  echo "  option routers 192.168.1.1;" >> /etc/dhcp/dhcpd.conf
  echo "  option domain-name-servers 1.1.1.1, 1.0.0.1;" >> /etc/dhcp/dhcpd.conf
  echo "  default-lease-time 600;" >> /etc/dhcp/dhcpd.conf
  echo "  max-lease-time 7200;" >> /etc/dhcp/dhcpd.conf
  echo "" >> /etc/dhcp/dhcpd.conf
  echo "  host PrimeraReserva {" >> /etc/dhcp/dhcpd.conf
  echo "    hardware ethernet 00:00:00:00:00:01;" >> /etc/dhcp/dhcpd.conf
  echo "    fixed-address 192.168.1.10;" >> /etc/dhcp/dhcpd.conf
  echo "  }" >> /etc/dhcp/dhcpd.conf
  echo "}" >> /etc/dhcp/dhcpd.conf

  echo ""
  echo "Descargando archivo de nombres de fabricantes..."
  echo ""
  wget -O /usr/local/etc/oui.txt http://standards-oui.ieee.org/oui/oui.txt

  echo ""
  echo "----------------------------------------------------------------------"
  echo "  FINALIZADO. REINICIA EL SISTEMA EJECUTANDO:"
  echo "  shutdown -r now"
  echo "  Y DESPUÉS DE REINICIAR TU DEBIAN DEBERÍA ESTAR SIRVIENDO IPs"
  echo "  EN LA SEGUNDA INTERFAZ CABLEADA Y OPERANDO COMO ROUTER."
  echo "  PODRÁS CONECTARLE AL 2DO PUERTO ETHERNET TANTO UN PUNTO DE ACCESO"
  echo "  COMO UN ROUTER EN MODO PUENTE Y YA PODRÄS TENER WIFI"
  echo "----------------------------------------------------------------------"
  echo ""

elif [ $OS_VERS == "10" ]; then

  echo ""
  echo "------------------------------------------------------------------------------"
  echo "  Iniciando el script de instalación de xxxxxxxxx para Debian 10 (Buster)..."
  echo "------------------------------------------------------------------------------"
  echo ""

  echo ""
  echo "  Comandos para Debian 10 todavía no preparados. Prueba ejecutar el script en otra versión de Debian."
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

