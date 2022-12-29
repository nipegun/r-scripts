#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para crear un punto de acceso en modo puente en Debian con los siguientes adaptadores WiFi:
#  - USB TP-Link TL-WN722N (Atheros AR9271)
#  - USB Alfa Networks AWUS036NHA
#
#  Ejecución remota:
#  curl -s https://raw.githubusercontent.com/nipegun/r-scripts/master/PostInst/PuntoDeAcceso-br0-(eth0-y-wlan0)-WiFi(0cf3-9271).sh | bash
# ----------

# Capacidades HT y VHT del adaptador (Para saber las capacidades ejecutar iw list)
#   HT:
#     HT20/HT40
#     SM Power Save disabled
#     RX HT20 SGI
#     RX HT40 SGI
#     RX STBC 1-stream
#     Max AMSDU length: 3839 bytes
#     No DSSS/CCK HT40

vColorAzul="\033[0;34m"
vColorAzulClaro="\033[1;34m"
vColorVerde='\033[1;32m'
vColorRojo='\033[1;31m'
vFinColor='\033[0m'

# Comprobar si el script está corriendo como root
  if [ $(id -u) -ne 0 ]; then
    echo -e "${vColorRojo}Este script está preparado para ejecutarse como root y no lo has ejecutado como root...${vFinColor}" >&2
    exit 1
  fi

# Determinar la versión de Debian
  if [ -f /etc/os-release ]; then             # Para systemd y freedesktop.org.
    . /etc/os-release
    OS_NAME=$NAME
    OS_VERS=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then # Para linuxbase.org.
    OS_NAME=$(lsb_release -si)
    OS_VERS=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then          # Para algunas versiones de Debian sin el comando lsb_release.
    . /etc/lsb-release
    OS_NAME=$DISTRIB_ID
    OS_VERS=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then       # Para versiones viejas de Debian.
    OS_NAME=Debian
    OS_VERS=$(cat /etc/debian_version)
  else                                        # Para el viejo uname (También funciona para BSD).
    OS_NAME=$(uname -s)
    OS_VERS=$(uname -r)
  fi

if [ $OS_VERS == "7" ]; then

  echo ""
  echo -e "${vColorAzulClaro}Iniciando el script de instalación de xxxxxxxxx para Debian 7 (Wheezy)...${vFinColor}"
  echo ""

  echo ""
  echo -e "${vColorRojo}  Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${vFinColor}"
  echo ""

elif [ $OS_VERS == "8" ]; then

  echo ""
  echo -e "${vColorAzulClaro}Iniciando el script de instalación de xxxxxxxxx para Debian 8 (Jessie)...${vFinColor}"
  echo ""

  echo ""
  echo -e "${vColorRojo}  Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${vFinColor}"
  echo ""

elif [ $OS_VERS == "9" ]; then

  echo ""
  echo -e "${vColorAzulClaro}Iniciando el script de instalación de xxxxxxxxx para Debian 9 (Stretch)...${vFinColor}"
  echo ""

  echo ""
  echo -e "${vColorRojo}  Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${vFinColor}"
  echo ""

elif [ $OS_VERS == "10" ]; then

  echo ""
  echo -e "${vColorAzulClaro}Iniciando el script de instalación de xxxxxxxxx para Debian 10 (Buster)...${vFinColor}"
  echo ""

  echo ""
  echo -e "${vColorRojo}  Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${vFinColor}"
  echo ""

elif [ $OS_VERS == "11" ]; then

  echo ""
  echo -e "${vColorAzulClaro}Iniciando el script de instalación de xxxxxxxxx para Debian 11 (Bullseye)...${vFinColor}"
  echo ""

  echo ""
  echo -e "${vColorAzulClaro}Iniciando el script de instalación de xxxxxxxxx para Debian 11 (Bullseye)...${vFinColor}"
  echo ""

  vFecha=$(date +A%YM%mD%d@%T)

  # Comprobar si el paquete dialog está instalado. Si no lo está, instalarlo.
    if [[ $(dpkg-query -s dialog 2>/dev/null | grep installed) == "" ]]; then
      echo ""
      echo -e "${vColorRojo}El paquete dialog no está instalado. Iniciando su instalación...${vFinColor}"
      echo ""
      apt-get -y update && apt-get -y install dialog
      echo ""
    fi

  menu=(dialog --checklist "Marca las opciones que quieras instalar:" 22 96 16)
    opciones=(
      1 "Instalar paquetes necesarios." on
      2 "Instalar controlador para el firmware WiFi." on
      3 "Activar el forwarding entre interfaces de red." on
      4 "Configurar interfaces de red con puente con IP por DHCP." on
      5 "Configurar interfaces de red con puente con IP fija." off
      6 "Configurar opciones por defecto para hostapd." on
      7 "Configurar hostapd para AP abierto (WiFi n 2,4GHz canal 1)." off
      8 "Configurar hostapd para AP cerrado (WiFi n 2,4GHz canal 1)." off
      9 "Configurar hostapd para AP abierto (WiFi n 5GHz canal 36)." off
     10 "Configurar hostapd para AP cerrado (WiFi n 5GHz canal 36)." off
     11 "Bloquear DHCP en eth0 y wlan0." on
     12 "Desenmascar, activar e iniciar hostapd." on
     13 "Crear reglas de NFTables." on
    )
  choices=$("${menu[@]}" "${opciones[@]}" 2>&1 >/dev/tty)

    for choice in $choices
      do
        case $choice in

          1)

            echo ""
            echo "  Instalando paquetes necesarios..."
            echo ""
            apt-get -y update
            apt-get -y install hostapd
            apt-get -y install crda
            apt-get -y install bridge-utils

          ;;

          2)

            echo ""
            echo "  Instalando controlador para el firmware WiFi..."
            echo ""
            apt-get -y install firmware-ath9k-htc

          ;;

          3)

            echo ""
            echo "  Activando forwarding entre interfaces de red..."
            echo ""
            cp /etc/sysctl.conf /etc/sysctl.conf.bak
            sed -i -e 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|g' /etc/sysctl.conf

          ;;


          4)

            echo ""
            echo "  Configurando interfaces de red con puente con IP por DHCP..."
            echo ""
            vMacEth0=$(cat /sys/class/net/eth0/address)
            echo "auto lo"                                                                                             > /etc/network/interfaces
            echo "  iface lo inet loopback"                                                                           >> /etc/network/interfaces
            echo ""                                                                                                   >> /etc/network/interfaces
            echo "auto eth0"                                                                                          >> /etc/network/interfaces
            echo "  iface eth0 inet manual"                                                                           >> /etc/network/interfaces
            echo ""                                                                                                   >> /etc/network/interfaces
            echo "allow-hotplug wlan0"                                                                                >> /etc/network/interfaces
            echo "  iface wlan0 inet manual"                                                                          >> /etc/network/interfaces
            echo ""                                                                                                   >> /etc/network/interfaces
            echo "auto br0"                                                                                           >> /etc/network/interfaces
            echo "  iface br0 inet dhcp"                                                                              >> /etc/network/interfaces
            echo "  bridge_ports eth0"                                                                                >> /etc/network/interfaces
            echo "    # No hace falta agregar wlan0 a los puertos del puente."                                        >> /etc/network/interfaces
            echo "    # Si existe la línea bridge=br0 en hostapd.conf,"                                               >> /etc/network/interfaces
            echo "    # hostapd lo agrega cuando se levanta el servicio."                                             >> /etc/network/interfaces
            echo "    # Esto es útil también para que el puente se levante aunque no encuentre un dispositivo wlan0." >> /etc/network/interfaces
            echo "  bridge_stp off"                                                                                   >> /etc/network/interfaces
            echo "  bridge_fd 0"                                                                                      >> /etc/network/interfaces
            echo "  bridge_maxwait 0"                                                                                 >> /etc/network/interfaces
            echo "  hwaddress $vMacEth0"                                                                              >> /etc/network/interfaces

          ;;

          5)

            echo ""
            echo "  Configurando interfaces de red con puente con IP fija..."
            echo ""
            vMacEth0=$(cat /sys/class/net/eth0/address)
            echo "auto lo"                                                                                             > /etc/network/interfaces
            echo "  iface lo inet loopback"                                                                           >> /etc/network/interfaces
            echo ""                                                                                                   >> /etc/network/interfaces
            echo "auto eth0"                                                                                          >> /etc/network/interfaces
            echo "  iface eth0 inet manual"                                                                           >> /etc/network/interfaces
            echo ""                                                                                                   >> /etc/network/interfaces
            echo "allow-hotplug wlan0"                                                                                >> /etc/network/interfaces
            echo "  iface wlan0 inet manual"                                                                          >> /etc/network/interfaces
            echo ""                                                                                                   >> /etc/network/interfaces
            echo "auto br0"                                                                                           >> /etc/network/interfaces
            echo "  iface br0 inet static"                                                                            >> /etc/network/interfaces
            echo "  bridge_ports eth0"                                                                                >> /etc/network/interfaces
            echo "    # No hace falta agregar wlan0 a los puertos del puente."                                        >> /etc/network/interfaces
            echo "    # Si existe la línea bridge=br0 en hostapd.conf,"                                               >> /etc/network/interfaces
            echo "    # hostapd lo agrega cuando se levanta el servicio."                                             >> /etc/network/interfaces
            echo "    # Esto es útil también para que el puente se levante aunque no encuentre un dispositivo wlan0." >> /etc/network/interfaces
            echo "  bridge_stp off"                                                                                   >> /etc/network/interfaces
            echo "  bridge_fd 0"                                                                                      >> /etc/network/interfaces
            echo "  bridge_maxwait 0"                                                                                 >> /etc/network/interfaces
            echo "  hwaddress $vMacEth0"                                                                              >> /etc/network/interfaces
            echo "  address 192.168.1.2"                                                                              >> /etc/network/interfaces
            echo "  netmask 255.255.255.0"                                                                            >> /etc/network/interfaces
            echo "  gateway 192.168.1.1"                                                                              >> /etc/network/interfaces
            echo "  #network 192.168.1.0"                                                                             >> /etc/network/interfaces
            echo "  #broadcast 192.168.1.255"                                                                         >> /etc/network/interfaces

          ;;

          6)

            echo ""
            echo "  Configurando opciones por defecto para hostapd..."
            echo ""
            cp /etc/default/hostapd /etc/default/hostapd-$vFecha.bak
            sed -i -e 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g' /etc/default/hostapd
            sed -i -e 's|#DAEMON_OPTS=""|DAEMON_OPTS="-dd -t -f /var/log/hostapd.log"|g' /etc/default/hostapd

          ;;

          7)
          
            echo ""
            echo "  Configurando hostapd para AP abierto (WiFi n 2,4GHz canal 1)..."
            echo ""
            echo "#/etc/hostapd/hostapd.conf"                                                                > /etc/hostapd/hostapd.conf
            echo ""                                                                                         >> /etc/hostapd/hostapd.conf
            echo "# Punto de acceso abierto"                                                                >> /etc/hostapd/hostapd.conf
            echo "bridge=br0"                                                                               >> /etc/hostapd/hostapd.conf
            echo "interface=wlan0"                                                                          >> /etc/hostapd/hostapd.conf
            echo "ssid=HostAPD"                                                                             >> /etc/hostapd/hostapd.conf
            echo ""                                                                                         >> /etc/hostapd/hostapd.conf
            echo "# Opciones para el adaptador con firmware Atheros AR9271"                                 >> /etc/hostapd/hostapd.conf
            echo "driver=nl80211"                                                                           >> /etc/hostapd/hostapd.conf
            echo "channel=1              # El canal a usar. 0 buscará el canal con menos interferencias"    >> /etc/hostapd/hostapd.conf
            echo "hw_mode=g"                                                                                >> /etc/hostapd/hostapd.conf
            echo "ieee80211n=1"                                                                             >> /etc/hostapd/hostapd.conf
            echo "wme_enabled=1"                                                                            >> /etc/hostapd/hostapd.conf
            echo "wmm_enabled=1          # Soporte para QoS"                                                >> /etc/hostapd/hostapd.conf
            echo "ieee80211d=1           # Limitar las frecuencias sólo a las disponibles en el país"       >> /etc/hostapd/hostapd.conf
            echo "country_code=ES"                                                                          >> /etc/hostapd/hostapd.conf
            echo "ht_capab=[HT20][SHORT-GI-20][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]"                      >> /etc/hostapd/hostapd.conf
            echo "#[HT40][SHORT-GI-40] dejados fuera para forzar que la red n se cree en el canal de 20Mhz" >> /etc/hostapd/hostapd.conf

          ;;

          8)

            echo ""
            echo "  Configurando hostapd para AP cerrado (WiFi n 2,4GHz canal 1)..."
            echo ""
            echo "#/etc/hostapd/hostapd.conf"                                                                > /etc/hostapd/hostapd.conf
            echo ""                                                                                         >> /etc/hostapd/hostapd.conf
            echo "# Punto de acceso cerrado"                                                                >> /etc/hostapd/hostapd.conf
            echo "bridge=br0"                                                                               >> /etc/hostapd/hostapd.conf
            echo "interface=wlan0"                                                                          >> /etc/hostapd/hostapd.conf
            echo "ssid=HostAPD"                                                                             >> /etc/hostapd/hostapd.conf
            echo "wpa=2"                                                                                    >> /etc/hostapd/hostapd.conf
            echo "wpa_key_mgmt=WPA-PSK"                                                                     >> /etc/hostapd/hostapd.conf
            echo "wpa_pairwise=TKIP"                                                                        >> /etc/hostapd/hostapd.conf
            echo "rsn_pairwise=CCMP"                                                                        >> /etc/hostapd/hostapd.conf
            echo "ignore_broadcast_ssid=0"                                                                  >> /etc/hostapd/hostapd.conf
            echo "eap_reauth_period=360000000"                                                              >> /etc/hostapd/hostapd.conf
            echo "wpa_passphrase=HostAPD"                                                                   >> /etc/hostapd/hostapd.conf
            echo ""                                                                                         >> /etc/hostapd/hostapd.conf
            echo "# Opciones para el adaptador con firmware Atheros AR9271"                                 >> /etc/hostapd/hostapd.conf
            echo "driver=nl80211"                                                                           >> /etc/hostapd/hostapd.conf
            echo "channel=1                 # El canal a usar. 0 buscará el canal con menos interferencias" >> /etc/hostapd/hostapd.conf
            echo "hw_mode=g"                                                                                >> /etc/hostapd/hostapd.conf
            echo "ieee80211n=1"                                                                             >> /etc/hostapd/hostapd.conf
            echo "wme_enabled=1"                                                                            >> /etc/hostapd/hostapd.conf
            echo "wmm_enabled=1             # Soporte para QoS"                                             >> /etc/hostapd/hostapd.conf
            echo "ieee80211d=1              # Limitar las frecuencias sólo a las disponibles en el país"    >> /etc/hostapd/hostapd.conf
            echo "country_code=ES"                                                                          >> /etc/hostapd/hostapd.conf
            echo "ht_capab=[HT20][SHORT-GI-20][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]"                      >> /etc/hostapd/hostapd.conf
            echo "#[HT40][SHORT-GI-40] dejados fuera para forzar que la red n se cree en el canal de 20Mhz" >> /etc/hostapd/hostapd.conf

          ;;

          9)
          
            echo ""
            echo "  Configurando hostapd para AP abierto (WiFi n 5GHz canal 36)..."
            echo ""
            echo "#/etc/hostapd/hostapd.conf"                                                                > /etc/hostapd/hostapd.conf
            echo ""                                                                                         >> /etc/hostapd/hostapd.conf
            echo "# Punto de acceso abierto"                                                                >> /etc/hostapd/hostapd.conf
            echo "bridge=br0"                                                                               >> /etc/hostapd/hostapd.conf
            echo "interface=wlan0"                                                                          >> /etc/hostapd/hostapd.conf
            echo "ssid=HostAPD"                                                                             >> /etc/hostapd/hostapd.conf
            echo ""                                                                                         >> /etc/hostapd/hostapd.conf
            echo "# Opciones para el adaptador con firmware Atheros AR9271"                                 >> /etc/hostapd/hostapd.conf
            echo "driver=nl80211"                                                                           >> /etc/hostapd/hostapd.conf
            echo "channel=36              # El canal a usar. 0 buscará el canal con menos interferencias"   >> /etc/hostapd/hostapd.conf
            echo "hw_mode=a"                                                                                >> /etc/hostapd/hostapd.conf
            echo "ieee80211n=1"                                                                             >> /etc/hostapd/hostapd.conf
            echo "wme_enabled=1"                                                                            >> /etc/hostapd/hostapd.conf
            echo "wmm_enabled=1          # Soporte para QoS"                                                >> /etc/hostapd/hostapd.conf
            echo "ieee80211d=1           # Limitar las frecuencias sólo a las disponibles en el país"       >> /etc/hostapd/hostapd.conf
            echo "country_code=ES"                                                                          >> /etc/hostapd/hostapd.conf
            echo "ht_capab=[HT40][SHORT-GI-40][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]"                      >> /etc/hostapd/hostapd.conf
            echo "#[HT20][SHORT-GI-20] dejados fuera para forzar que la red n se cree en el canal de 40Mhz" >> /etc/hostapd/hostapd.conf

          ;;

         10)

            echo ""
            echo "  Configurando hostapd para AP cerrado (WiFi n 5GHz canal 36)..."
            echo ""
            echo "#/etc/hostapd/hostapd.conf"                                                                > /etc/hostapd/hostapd.conf
            echo ""                                                                                         >> /etc/hostapd/hostapd.conf
            echo "# Punto de acceso cerrado"                                                                >> /etc/hostapd/hostapd.conf
            echo "bridge=br0"                                                                               >> /etc/hostapd/hostapd.conf
            echo "interface=wlan0"                                                                          >> /etc/hostapd/hostapd.conf
            echo "ssid=HostAPD"                                                                             >> /etc/hostapd/hostapd.conf
            echo "wpa=2"                                                                                    >> /etc/hostapd/hostapd.conf
            echo "wpa_key_mgmt=WPA-PSK"                                                                     >> /etc/hostapd/hostapd.conf
            echo "wpa_pairwise=TKIP"                                                                        >> /etc/hostapd/hostapd.conf
            echo "rsn_pairwise=CCMP"                                                                        >> /etc/hostapd/hostapd.conf
            echo "ignore_broadcast_ssid=0"                                                                  >> /etc/hostapd/hostapd.conf
            echo "eap_reauth_period=360000000"                                                              >> /etc/hostapd/hostapd.conf
            echo "wpa_passphrase=HostAPD"                                                                   >> /etc/hostapd/hostapd.conf
            echo ""                                                                                         >> /etc/hostapd/hostapd.conf
            echo "# Opciones para el adaptador con firmware Atheros AR9271"                                 >> /etc/hostapd/hostapd.conf
            echo "driver=nl80211"                                                                           >> /etc/hostapd/hostapd.conf
            echo "channel=36                # El canal a usar. 0 buscará el canal con menos interferencias" >> /etc/hostapd/hostapd.conf
            echo "hw_mode=a"                                                                                >> /etc/hostapd/hostapd.conf
            echo "ieee80211n=1"                                                                             >> /etc/hostapd/hostapd.conf
            echo "wme_enabled=1"                                                                            >> /etc/hostapd/hostapd.conf
            echo "wmm_enabled=1             # Soporte para QoS"                                             >> /etc/hostapd/hostapd.conf
            echo "ieee80211d=1              # Limitar las frecuencias sólo a las disponibles en el país"    >> /etc/hostapd/hostapd.conf
            echo "country_code=ES"                                                                          >> /etc/hostapd/hostapd.conf
            echo "ht_capab=[HT40][SHORT-GI-40][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]"                      >> /etc/hostapd/hostapd.conf
            echo "#[HT20][SHORT-GI-20] dejados fuera para forzar que la red n se cree en el canal de 40Mhz" >> /etc/hostapd/hostapd.conf

          ;;

         11)

            echo ""
            echo "    Bloqueando DHCP en eth0 y wlan0 (dejando sólo el puente br0)..."
            echo ""
            touch /etc/dhcpcd.conf
            echo "denyinterfaces wlan0" >> /etc/dhcpcd.conf
            echo "denyinterfaces eth0"  >> /etc/dhcpcd.conf

          ;;

         12)

            echo ""
            echo "    Desenmascarando, activando e iniciando el servicio hostapd..."
            echo ""
            systemctl unmask hostapd
            systemctl enable hostapd --now
  
          ;;

         13)

            echo ""
            echo "    Creando reglas con NFTables..."
            echo ""
            mkdir -p /root/scripts/ 2> /dev/null
            echo "# Crear la tabla nat"                                                           > /root/scripts/ReglasNFTablesAP.sh
            echo "  nft add table nat"                                                           >> /root/scripts/ReglasNFTablesAP.sh
            echo "# Crear las cadenas de la tabla nat"                                           >> /root/scripts/ReglasNFTablesAP.sh
            echo "  nft add chain nat prerouting { type nat hook prerouting priority 0 \; }"     >> /root/scripts/ReglasNFTablesAP.sh
            echo "  nft add chain nat postrouting { type nat hook postrouting priority 100 \; }" >> /root/scripts/ReglasNFTablesAP.sh
            echo "# Crear regla"                                                                 >> /root/scripts/ReglasNFTablesAP.sh
            echo "  nft add rule ip nat postrouting oifname "br0" counter masquerade"            >> /root/scripts/ReglasNFTablesAP.sh
            echo ""
            chmod +x /root/scripts/ReglasNFTablesAP.sh
            echo "/root/scripts/ReglasNFTablesAP.sh"                                             >> /root/scripts/ComandosPostArranque.sh
            # Con IPTables sería tal que así:
            #   iptables -t nat -A POSTROUTING -o br0 -j MASQUERADE
            #   o
            #   iptables --table nat --append POSTROUTING --out-interface br0 -j MASQUERADE

          ;;

      esac

  done

fi

