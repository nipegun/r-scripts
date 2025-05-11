#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para crear un punto de acceso completo usando la wlan0
#
# Ejecución remota (puede requerir permisos sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/r-scripts/refs/heads/master/PostInst/Router-wlan0.sh | bash
#
# Ejecución remota como root (para sistemas sin sudo):
#   curl -sL https://raw.githubusercontent.com/nipegun/r-scripts/refs/heads/master/PostInst/Router-wlan0.sh | sed 's-sudo--g' | bash
#
# Bajar y editar directamente el archivo en nano
#   curl -sL https://raw.githubusercontent.com/nipegun/r-scripts/refs/heads/master/PostInst/Router-wlan0.sh | nano -
# ----------

vInterfazCableada0='eth0'
vInterfazInalambrica0='wlan0'

# Definir constantes de color
  cColorAzul='\033[0;34m'
  cColorAzulClaro='\033[1;34m'
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Determinar la versión de Debian
  if [ -f /etc/os-release ]; then             # Para systemd y freedesktop.org.
    . /etc/os-release
    cNomSO=$NAME
    cVerSO=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then # Para linuxbase.org.
    cNomSO=$(lsb_release -si)
    cVerSO=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then          # Para algunas versiones de Debian sin el comando lsb_release.
    . /etc/lsb-release
    cNomSO=$DISTRIB_ID
    cVerSO=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then       # Para versiones viejas de Debian.
    cNomSO=Debian
    cVerSO=$(cat /etc/debian_version)
  else                                        # Para el viejo uname (También funciona para BSD).
    cNomSO=$(uname -s)
    cVerSO=$(uname -r)
  fi

# Ejecutar comandos dependiendo de la versión de Debian detectada

  if [ $cVerSO == "13" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de transformación de Debian 13 (x) en un punto de acceso completo...${cFinColor}"
    echo ""

    echo ""
    echo -e "${cColorRojo}    Comandos para Debian 13 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${cFinColor}"
    echo ""

  elif [ $cVerSO == "12" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de transformación de Debian 12 (Bookworm)...${cFinColor}"
    echo ""

    # Instalar paquetes necesarios
      echo ""
      echo "  Instalando paquetes necsarios..."
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install isc-dhcp-server
      sudo apt-get -y install hostapd
      sudo apt-get -y install nftables

    # Habilitar el forwarding
      echo ""
      echo "  Habilitando el forwarding IPv4 entre interfaces..."
      echo ""
      sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
      sudo sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

    # Indicar la ubicación del archivo de configuración de hostapd
      echo ""
      echo "  Indicando la ubicación del archivo de configuración de hostapd..."
      echo ""
      sudo cp /etc/default/hostapd /etc/default/hostapd.bak
      sudo sed -i -e 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g'      /etc/default/hostapd
      sudo sed -i -e 's|#DAEMON_OPTS=""|DAEMON_OPTS="-dd -t -f /var/log/hostapd.log"|g' /etc/default/hostapd

    # Configurar el demonio hostapd para un punto de acceso básico
      echo ""
      echo "  Configurando el demonio hostapd para un punto de acceso básico..."
      echo ""
      echo "#/etc/hostapd/hostapd.conf"       | sudo tee    /etc/hostapd/hostapd.conf
      echo "interface=$vInterfazInalambrica0" | sudo tee -a /etc/hostapd/hostapd.conf
      echo "driver=nl80211"                   | sudo tee -a /etc/hostapd/hostapd.conf
      echo "#bridge=br0"                      | sudo tee -a /etc/hostapd/hostapd.conf
      echo "country_code=ES"                  | sudo tee -a /etc/hostapd/hostapd.conf
      echo "channel=1"                        | sudo tee -a /etc/hostapd/hostapd.conf
      echo "ssid=MiAP"                        | sudo tee -a /etc/hostapd/hostapd.conf

    # Desenmascarar y activar el servicio (Si no, con entorno gráfico NetworkManager no lo deja iniciar)
      echo ""
      echo "  Desenmascarando y activando el servicio hostapd..."
      echo ""
      sudo systemctl unmask hostapd
      sudo systemctl enable hostapd --now

    # Indicar la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá
      echo ""
      echo "  Indicando la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá..."
      echo ""
      sudo cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
      echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'       | sudo tee    /etc/default/isc-dhcp-server
      echo 'INTERFACESv4='"$vInterfazInalambrica0"'' | sudo tee -a /etc/default/isc-dhcp-server
      echo 'INTERFACESv6=""'                         | sudo tee -a /etc/default/isc-dhcp-server

    # Configurar el servidor DHCP
      echo ""
      echo "  Configurando el servidor DHCP"
      echo ""
      sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
      echo "authoritative;"                                         | sudo tee    /etc/dhcp/dhcpd.conf
      echo "subnet 192.168.100.0 netmask 255.255.255.0 {"           | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  range 192.168.100.100 192.168.100.199;"               | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  option routers 192.168.100.1;"                        | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  option domain-name-servers 9.9.9.9, 149.112.112.112;" | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  default-lease-time 600;"                              | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  max-lease-time 7200;"                                 | sudo tee -a /etc/dhcp/dhcpd.conf
      echo ""                                                       | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  host PrimeraReserva {"                                | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "    hardware ethernet 00:00:00:00:00:01;"               | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "    fixed-address 192.168.100.10;"                      | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  }"                                                    | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "}"                                                      | sudo tee -a /etc/dhcp/dhcpd.conf

    # Descargar identificadores MAC de fabricantes 
      echo ""
      echo "  Descargar identificadores MAC de fabricantes ..."
      echo ""
      sudo curl -L http://standards-oui.ieee.org/oui/oui.txt -o /usr/local/etc/oui.txt 

    # Configurar interfaces de red
      echo ""
      echo "  Configurando interfaces de red..."
      echo ""
      sudo cp /etc/network/interfaces /etc/network/interfaces.bak
      echo "auto lo"                                  | sudo tee    /etc/network/interfaces
      echo "iface lo inet loopback"                   | sudo tee -a /etc/network/interfaces
      echo "pre-up nft --file /etc/nftables.conf"     | sudo tee -a /etc/network/interfaces
      echo ""                                         | sudo tee -a /etc/network/interfaces
      echo "auto $vInterfazCableada0"                 | sudo tee -a /etc/network/interfaces
      echo "allow-hotplug $vInterfazCableada0"        | sudo tee -a /etc/network/interfaces
      echo "iface $vInterfazCableada0 inet dhcp"      | sudo tee -a /etc/network/interfaces
      echo ""                                         | sudo tee -a /etc/network/interfaces
      echo "auto $vInterfazInalambrica0"              | sudo tee -a /etc/network/interfaces
      echo "iface $vInterfazInalambrica0 inet static" | sudo tee -a /etc/network/interfaces
      echo "address 192.168.100.1"                    | sudo tee -a /etc/network/interfaces
      echo "network 192.168.100.0"                    | sudo tee -a /etc/network/interfaces
      echo "netmask 255.255.255.0"                    | sudo tee -a /etc/network/interfaces
      echo "broadcast 192.168.1.255"                  | sudo tee -a /etc/network/interfaces

    # Crear las reglas para NFTables
      echo ""
      echo "  Creando las reglas para NFTables..."
      echo ""
      echo "table inet filter {"                                                                      | sudo tee    /root/ReglasNFTablesAP.txt
      echo "}"                                                                                        | sudo tee -a /root/ReglasNFTablesAP.txt
      echo ""                                                                                         | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "table ip nat {"                                                                           | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  chain postrouting {"                                                                    | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "    type nat hook postrouting priority 100; policy accept;"                               | sudo tee -a /root/ReglasNFTablesAP.txt
      echo '    oifname "'"$vInterfazCableada0"'" ip saddr 192.168.100.0/24 counter masquerade'       | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  }"                                                                                      | sudo tee -a /root/ReglasNFTablesAP.txt
      echo ""                                                                                         | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  chain prerouting {"                                                                     | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "    type nat hook prerouting priority 0; policy accept;"                                  | sudo tee -a /root/ReglasNFTablesAP.txt
      echo '    iifname "'"$vInterfazCableada0"'" tcp dport 33892 counter dnat to 192.168.100.2:3389' | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  }"                                                                                      | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "}"                                                                                        | sudo tee -a /root/ReglasNFTablesAP.txt
      # Agregar las reglas al archivo de configuración de NFTables
        sudo sed -i '/^flush ruleset/a include "/root/ReglasNFTablesAP.txt"' /etc/nftables.conf
        sudo sed -i -e 's|flush ruleset|flush ruleset\n|g'                   /etc/nftables.conf
      # Recargar las reglas generales de NFTables
        sudo nft --file /etc/nftables.conf
      # Agregar las reglas a los ComandosPostArranque
        ##udo sed -i -e 's|nft --file /etc/nftables.conf||g' /root/scripts/ParaEsteDebian/ComandosPostArranque.sh
        #echo "nft --file /etc/nftables.conf" |  sudo tee -a /root/scripts/ParaEsteDebian/ComandosPostArranque.sh

    # Notificar fin de ejecución del script
      echo ""
      echo "  La ejecución del script ha finalizado."
      echo ""
      echo "    Se ha creado un punto de acceso básico llamado 'MiAP' que sirve IPs en la subred 192.168.100.0/24."
      echo "    Para acelerar la velocidad del punto de acceso habrá que configurar hostapd con las opciones para la tarjeta WiFi instalada."
      echo "    Esto se hace editando el archivo /etc/hostapd/hostapd.conf y agregando capacidades y funcionalidades extra."
      echo "    Es aconsejable reiniciar el sistema, al menos una vez, con:"
      echo ""
      echo "      shutdown -r now"
      echo ""
      echo "    ...antes de conectarse al punto de acceso."
      echo "    Si después de reiniciar, el punto de acceso no aparece, segúramente sea porque el firmware de la tarjeta WiFi no está instalado."
      echo ""

  elif [ $cVerSO == "11" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de transformación de Debian 11 (Bullseye)...${cFinColor}"
    echo ""

    # Instalar paquetes necesarios
      echo ""
      echo "  Instalando paquetes necsarios..."
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install isc-dhcp-server
      sudo apt-get -y install hostapd
      sudo apt-get -y install nftables

    # Habilitar el forwarding
      echo ""
      echo "  Habilitando el forwarding IPv4 entre interfaces..."
      echo ""
      sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
      sudo sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

    # Indicar la ubicación del archivo de configuración de hostapd
      echo ""
      echo "  Indicando la ubicación del archivo de configuración de hostapd..."
      echo ""
      sudo cp /etc/default/hostapd /etc/default/hostapd.bak
      sudo sed -i -e 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g'      /etc/default/hostapd
      sudo sed -i -e 's|#DAEMON_OPTS=""|DAEMON_OPTS="-dd -t -f /var/log/hostapd.log"|g' /etc/default/hostapd

    # Configurar el demonio hostapd para un punto de acceso básico
      echo ""
      echo "  Configurando el demonio hostapd para un punto de acceso básico..."
      echo ""
      echo "#/etc/hostapd/hostapd.conf"       | sudo tee    /etc/hostapd/hostapd.conf
      echo "interface=$vInterfazInalambrica0" | sudo tee -a /etc/hostapd/hostapd.conf
      echo "driver=nl80211"                   | sudo tee -a /etc/hostapd/hostapd.conf
      echo "#bridge=br0"                      | sudo tee -a /etc/hostapd/hostapd.conf
      echo "country_code=ES"                  | sudo tee -a /etc/hostapd/hostapd.conf
      echo "channel=1"                        | sudo tee -a /etc/hostapd/hostapd.conf
      echo "ssid=MiAP"                        | sudo tee -a /etc/hostapd/hostapd.conf

    # Desenmascarar y activar el servicio (Si no, con entorno gráfico NetworkManager no lo deja iniciar)
      echo ""
      echo "  Desenmascarando y activando el servicio hostapd..."
      echo ""
      sudo systemctl unmask hostapd
      sudo systemctl enable hostapd --now

    # Indicar la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá
      echo ""
      echo "  Indicando la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá..."
      echo ""
      sudo cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
      echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'       | sudo tee    /etc/default/isc-dhcp-server
      echo 'INTERFACESv4='"$vInterfazInalambrica0"'' | sudo tee -a /etc/default/isc-dhcp-server
      echo 'INTERFACESv6=""'                         | sudo tee -a /etc/default/isc-dhcp-server

    # Configurar el servidor DHCP
      echo ""
      echo "  Configurando el servidor DHCP"
      echo ""
      sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
      echo "authoritative;"                                         | sudo tee    /etc/dhcp/dhcpd.conf
      echo "subnet 192.168.100.0 netmask 255.255.255.0 {"           | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  range 192.168.100.100 192.168.100.199;"               | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  option routers 192.168.100.1;"                        | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  option domain-name-servers 9.9.9.9, 149.112.112.112;" | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  default-lease-time 600;"                              | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  max-lease-time 7200;"                                 | sudo tee -a /etc/dhcp/dhcpd.conf
      echo ""                                                       | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  host PrimeraReserva {"                                | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "    hardware ethernet 00:00:00:00:00:01;"               | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "    fixed-address 192.168.100.10;"                      | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  }"                                                    | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "}"                                                      | sudo tee -a /etc/dhcp/dhcpd.conf

    # Descargar identificadores MAC de fabricantes 
      echo ""
      echo "  Descargar identificadores MAC de fabricantes ..."
      echo ""
      sudo curl -L http://standards-oui.ieee.org/oui/oui.txt -o /usr/local/etc/oui.txt 

    # Configurar interfaces de red
      echo ""
      echo "  Configurando interfaces de red..."
      echo ""
      sudo cp /etc/network/interfaces /etc/network/interfaces.bak
      echo "auto lo"                                  | sudo tee    /etc/network/interfaces
      echo "iface lo inet loopback"                   | sudo tee -a /etc/network/interfaces
      echo "pre-up nft --file /etc/nftables.conf"     | sudo tee -a /etc/network/interfaces
      echo ""                                         | sudo tee -a /etc/network/interfaces
      echo "auto $vInterfazCableada0"                 | sudo tee -a /etc/network/interfaces
      echo "allow-hotplug $vInterfazCableada0"        | sudo tee -a /etc/network/interfaces
      echo "iface $vInterfazCableada0 inet dhcp"      | sudo tee -a /etc/network/interfaces
      echo ""                                         | sudo tee -a /etc/network/interfaces
      echo "auto $vInterfazInalambrica0"              | sudo tee -a /etc/network/interfaces
      echo "iface $vInterfazInalambrica0 inet static" | sudo tee -a /etc/network/interfaces
      echo "address 192.168.100.1"                    | sudo tee -a /etc/network/interfaces
      echo "network 192.168.100.0"                    | sudo tee -a /etc/network/interfaces
      echo "netmask 255.255.255.0"                    | sudo tee -a /etc/network/interfaces
      echo "broadcast 192.168.1.255"                  | sudo tee -a /etc/network/interfaces

    # Crear las reglas para NFTables
      echo ""
      echo "  Creando las reglas para NFTables..."
      echo ""
      echo "table inet filter {"                                                                      | sudo tee    /root/ReglasNFTablesAP.txt
      echo "}"                                                                                        | sudo tee -a /root/ReglasNFTablesAP.txt
      echo ""                                                                                         | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "table ip nat {"                                                                           | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  chain postrouting {"                                                                    | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "    type nat hook postrouting priority 100; policy accept;"                               | sudo tee -a /root/ReglasNFTablesAP.txt
      echo '    oifname "'"$vInterfazCableada0"'" ip saddr 192.168.100.0/24 counter masquerade'       | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  }"                                                                                      | sudo tee -a /root/ReglasNFTablesAP.txt
      echo ""                                                                                         | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  chain prerouting {"                                                                     | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "    type nat hook prerouting priority 0; policy accept;"                                  | sudo tee -a /root/ReglasNFTablesAP.txt
      echo '    iifname "'"$vInterfazCableada0"'" tcp dport 33892 counter dnat to 192.168.100.2:3389' | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  }"                                                                                      | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "}"                                                                                        | sudo tee -a /root/ReglasNFTablesAP.txt
      # Agregar las reglas al archivo de configuración de NFTables
        sudo sed -i '/^flush ruleset/a include "/root/ReglasNFTablesAP.txt"' /etc/nftables.conf
        sudo sed -i -e 's|flush ruleset|flush ruleset\n|g'                   /etc/nftables.conf
      # Recargar las reglas generales de NFTables
        sudo nft --file /etc/nftables.conf
      # Agregar las reglas a los ComandosPostArranque
        ##udo sed -i -e 's|nft --file /etc/nftables.conf||g' /root/scripts/ParaEsteDebian/ComandosPostArranque.sh
        #echo "nft --file /etc/nftables.conf" |  sudo tee -a /root/scripts/ParaEsteDebian/ComandosPostArranque.sh

    # Notificar fin de ejecución del script
      echo ""
      echo "  La ejecución del script ha finalizado."
      echo ""
      echo "    Se ha creado un punto de acceso básico llamado 'MiAP' que sirve IPs en la subred 192.168.100.0/24."
      echo "    Para acelerar la velocidad del punto de acceso habrá que configurar hostapd con las opciones para la tarjeta WiFi instalada."
      echo "    Esto se hace editando el archivo /etc/hostapd/hostapd.conf y agregando capacidades y funcionalidades extra."
      echo "    Es aconsejable reiniciar el sistema, al menos una vez, con:"
      echo ""
      echo "      shutdown -r now"
      echo ""
      echo "    ...antes de conectarse al punto de acceso."
      echo "    Si después de reiniciar, el punto de acceso no aparece, segúramente sea porque el firmware de la tarjeta WiFi no está instalado."
      echo ""

  elif [ $cVerSO == "10" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de transformación de Debian 10 (Buster)...${cFinColor}"
    echo ""

    # Instalar paquetes necesarios
      echo ""
      echo "  Instalando paquetes necsarios..."
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install isc-dhcp-server
      sudo apt-get -y install hostapd
      sudo apt-get -y install nftables

    # Habilitar el forwarding
      echo ""
      echo "  Habilitando el forwarding IPv4 entre interfaces..."
      echo ""
      sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
      sudo sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

    # Indicar la ubicación del archivo de configuración de hostapd
      echo ""
      echo "  Indicando la ubicación del archivo de configuración de hostapd..."
      echo ""
      sudo cp /etc/default/hostapd /etc/default/hostapd.bak
      sudo sed -i -e 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g'      /etc/default/hostapd
      sudo sed -i -e 's|#DAEMON_OPTS=""|DAEMON_OPTS="-dd -t -f /var/log/hostapd.log"|g' /etc/default/hostapd

    # Configurar el demonio hostapd para un punto de acceso básico
      echo ""
      echo "  Configurando el demonio hostapd para un punto de acceso básico..."
      echo ""
      echo "#/etc/hostapd/hostapd.conf"       | sudo tee    /etc/hostapd/hostapd.conf
      echo "interface=$vInterfazInalambrica0" | sudo tee -a /etc/hostapd/hostapd.conf
      echo "driver=nl80211"                   | sudo tee -a /etc/hostapd/hostapd.conf
      echo "#bridge=br0"                      | sudo tee -a /etc/hostapd/hostapd.conf
      echo "country_code=ES"                  | sudo tee -a /etc/hostapd/hostapd.conf
      echo "channel=1"                        | sudo tee -a /etc/hostapd/hostapd.conf
      echo "ssid=MiAP"                        | sudo tee -a /etc/hostapd/hostapd.conf

    # Desenmascarar y activar el servicio (Si no, con entorno gráfico NetworkManager no lo deja iniciar)
      echo ""
      echo "  Desenmascarando y activando el servicio hostapd..."
      echo ""
      sudo systemctl unmask hostapd
      sudo systemctl enable hostapd --now

    # Indicar la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá
      echo ""
      echo "  Indicando la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá..."
      echo ""
      sudo cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
      echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'       | sudo tee    /etc/default/isc-dhcp-server
      echo 'INTERFACESv4='"$vInterfazInalambrica0"'' | sudo tee -a /etc/default/isc-dhcp-server
      echo 'INTERFACESv6=""'                         | sudo tee -a /etc/default/isc-dhcp-server

    # Configurar el servidor DHCP
      echo ""
      echo "  Configurando el servidor DHCP"
      echo ""
      sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
      echo "authoritative;"                                         | sudo tee    /etc/dhcp/dhcpd.conf
      echo "subnet 192.168.100.0 netmask 255.255.255.0 {"           | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  range 192.168.100.100 192.168.100.199;"               | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  option routers 192.168.100.1;"                        | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  option domain-name-servers 9.9.9.9, 149.112.112.112;" | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  default-lease-time 600;"                              | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  max-lease-time 7200;"                                 | sudo tee -a /etc/dhcp/dhcpd.conf
      echo ""                                                       | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  host PrimeraReserva {"                                | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "    hardware ethernet 00:00:00:00:00:01;"               | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "    fixed-address 192.168.100.10;"                      | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  }"                                                    | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "}"                                                      | sudo tee -a /etc/dhcp/dhcpd.conf

    # Descargar identificadores MAC de fabricantes 
      echo ""
      echo "  Descargar identificadores MAC de fabricantes ..."
      echo ""
      sudo curl -L http://standards-oui.ieee.org/oui/oui.txt -o /usr/local/etc/oui.txt 

    # Configurar interfaces de red
      echo ""
      echo "  Configurando interfaces de red..."
      echo ""
      sudo cp /etc/network/interfaces /etc/network/interfaces.bak
      echo "auto lo"                                  | sudo tee    /etc/network/interfaces
      echo "iface lo inet loopback"                   | sudo tee -a /etc/network/interfaces
      echo "pre-up nft --file /etc/nftables.conf"     | sudo tee -a /etc/network/interfaces
      echo ""                                         | sudo tee -a /etc/network/interfaces
      echo "auto $vInterfazCableada0"                 | sudo tee -a /etc/network/interfaces
      echo "allow-hotplug $vInterfazCableada0"        | sudo tee -a /etc/network/interfaces
      echo "iface $vInterfazCableada0 inet dhcp"      | sudo tee -a /etc/network/interfaces
      echo ""                                         | sudo tee -a /etc/network/interfaces
      echo "auto $vInterfazInalambrica0"              | sudo tee -a /etc/network/interfaces
      echo "iface $vInterfazInalambrica0 inet static" | sudo tee -a /etc/network/interfaces
      echo "address 192.168.100.1"                    | sudo tee -a /etc/network/interfaces
      echo "network 192.168.100.0"                    | sudo tee -a /etc/network/interfaces
      echo "netmask 255.255.255.0"                    | sudo tee -a /etc/network/interfaces
      echo "broadcast 192.168.1.255"                  | sudo tee -a /etc/network/interfaces

    # Crear las reglas para NFTables
      echo ""
      echo "  Creando las reglas para NFTables..."
      echo ""
      echo "table inet filter {"                                                                      | sudo tee    /root/ReglasNFTablesAP.txt
      echo "}"                                                                                        | sudo tee -a /root/ReglasNFTablesAP.txt
      echo ""                                                                                         | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "table ip nat {"                                                                           | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  chain postrouting {"                                                                    | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "    type nat hook postrouting priority 100; policy accept;"                               | sudo tee -a /root/ReglasNFTablesAP.txt
      echo '    oifname "'"$vInterfazCableada0"'" ip saddr 192.168.100.0/24 counter masquerade'       | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  }"                                                                                      | sudo tee -a /root/ReglasNFTablesAP.txt
      echo ""                                                                                         | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  chain prerouting {"                                                                     | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "    type nat hook prerouting priority 0; policy accept;"                                  | sudo tee -a /root/ReglasNFTablesAP.txt
      echo '    iifname "'"$vInterfazCableada0"'" tcp dport 33892 counter dnat to 192.168.100.2:3389' | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "  }"                                                                                      | sudo tee -a /root/ReglasNFTablesAP.txt
      echo "}"                                                                                        | sudo tee -a /root/ReglasNFTablesAP.txt
      # Agregar las reglas al archivo de configuración de NFTables
        sudo sed -i '/^flush ruleset/a include "/root/ReglasNFTablesAP.txt"' /etc/nftables.conf
        sudo sed -i -e 's|flush ruleset|flush ruleset\n|g'                   /etc/nftables.conf
      # Recargar las reglas generales de NFTables
        sudo nft --file /etc/nftables.conf
      # Agregar las reglas a los ComandosPostArranque
        ##udo sed -i -e 's|nft --file /etc/nftables.conf||g' /root/scripts/ParaEsteDebian/ComandosPostArranque.sh
        #echo "nft --file /etc/nftables.conf" |  sudo tee -a /root/scripts/ParaEsteDebian/ComandosPostArranque.sh

    # Notificar fin de ejecución del script
      echo ""
      echo "  La ejecución del script ha finalizado."
      echo ""
      echo "    Se ha creado un punto de acceso básico llamado 'MiAP' que sirve IPs en la subred 192.168.100.0/24."
      echo "    Para acelerar la velocidad del punto de acceso habrá que configurar hostapd con las opciones para la tarjeta WiFi instalada."
      echo "    Esto se hace editando el archivo /etc/hostapd/hostapd.conf y agregando capacidades y funcionalidades extra."
      echo "    Es aconsejable reiniciar el sistema, al menos una vez, con:"
      echo ""
      echo "      shutdown -r now"
      echo ""
      echo "    ...antes de conectarse al punto de acceso."
      echo "    Si después de reiniciar, el punto de acceso no aparece, segúramente sea porque el firmware de la tarjeta WiFi no está instalado."
      echo ""

  elif [ $cVerSO == "9" ]; then

    echo ""
    echo -e "${cColorAzulClaro}  Iniciando el script de transformación de Debian 9 (Stretch)...${cFinColor}"
    echo ""

    # Instalar paquetes necesarios
      echo ""
      echo "  Instalando paquetes necsarios..."
      echo ""
      sudo apt-get -y update
      sudo apt-get -y install isc-dhcp-server
      sudo apt-get -y install hostapd
      sudo apt-get -y install iptables

    # Habilitar el forwarding
      echo ""
      echo "  Habilitando el forwarding IPv4 entre interfaces..."
      echo ""
      sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak
      sudo sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

    # Indicar la ubicación del archivo de configuración de hostapd
      echo ""
      echo "  Indicando la ubicación del archivo de configuración de hostapd..."
      echo ""
      sudo cp /etc/default/hostapd /etc/default/hostapd.bak
      sudo sed -i -e 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g'      /etc/default/hostapd
      sudo sed -i -e 's|#DAEMON_OPTS=""|DAEMON_OPTS="-dd -t -f /var/log/hostapd.log"|g' /etc/default/hostapd

    # Configurar el demonio hostapd para un punto de acceso básico
      echo ""
      echo "  Configurando el demonio hostapd para un punto de acceso básico..."
      echo ""
      echo "#/etc/hostapd/hostapd.conf"       | sudo tee    /etc/hostapd/hostapd.conf
      echo "interface=$vInterfazInalambrica0" | sudo tee -a /etc/hostapd/hostapd.conf
      echo "driver=nl80211"                   | sudo tee -a /etc/hostapd/hostapd.conf
      echo "#bridge=br0"                      | sudo tee -a /etc/hostapd/hostapd.conf
      echo "country_code=ES"                  | sudo tee -a /etc/hostapd/hostapd.conf
      echo "channel=1"                        | sudo tee -a /etc/hostapd/hostapd.conf
      echo "ssid=MiAP"                        | sudo tee -a /etc/hostapd/hostapd.conf

    # Desenmascarar y activar el servicio (Si no, con entorno gráfico NetworkManager no lo deja iniciar)
      echo ""
      echo "  Desenmascarando y activando el servicio hostapd..."
      echo ""
      sudo systemctl unmask hostapd
      sudo systemctl enable hostapd --now

    # Indicar la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá
      echo ""
      echo "  Indicando la ubicación del archivo de configuración del demonio dhcpd y la interfaz sobre la que correrá..."
      echo ""
      sudo cp /etc/default/isc-dhcp-server /etc/default/isc-dhcp-server.bak
      echo 'DHCPDv4_CONF=/etc/dhcp/dhcpd.conf'       | sudo tee    /etc/default/isc-dhcp-server
      echo 'INTERFACESv4='"$vInterfazInalambrica0"'' | sudo tee -a /etc/default/isc-dhcp-server
      echo 'INTERFACESv6=""'                         | sudo tee -a /etc/default/isc-dhcp-server

    # Configurar el servidor DHCP
      echo ""
      echo "  Configurando el servidor DHCP"
      echo ""
      sudo cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.bak
      echo "authoritative;"                                         | sudo tee    /etc/dhcp/dhcpd.conf
      echo "subnet 192.168.100.0 netmask 255.255.255.0 {"           | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  range 192.168.100.100 192.168.100.199;"               | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  option routers 192.168.100.1;"                        | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  option domain-name-servers 9.9.9.9, 149.112.112.112;" | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  default-lease-time 600;"                              | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  max-lease-time 7200;"                                 | sudo tee -a /etc/dhcp/dhcpd.conf
      echo ""                                                       | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  host PrimeraReserva {"                                | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "    hardware ethernet 00:00:00:00:00:01;"               | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "    fixed-address 192.168.100.10;"                      | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "  }"                                                    | sudo tee -a /etc/dhcp/dhcpd.conf
      echo "}"                                                      | sudo tee -a /etc/dhcp/dhcpd.conf

    # Descargar identificadores MAC de fabricantes 
      echo ""
      echo "  Descargar identificadores MAC de fabricantes ..."
      echo ""
      sudo curl -L http://standards-oui.ieee.org/oui/oui.txt -o /usr/local/etc/oui.txt 

    # Configurar interfaces de red
      echo ""
      echo "  Configurando interfaces de red..."
      echo ""
      sudo cp /etc/network/interfaces /etc/network/interfaces.bak
      echo "auto lo"                                              | sudo tee    /etc/network/interfaces
      echo "iface lo inet loopback"                               | sudo tee -a /etc/network/interfaces
      echo "pre-up iptables-restore < /root/ReglasIPTablesAP.txt" | sudo tee -a /etc/network/interfaces
      echo ""                                                     | sudo tee -a /etc/network/interfaces
      echo "auto $vInterfazCableada0"                             | sudo tee -a /etc/network/interfaces
      echo "allow-hotplug $vInterfazCableada0"                    | sudo tee -a /etc/network/interfaces
      echo "iface $vInterfazCableada0 inet dhcp"                  | sudo tee -a /etc/network/interfaces
      echo ""                                                     | sudo tee -a /etc/network/interfaces
      echo "auto $vInterfazInalambrica0"                          | sudo tee -a /etc/network/interfaces
      echo "iface $vInterfazInalambrica0 inet static"             | sudo tee -a /etc/network/interfaces
      echo "address 192.168.100.1"                                | sudo tee -a /etc/network/interfaces
      echo "network 192.168.100.0"                                | sudo tee -a /etc/network/interfaces
      echo "netmask 255.255.255.0"                                | sudo tee -a /etc/network/interfaces
      echo "broadcast 192.168.1.255"                              | sudo tee -a /etc/network/interfaces

    # Crear las reglas para IPTables
      echo ""
      echo "  Creando las reglas para NFTables..."
      echo ""
      echo "*mangle"                                                                                                    | sudo tee    /root/ReglasIPTablesAP.txt
      echo ":PREROUTING ACCEPT [0:0]"                                                                                   | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ":INPUT ACCEPT [0:0]"                                                                                        | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ":FORWARD ACCEPT [0:0]"                                                                                      | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ":OUTPUT ACCEPT [0:0"                                                                                        | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ":POSTROUTING ACCEPT [0:0]"                                                                                  | sudo tee -a /root/ReglasIPTablesAP.txt
      echo 'COMMIT'                                                                                                     | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ""                                                                                                           | sudo tee -a /root/ReglasIPTablesAP.txt
      echo "*nat"                                                                                                       | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ":PREROUTING ACCEPT [0:0]"                                                                                   | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ":INPUT ACCEPT [0:0]"                                                                                        | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ':OUTPUT ACCEPT [0:0]'                                                                                       | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ":POSTROUTING ACCEPT [0:0]"                                                                                  | sudo tee -a /root/ReglasIPTablesAP.txt
      echo "-A POSTROUTING -o $vInterfazCableada0 -j MASQUERADE"                                                        | sudo tee -a /root/ReglasIPTablesAP.txt
      echo "COMMIT"                                                                                                     | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ""                                                                                                           | sudo tee -a /root/ReglasIPTablesAP.txt
      echo "*filter"                                                                                                    | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ":INPUT ACCEPT [0:0]"                                                                                        | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ":FORWARD ACCEPT [0:0]"                                                                                      | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ":OUTPUT ACCEPT [0:0]"                                                                                       | sudo tee -a /root/ReglasIPTablesAP.txt
      echo "-A FORWARD -i $vInterfazCableada0 -o $vInterfazInalambrica0 -m state --state RELATED,ESTABLISHED -j ACCEPT" | sudo tee -a /root/ReglasIPTablesAP.txt
      echo "-A FORWARD -i $vInterfazInalambrica0 -o $vInterfazCableada0 -j ACCEPT"                                      | sudo tee -a /root/ReglasIPTablesAP.txt
      echo "COMMIT"                                                                                                     | sudo tee -a /root/ReglasIPTablesAP.txt
      echo ""

    # Notificar fin de ejecución del script
      echo ""
      echo "  La ejecución del script ha finalizado."
      echo ""
      echo "    Se ha creado un punto de acceso básico llamado 'MiAP' que sirve IPs en la subred 192.168.100.0/24."
      echo "    Para acelerar la velocidad del punto de acceso habrá que configurar hostapd con las opciones para la tarjeta WiFi instalada."
      echo "    Esto se hace editando el archivo /etc/hostapd/hostapd.conf y agregando capacidades y funcionalidades extra."
      echo "    Es aconsejable reiniciar el sistema, al menos una vez, con:"
      echo ""
      echo "      shutdown -r now"
      echo ""
      echo "    ...antes de conectarse al punto de acceso."
      echo "    Si después de reiniciar, el punto de acceso no aparece, segúramente sea porque el firmware de la tarjeta WiFi no está instalado."
      echo ""

  fi
