#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para instalar y configurar xxxxxxxxx en Debian
#
#  Ejecución remota:
#  curl -s https://raw.githubusercontent.com/nipegun/r-scripts/master/PostInst/RoutearPor-eth1.sh | bash
#  curl -s https://raw.githubusercontent.com/nipegun/r-scripts/master/PostInst/RoutearPor-eth1.sh | sed 's-vLANIP="192.168.1"-vLANIP="192.168.90"-g' | bash
# ----------

vIntEth0="eth0"
vIntEth1="eth1"
vLANIP="192.168.1"

# Comprobar si el script está corriendo como root
  if [ $(id -u) -ne 0 ]; then
    echo "Este script está preparado para ejecutarse como root y no lo has ejecutado como root." >&2
    exit 1
  fi

ColorAzul="\033[0;34m"
ColorAzulClaro="\033[1;34m"
ColorVerde='\033[1;32m'
ColorRojo='\033[1;31m'
FinColor='\033[0m'

# Comprobar si el paquete curl está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s curl 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${ColorRojo}  curl no está instalado. Iniciando su instalación...${FinColor}"
    echo ""
    sudo apt-get -y update > /dev/null
    sudo apt-get -y install curl
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
  echo -e "${ColorAzul}  Iniciando el script de preparación de Debian 7 (Wheezy) como router por eth1...${FinColor}"
  echo ""

  echo ""
  echo -e "${ColorRojo}  Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${FinColor}"
  echo ""

elif [ $OS_VERS == "8" ]; then

  echo ""
  echo -e "${ColorAzul}  Iniciando el script de preparación de Debian 8 (Jessie) como router por eth1...${FinColor}"
  echo ""

  echo ""
  echo -e "${ColorRojo}  Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${FinColor}"
  echo ""

elif [ $OS_VERS == "9" ]; then

  echo ""
  echo -e "${ColorAzul}  Iniciando el script de preparación de Debian 9 (Stretch) como router por eth1...${FinColor}"
  echo ""

  echo ""
  echo -e "${ColorRojo}  Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${FinColor}"
  echo ""

elif [ $OS_VERS == "10" ]; then

  echo ""
  echo -e "${ColorAzul}  Iniciando el script de preparación de Debian 10 (Buster) como router por eth1...${FinColor}"
  echo ""

  # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${ColorRojo}  dialog no está instalado. Iniciando su instalación...${FinColor}"
      echo ""
      apt-get -y update
      apt-get -y install dialog
      echo ""
    fi

  menu=(dialog --timeout 5 --checklist "Selecciona las funcionalidades a instalar:" 22 96 16)
    opciones=(
      1 "Configurar tarjetas de red." on
      2 "Habilitar el forwarding entre interfaces." on
      3 "Agregar funcioalidad NAT." on
      4 "Agregar funcionalidad DHCP." off
      5 "Agregar funcionalidad DNS." off
      6 "..." off
      7 "..." off
      8 "..." off
      9 "..." off
     10 "..." off
     11 "..." off
     12 "..." off
    )
    choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
    clear

    for choice in $choices
      do
        case $choice in

          1)

            echo ""
            echo -e "${ColorAzulClaro}  Configurando tarjetas de red...${FinColor}"
            echo ""

            echo ""
            echo "    Configurando la interfaz loopback"
            echo ""
            echo "auto lo"                                                    > /etc/network/interfaces
            echo "  iface lo inet loopback"                                  >> /etc/network/interfaces
            echo "  pre-up iptables-restore < /root/ReglasIPTablesNAT.rules" >> /etc/network/interfaces
            echo ""                                                          >> /etc/network/interfaces

            echo ""
            echo "    Configurando la 1ra interfaz ethernet"
            echo ""
            echo "auto $vIntEth0"                                            >> /etc/network/interfaces
            echo "  allow-hotplug $vIntEth0"                                 >> /etc/network/interfaces
            echo "  iface $vIntEth0 inet dhcp"                               >> /etc/network/interfaces
            echo ""                                                          >> /etc/network/interfaces

            echo ""
            echo "    Configurando la 2da interfaz ethenet"
            echo ""
            echo "auto $vIntEth1"                                            >> /etc/network/interfaces
            echo "  iface $vIntEth1 inet static"                             >> /etc/network/interfaces
            echo "  address $vLANIP.1"                                       >> /etc/network/interfaces
            echo "  network $vLANIP.0"                                       >> /etc/network/interfaces
            echo "  netmask 255.255.255.0"                                   >> /etc/network/interfaces
            echo "  broadcast $vLANIP.255"                                   >> /etc/network/interfaces
            echo ""                                                          >> /etc/network/interfaces

          ;;

          2)

            echo ""
            echo -e "${ColorAzulClaro}    Habilitando el forwarding entre interfaces...${FinColor}"
            echo ""
            cp /etc/sysctl.conf /etc/sysctl.conf.bak
            sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

          ;;

          3)

            echo ""
            echo -e "${ColorAzulClaro}  Agregando la funcionalidad NAT...${FinColor}"
            echo ""
            # Crear el archivo de reglas
              echo "*mangle"                                                                              > /root/ReglasIPTablesNAT.rules
              echo ":PREROUTING ACCEPT [0:0]"                                                            >> /root/ReglasIPTablesNAT.rules
              echo ":INPUT ACCEPT [0:0]"                                                                 >> /root/ReglasIPTablesNAT.rules
              echo ":FORWARD ACCEPT [0:0]"                                                               >> /root/ReglasIPTablesNAT.rules
              echo ":OUTPUT ACCEPT [0:0]"                                                                >> /root/ReglasIPTablesNAT.rules
              echo ":POSTROUTING ACCEPT [0:0]"                                                           >> /root/ReglasIPTablesNAT.rules
              echo "COMMIT"                                                                              >> /root/ReglasIPTablesNAT.rules
              echo ""                                                                                    >> /root/ReglasIPTablesNAT.rules
              echo "*nat"                                                                                >> /root/ReglasIPTablesNAT.rules
              echo ":PREROUTING ACCEPT [0:0]"                                                            >> /root/ReglasIPTablesNAT.rules
              echo ":INPUT ACCEPT [0:0]"                                                                 >> /root/ReglasIPTablesNAT.rules
              echo ":OUTPUT ACCEPT [0:0]"                                                                >> /root/ReglasIPTablesNAT.rules
              echo ":POSTROUTING ACCEPT [0:0]"                                                           >> /root/ReglasIPTablesNAT.rules
              echo "-A POSTROUTING -o $vIntEth0 -j MASQUERADE"                                           >> /root/ReglasIPTablesNAT.rules
              echo "COMMIT"                                                                              >> /root/ReglasIPTablesNAT.rules
              echo ""                                                                                    >> /root/ReglasIPTablesNAT.rules
              echo "*filter"                                                                             >> /root/ReglasIPTablesNAT.rules
              echo ":INPUT ACCEPT [0:0]"                                                                 >> /root/ReglasIPTablesNAT.rules
              echo ":FORWARD ACCEPT [0:0]"                                                               >> /root/ReglasIPTablesNAT.rules
              echo ":OUTPUT ACCEPT [0:0]"                                                                >> /root/ReglasIPTablesNAT.rules
              echo "-A FORWARD -i $vIntEth0 -o $vIntEth1 -m state --state RELATED,ESTABLISHED -j ACCEPT" >> /root/ReglasIPTablesNAT.rules
              echo "-A FORWARD -i $vIntEth1 -o $vIntEth0 -j ACCEPT"                                      >> /root/ReglasIPTablesNAT.rules
              echo "COMMIT"                                                                              >> /root/ReglasIPTablesNAT.rules

            # Recargar las reglas generales de NFTables
              iptables-restore < /root/ReglasIPTablesNAT.rules

            # Agregar las reglas a los ComandosPostArranque
              sed -i -e 's|iptables-restore < /root/ReglasIPTablesNAT.rules||g' /root/scripts/ComandosPostArranque.sh
              echo "iptables-restore < /root/ReglasIPTablesNAT.rules" >>        /root/scripts/ComandosPostArranque.sh

          ;;

          4)

            echo ""
            echo -e "${ColorAzulClaro}  Agregando la funcionalidad DHCP...${FinColor}"
            echo ""

            echo ""
            echo "    Instalando isc-dhcp-server..."
            echo ""
            apt-get -y install isc-dhcp-server
  
            echo ""
            echo "    Indicando la ubicación del archivo de configuración del demonio dhcpd"
            echo "    y la interfaz sobre la que correrá..."
            echo ""
            cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
            echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'  > /etc/default/isc-dhcp-server
            echo 'INTERFACESv4="$vIntEth1"'          >> /etc/default/isc-dhcp-server
            echo 'INTERFACESv6=""'                   >> /etc/default/isc-dhcp-server

            echo ""
            echo "    Configurando dhcp..."
            echo ""
            cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
            echo "authoritative;"                                  > /etc/dhcp/dhcpd.conf
            echo "subnet $vLANIP.0 netmask 255.255.255.0 {"       >> /etc/dhcp/dhcpd.conf
            echo "  range $vLANIP.100 $vLANIP.199;"               >> /etc/dhcp/dhcpd.conf
            echo "  option routers $vLANIP.1;"                    >> /etc/dhcp/dhcpd.conf
            echo "  option domain-name-servers 1.1.1.1, 1.0.0.1;" >> /etc/dhcp/dhcpd.conf
            echo "  default-lease-time 600;"                      >> /etc/dhcp/dhcpd.conf
            echo "  max-lease-time 7200;"                         >> /etc/dhcp/dhcpd.conf
            echo ""                                               >> /etc/dhcp/dhcpd.conf
            echo "  host PrimeraReserva {"                        >> /etc/dhcp/dhcpd.conf
            echo "    hardware ethernet 00:00:00:00:00:01;"       >> /etc/dhcp/dhcpd.conf
            echo "    fixed-address $vLANIP.10;"                  >> /etc/dhcp/dhcpd.conf
            echo "  }"                                            >> /etc/dhcp/dhcpd.conf
            echo "}"                                              >> /etc/dhcp/dhcpd.conf

            echo ""
            echo "    Descargando archivo de nombres de fabricantes..."
            echo ""
            # Comprobar si el paquete wget está instalado. Si no lo está, instalarlo.
              if [[ $(dpkg-query -s wget 2>/dev/null | grep installed) == "" ]]; then
                echo ""
                echo -e "${ColorRojo}  wget no está instalado. Iniciando su instalación...${FinColor}"
                echo ""
                apt-get -y update && apt-get -y install wget
                echo ""
              fi
            wget -O /usr/local/etc/oui.txt http://standards-oui.ieee.org/oui/oui.txt

          ;;

          5)

            echo ""
            echo -e "${ColorAzulClaro}  Agregando la funcionalidad DNS...${FinColor}"
            echo ""

          ;;

          6)

          ;;
    
          9)

          ;;

          10)

          ;;

          11)

          ;;

          12)

          ;;

        esac

  done

elif [ $OS_VERS == "11" ]; then

  echo ""
  echo -e "${ColorAzul}  Iniciando el script de preparación de Debian 11 (Bullseye) como router por eth1...${FinColor}"
  echo ""

  # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${ColorRojo}  dialog no está instalado. Iniciando su instalación...${FinColor}"
      echo ""
      apt-get -y update
      apt-get -y install dialog
      echo ""
    fi

  menu=(dialog --timeout 5 --checklist "Selecciona las funcionalidades a instalar:" 22 96 16)
    opciones=(
      1 "Configurar tarjetas de red." on
      2 "Habilitar el forwarding entre interfaces." on
      3 "Agregar funcioalidad NAT." on
      4 "Agregar funcionalidad DHCP." off
      5 "Agregar funcionalidad DNS." off
      6 "..." off
      7 "..." off
      8 "..." off
      9 "..." off
     10 "..." off
     11 "..." off
     12 "..." off
    )
    choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)
    clear

    for choice in $choices
      do
        case $choice in

          1)

            echo ""
            echo -e "${ColorAzulClaro}  Configurando tarjetas de red...${FinColor}"
            echo ""

            echo ""
            echo "    Configurando la interfaz loopback"
            echo ""
            echo "auto lo"                                 > /etc/network/interfaces
            echo "  iface lo inet loopback"               >> /etc/network/interfaces
            echo "  pre-up nft --file /etc/nftables.conf" >> /etc/network/interfaces
            echo ""                                       >> /etc/network/interfaces

            echo ""
            echo "    Configurando la 1ra interfaz ethernet"
            echo ""
            echo "auto $vIntEth0"                         >> /etc/network/interfaces
            echo "  allow-hotplug $vIntEth0"              >> /etc/network/interfaces
            echo "  iface $vIntEth0 inet dhcp"            >> /etc/network/interfaces
            echo ""                                       >> /etc/network/interfaces

            echo ""
            echo "    Configurando la 2da interfaz ethenet"
            echo ""
            echo "auto $vIntEth1"                         >> /etc/network/interfaces
            echo "  iface $vIntEth1 inet static"          >> /etc/network/interfaces
            echo "  address $vLANIP.1"                    >> /etc/network/interfaces
            echo "  network $vLANIP.0"                    >> /etc/network/interfaces
            echo "  netmask 255.255.255.0"                >> /etc/network/interfaces
            echo "  broadcast $vLANIP.255"                >> /etc/network/interfaces
            echo ""                                       >> /etc/network/interfaces

          ;;

          2)

            echo ""
            echo -e "${ColorAzulClaro}    Habilitando el forwarding entre interfaces...${FinColor}"
            echo ""
            cp /etc/sysctl.conf /etc/sysctl.conf.bak
            sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

          ;;

          3)

            echo ""
            echo -e "${ColorAzulClaro}  Agregando la funcionalidad NAT...${FinColor}"
            echo ""
            # Crear el archivo de reglas
              echo ""
              echo "  Creando las reglas para el NATeo..."
              echo ""
              echo "table inet filter {"                                                           > /root/ReglasNFTablesNAT.rules
              echo "}"                                                                            >> /root/ReglasNFTablesNAT.rules
              echo ""                                                                             >> /root/ReglasNFTablesNAT.rules
              echo "table ip nat {"                                                               >> /root/ReglasNFTablesNAT.rules
              echo "  chain postrouting {"                                                        >> /root/ReglasNFTablesNAT.rules
              echo "    type nat hook postrouting priority 100; policy accept;"                   >> /root/ReglasNFTablesNAT.rules
              echo '    oifname '"$vIntEth0"' ip saddr '"$vLANIP"'.0/24 counter masquerade'       >> /root/ReglasNFTablesNAT.rules
              echo "  }"                                                                          >> /root/ReglasNFTablesNAT.rules
              echo ""                                                                             >> /root/ReglasNFTablesNAT.rules
              echo "  chain prerouting {"                                                         >> /root/ReglasNFTablesNAT.rules
              echo "    type nat hook prerouting priority 0; policy accept;"                      >> /root/ReglasNFTablesNAT.rules
              echo '    iifname '"$vIntEth0"' tcp dport 33892 counter dnat to '"$vLANIP"'.2:3389' >> /root/ReglasNFTablesNAT.rules
              echo '    iifname '"$vIntEth0"' tcp dport 33893 counter dnat to '"$vLANIP"'.3:3389' >> /root/ReglasNFTablesNAT.rules
              echo '    iifname '"$vIntEth0"' tcp dport 33894 counter dnat to '"$vLANIP"'.4:3389' >> /root/ReglasNFTablesNAT.rules
              echo "  }"                                                                          >> /root/ReglasNFTablesNAT.rules
              echo "}"                                                                            >> /root/ReglasNFTablesNAT.rules

            # Agregar las reglas al archivo de configuración de NFTables
              sed -i '/^flush ruleset/a include "/root/ReglasNFTablesNAT.rules"' /etc/nftables.conf
              sed -i -e 's|flush ruleset|flush ruleset\n|g'                      /etc/nftables.conf

            # Recargar las reglas generales de NFTables
              nft --file /etc/nftables.conf

            # Agregar las reglas a los ComandosPostArranque
              sed -i -e 's|nft --file /etc/nftables.conf||g' /root/scripts/ComandosPostArranque.sh
              echo "nft --file /etc/nftables.conf" >>        /root/scripts/ComandosPostArranque.sh

          ;;

          4)

            echo ""
            echo -e "${ColorAzulClaro}  Agregando la funcionalidad DHCP...${FinColor}"
            echo ""

            echo ""
            echo "    Instalando isc-dhcp-server..."
            echo ""
            apt-get -y install isc-dhcp-server
  
            echo ""
            echo "    Indicando la ubicación del archivo de configuración del demonio dhcpd"
            echo "    y la interfaz sobre la que correrá..."
            echo ""
            cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
            echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'  > /etc/default/isc-dhcp-server
            echo 'INTERFACESv4="$vIntEth1"'          >> /etc/default/isc-dhcp-server
            echo 'INTERFACESv6=""'                   >> /etc/default/isc-dhcp-server

            echo ""
            echo "    Configurando dhcp..."
            echo ""
            cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
            echo "authoritative;"                                  > /etc/dhcp/dhcpd.conf
            echo "subnet $vLANIP.0 netmask 255.255.255.0 {"       >> /etc/dhcp/dhcpd.conf
            echo "  range $vLANIP.100 $vLANIP.199;"               >> /etc/dhcp/dhcpd.conf
            echo "  option routers $vLANIP.1;"                    >> /etc/dhcp/dhcpd.conf
            echo "  option domain-name-servers 1.1.1.1, 1.0.0.1;" >> /etc/dhcp/dhcpd.conf
            echo "  default-lease-time 600;"                      >> /etc/dhcp/dhcpd.conf
            echo "  max-lease-time 7200;"                         >> /etc/dhcp/dhcpd.conf
            echo ""                                               >> /etc/dhcp/dhcpd.conf
            echo "  host PrimeraReserva {"                        >> /etc/dhcp/dhcpd.conf
            echo "    hardware ethernet 00:00:00:00:00:01;"       >> /etc/dhcp/dhcpd.conf
            echo "    fixed-address $vLANIP.10;"                  >> /etc/dhcp/dhcpd.conf
            echo "  }"                                            >> /etc/dhcp/dhcpd.conf
            echo "}"                                              >> /etc/dhcp/dhcpd.conf

            echo ""
            echo "    Descargando archivo de nombres de fabricantes..."
            echo ""
            # Comprobar si el paquete wget está instalado. Si no lo está, instalarlo.
              if [[ $(dpkg-query -s wget 2>/dev/null | grep installed) == "" ]]; then
                echo ""
                echo -e "${ColorRojo}  wget no está instalado. Iniciando su instalación...${FinColor}"
                echo ""
                apt-get -y update && apt-get -y install wget
                echo ""
              fi
            wget -O /usr/local/etc/oui.txt http://standards-oui.ieee.org/oui/oui.txt

          ;;

          5)

            echo ""
            echo -e "${ColorAzulClaro}  Agregando la funcionalidad DNS...${FinColor}"
            echo ""

            # Desinstalar cualquier posible paquete previamente instalado
              mkdir -p /CopSegInt/ 2> /dev/null
              mkdir -p /CopSegInt/DNS/etc/ 2> /dev/null
              mv /etc/bind/ /CopSegInt/DNS/etc/
              chattr -i /etc/resolv.conf
              rm -rf /var/cache/bind/ 2> /dev/null
              rm -rf /etc/bind/ 2> /dev/null
              systemctl stop bind9.service
              systemctl disable bind9.service
              apt-get -y purge bind9 dnsutils

            echo ""
            echo "    Instalando paquetes necesarios..."
            echo ""
            apt-get -y update
            apt-get -y install bind9
            apt-get -y install dnsutils

            echo ""
            echo "    Realizando cambios en la configuración..."
            echo ""
            sed -i "1s|^|nameserver 127.0.0.1\n|" /etc/resolv.conf
            sed -i -e 's|// forwarders {|forwarders {|g' /etc/bind/named.conf.options
            sed -i "/0.0.0.0;/c\1.1.1.1;"                /etc/bind/named.conf.options
            sed -i -e 's|// };|};|g'                     /etc/bind/named.conf.options

            echo ""
            echo "    Creando zona DNS de prueba..."
            echo ""
            echo 'zone "prueba.com" {'               >> /etc/bind/named.conf.local
            echo "  type master;"                    >> /etc/bind/named.conf.local
            echo '  file "/etc/bind/db.prueba.com";' >> /etc/bind/named.conf.local
            echo "};"                                >> /etc/bind/named.conf.local

            echo ""
            echo "    Creando la base de datos de prueba..."
            echo ""
            cp /etc/bind/db.local /etc/bind/db.prueba.com
            echo -e "router\tIN\tA\t$vLANIP.1"     >> /etc/bind/db.prueba.com
            echo -e "servidor\tIN\tA\t$vLANIP.10"  >> /etc/bind/db.prueba.com
            echo -e "impresora\tIN\tA\t$vLANIP.11" >> /etc/bind/db.prueba.com

            echo ""
            echo "    Corrigiendo los posibles errores de IPv6..."
            echo ""
            sed -i -e 's|RESOLVCONF=no|RESOLVCONF=yes|g'           /etc/default/named
            sed -i -e 's|OPTIONS="-u bind"|OPTIONS="-4 -u bind"|g' /etc/default/named

            echo ""
            echo "    Configurando logs..."
            echo ""
            echo 'include "/etc/bind/named.conf.log";' >> /etc/bind/named.conf

            echo 'logging {'                                                            > /etc/bind/named.conf.log
            echo '  channel "default" {'                                               >> /etc/bind/named.conf.log
            echo '    file "/var/log/named/default.log" versions 10 size 10m;'         >> /etc/bind/named.conf.log
            echo '    print-time YES;'                                                 >> /etc/bind/named.conf.log
            echo '    print-severity YES;'                                             >> /etc/bind/named.conf.log
            echo '    print-category YES;'                                             >> /etc/bind/named.conf.log
            echo '  };'                                                                >> /etc/bind/named.conf.log
            echo ''                                                                    >> /etc/bind/named.conf.log
            echo '  channel "lame-servers" {'                                          >> /etc/bind/named.conf.log
            echo '    file "/var/log/named/lame-servers.log" versions 1 size 5m;'      >> /etc/bind/named.conf.log
            echo '    print-time yes;'                                                 >> /etc/bind/named.conf.log
            echo '    print-severity yes;'                                             >> /etc/bind/named.conf.log
            echo '    severity info;'                                                  >> /etc/bind/named.conf.log
            echo '  };'                                                                >> /etc/bind/named.conf.log
            echo ''                                                                    >> /etc/bind/named.conf.log
            echo '  channel "queries" {'                                               >> /etc/bind/named.conf.log
            echo '    file "/var/log/named/queries.log" versions 10 size 10m;'         >> /etc/bind/named.conf.log
            echo '    print-time YES;'                                                 >> /etc/bind/named.conf.log
            echo '    print-severity NO;'                                              >> /etc/bind/named.conf.log
            echo '    print-category NO;'                                              >> /etc/bind/named.conf.log
            echo '  };'                                                                >> /etc/bind/named.conf.log
            echo ''                                                                    >> /etc/bind/named.conf.log
            echo '  channel "security" {'                                              >> /etc/bind/named.conf.log
            echo '    file "/var/log/named/security.log" versions 10 size 10m;'        >> /etc/bind/named.conf.log
            echo '    print-time YES;'                                                 >> /etc/bind/named.conf.log
            echo '    print-severity NO;'                                              >> /etc/bind/named.conf.log
            echo '    print-category NO;'                                              >> /etc/bind/named.conf.log
            echo '  };'                                                                >> /etc/bind/named.conf.log
            echo ''                                                                    >> /etc/bind/named.conf.log
            echo '  channel "update" {'                                                >> /etc/bind/named.conf.log
            echo '    file "/var/log/named/update.log" versions 10 size 10m;'          >> /etc/bind/named.conf.log
            echo '    print-time YES;'                                                 >> /etc/bind/named.conf.log
            echo '    print-severity NO;'                                              >> /etc/bind/named.conf.log
            echo '    print-category NO;'                                              >> /etc/bind/named.conf.log
            echo '  };'                                                                >> /etc/bind/named.conf.log
            echo ''                                                                    >> /etc/bind/named.conf.log
            echo '  channel "update-security" {'                                       >> /etc/bind/named.conf.log
            echo '    file "/var/log/named/update-security.log" versions 10 size 10m;' >> /etc/bind/named.conf.log
            echo '    print-time YES;'                                                 >> /etc/bind/named.conf.log
            echo '    print-severity NO;'                                              >> /etc/bind/named.conf.log
            echo '    print-category NO;'                                              >> /etc/bind/named.conf.log
            echo '  };'                                                                >> /etc/bind/named.conf.log
            echo ''                                                                    >> /etc/bind/named.conf.log
            echo '  category "default"         { "default"; };'                        >> /etc/bind/named.conf.log
            echo '  category "lame-servers"    { "lame-servers"; };'                   >> /etc/bind/named.conf.log
            echo '  category "queries"         { "queries"; };'                        >> /etc/bind/named.conf.log
            echo '  category "security"        { "security"; };'                       >> /etc/bind/named.conf.log
            echo '  category "update"          { "update"; };'                         >> /etc/bind/named.conf.log
            echo '  category "update-security" { "update-security"; };'                >> /etc/bind/named.conf.log
            echo ''                                                                    >> /etc/bind/named.conf.log
            echo '};'                                                                  >> /etc/bind/named.conf.log

            mkdir /var/log/named
            chown -R bind:bind /var/log/named

            chattr +i /etc/resolv.conf

            echo ""
            echo "    Reiniciando el servidor DNS..."
            echo ""
            service bind9 restart

            echo ""
            echo "    Mostrando el estado del servidor DNS..."
            echo ""
            service bind9 status

          ;;

          6)

          ;;
    
          9)

          ;;

          10)

          ;;

          11)

          ;;

          12)

          ;;

        esac

  done

fi
