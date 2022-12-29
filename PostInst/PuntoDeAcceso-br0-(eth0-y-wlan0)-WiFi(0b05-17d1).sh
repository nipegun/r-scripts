#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para crear un punto de acceso en modo puente en Debian con el adaptador WiFi Asus USB AC51 (Mediatek MT7610U)
#
#  Ejecución remota:
#  curl -s https://raw.githubusercontent.com/nipegun/r-scripts/master/PostInst/PuntoDeAcceso-br0-(eth0-y-wlan0)-WiFi(0b05-17d1).sh | bash
# ----------

# Capacidades HT y VHT del adaptador (Para saber las capacidades ejecutar iw list)
#   HT:
#     HT20/HT40
#     SM Power Save disabled
#     RX Greenfield
#     RX HT20 SGI
#     RX HT40 SGI
#     RX STBC 1-stream
#     Max AMSDU length: 3839 bytes
#     No DSSS/CCK HT40
#   VHT:
#     Max MPDU length: 3895
#     Supported Channel Width: neither 160 nor 80+80
#     short GI (80 MHz)
#     RX antenna pattern consistency
#     TX antenna pattern consistency

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
      7 "Configurar hostapd para AP abierto (WiFi n 2,4GHz canal 1)..." off
      8 "Configurar hostapd para AP cerrado (WiFi n 2,4GHz canal 1)..." off
      9 "Configurar hostapd para AP abierto (WiFi n 5GHz canal 36)..." off
     10 "Configurar hostapd para AP cerrado (WiFi n 5GHz canal 36)..." off
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
            echo "auto lo"                     > /etc/network/interfaces
            echo "  iface lo inet loopback"   >> /etc/network/interfaces
            echo ""                           >> /etc/network/interfaces
            echo "auto eth0"                  >> /etc/network/interfaces
            echo "  iface eth0 inet manual"   >> /etc/network/interfaces
            echo ""                           >> /etc/network/interfaces
            echo "allow-hotplug wlan0"        >> /etc/network/interfaces
            echo "  iface wlan0 inet manual"  >> /etc/network/interfaces
            echo ""                           >> /etc/network/interfaces
            echo "auto br0"                   >> /etc/network/interfaces
            echo "  iface br0 inet dhcp"      >> /etc/network/interfaces
            echo "  bridge_ports eth0 wlan0"  >> /etc/network/interfaces
            echo "  bridge_stp off"           >> /etc/network/interfaces
            echo "  bridge_fd 0"              >> /etc/network/interfaces
            echo "  bridge_maxwait 0"         >> /etc/network/interfaces
            echo "  hwaddress $vMacEth0"      >> /etc/network/interfaces
            echo ""                           >> /etc/network/interfaces
            echo "#auto br0"                  >> /etc/network/interfaces
            echo "  #iface br0 inet static"   >> /etc/network/interfaces
            echo "  #bridge_ports eth0 wlan0" >> /etc/network/interfaces
            echo "  #bridge_stp off"          >> /etc/network/interfaces
            echo "  #bridge_fd 0"             >> /etc/network/interfaces
            echo "  #bridge_maxwait 0"        >> /etc/network/interfaces
            echo "  #hwaddress $vMacEth0"     >> /etc/network/interfaces
            echo "  #address 192.168.1.2"     >> /etc/network/interfaces
            echo "  #netmask 255.255.255.0"   >> /etc/network/interfaces
            echo "  #gateway 192.168.1.1"     >> /etc/network/interfaces
            echo "  #network 192.168.1.0"     >> /etc/network/interfaces
            echo "  #broadcast 192.168.1.255" >> /etc/network/interfaces

          ;;

          5)

            echo ""
            echo "  Configurando interfaces de red con puente con IP fija..."
            echo ""
            vMacEth0=$(cat /sys/class/net/eth0/address)
            echo "auto lo"                     > /etc/network/interfaces
            echo "  iface lo inet loopback"   >> /etc/network/interfaces
            echo ""                           >> /etc/network/interfaces
            echo "auto eth0"                  >> /etc/network/interfaces
            echo "  iface eth0 inet manual"   >> /etc/network/interfaces
            echo ""                           >> /etc/network/interfaces
            echo "allow-hotplug wlan0"        >> /etc/network/interfaces
            echo "  iface wlan0 inet manual"  >> /etc/network/interfaces
            echo ""                           >> /etc/network/interfaces
            echo "#auto br0"                  >> /etc/network/interfaces
            echo "#  iface br0 inet dhcp"     >> /etc/network/interfaces
            echo "#  bridge_ports eth0 wlan0" >> /etc/network/interfaces
            echo "#  bridge_stp off"          >> /etc/network/interfaces
            echo "#  bridge_fd 0"             >> /etc/network/interfaces
            echo "#  bridge_maxwait 0"        >> /etc/network/interfaces
            echo "#  hwaddress $vMacEth0"     >> /etc/network/interfaces
            echo ""                           >> /etc/network/interfaces
            echo "auto br0"                   >> /etc/network/interfaces
            echo "  iface br0 inet static"    >> /etc/network/interfaces
            echo "  bridge_ports eth0 wlan0"  >> /etc/network/interfaces
            echo "  bridge_stp off"           >> /etc/network/interfaces
            echo "  bridge_fd 0"              >> /etc/network/interfaces
            echo "  bridge_maxwait 0"         >> /etc/network/interfaces
            echo "  hwaddress $vMacEth0"      >> /etc/network/interfaces
            echo "  address 192.168.1.2"      >> /etc/network/interfaces
            echo "  netmask 255.255.255.0"    >> /etc/network/interfaces
            echo "  gateway 192.168.1.1"      >> /etc/network/interfaces
            echo "  #network 192.168.1.0"     >> /etc/network/interfaces
            echo "  #broadcast 192.168.1.255" >> /etc/network/interfaces

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
            echo "#/etc/hostapd/hostapd.conf"                                                                       > /etc/hostapd/hostapd.conf
            echo ""                                                                                                >> /etc/hostapd/hostapd.conf
            echo "# Punto de acceso abierto"                                                                       >> /etc/hostapd/hostapd.conf
            echo "bridge=br0"                                                                                      >> /etc/hostapd/hostapd.conf
            echo "interface=wlan0"                                                                                 >> /etc/hostapd/hostapd.conf
            echo "ssid=HostAPD"                                                                                    >> /etc/hostapd/hostapd.conf
            echo ""                                                                                                >> /etc/hostapd/hostapd.conf
            echo "# Opciones para el adaptador con firmware Mediatek MT7610U"                                      >> /etc/hostapd/hostapd.conf
            echo "driver=nl80211"                                                                                  >> /etc/hostapd/hostapd.conf
            echo "channel=1                        # El canal a usar. 0 buscará el canal con menos interferencias" >> /etc/hostapd/hostapd.conf
            echo "hw_mode=g"                                                                                       >> /etc/hostapd/hostapd.conf
            echo "ieee80211n=1"                                                                                    >> /etc/hostapd/hostapd.conf
            echo "wme_enabled=1"                                                                                   >> /etc/hostapd/hostapd.conf
            echo "wmm_enabled=1                    # Soporte para QoS"                                             >> /etc/hostapd/hostapd.conf
            echo "ieee80211d=1                     # Limitar las frecuencias sólo a las disponibles en el país"    >> /etc/hostapd/hostapd.conf
            echo "country_code=ES"                                                                                 >> /etc/hostapd/hostapd.conf
            echo "ht_capab=[HT40][SHORT-GI-40][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]"                             >> /etc/hostapd/hostapd.conf
            echo "#[HT20][SHORT-GI-20] dejados fuera para forzar que la red n se cree en el canal de 40Mhz"        >> /etc/hostapd/hostapd.conf
            echo "vht_capab=[MAX-MPDU-3895][VHT160-80PLUS80][SHORT-GI-80][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]" >> /etc/hostapd/hostapd.conf

          ;;

          8)

            echo ""
            echo "  Configurando hostapd para AP cerrado (WiFi n 2,4GHz canal 1)..."
            echo ""
            echo "#/etc/hostapd/hostapd.conf"                                                                       > /etc/hostapd/hostapd.conf
            echo ""                                                                                                >> /etc/hostapd/hostapd.conf
            echo "# Punto de acceso cerrado"                                                                       >> /etc/hostapd/hostapd.conf
            echo "bridge=br0"                                                                                      >> /etc/hostapd/hostapd.conf
            echo "interface=wlan0"                                                                                 >> /etc/hostapd/hostapd.conf
            echo "ssid=HostAPD"                                                                                    >> /etc/hostapd/hostapd.conf
            echo "wpa=2"                                                                                           >> /etc/hostapd/hostapd.conf
            echo "wpa_key_mgmt=WPA-PSK"                                                                            >> /etc/hostapd/hostapd.conf
            echo "wpa_pairwise=TKIP"                                                                               >> /etc/hostapd/hostapd.conf
            echo "rsn_pairwise=CCMP"                                                                               >> /etc/hostapd/hostapd.conf
            echo "ignore_broadcast_ssid=0"                                                                         >> /etc/hostapd/hostapd.conf
            echo "eap_reauth_period=360000000"                                                                     >> /etc/hostapd/hostapd.conf
            echo "wpa_passphrase=HostAPD"                                                                          >> /etc/hostapd/hostapd.conf
            echo ""                                                                                                >> /etc/hostapd/hostapd.conf
            echo "# Opciones para el adaptador con firmware Mediatek MT7610U"                                      >> /etc/hostapd/hostapd.conf
            echo "driver=nl80211"                                                                                  >> /etc/hostapd/hostapd.conf
            echo "channel=1                        # El canal a usar. 0 buscará el canal con menos interferencias" >> /etc/hostapd/hostapd.conf
            echo "hw_mode=g"                                                                                       >> /etc/hostapd/hostapd.conf
            echo "ieee80211n=1"                                                                                    >> /etc/hostapd/hostapd.conf
            echo "wme_enabled=1"                                                                                   >> /etc/hostapd/hostapd.conf
            echo "wmm_enabled=1                    # Soporte para QoS"                                             >> /etc/hostapd/hostapd.conf
            echo "ieee80211d=1                     # Limitar las frecuencias sólo a las disponibles en el país"    >> /etc/hostapd/hostapd.conf
            echo "country_code=ES"                                                                                 >> /etc/hostapd/hostapd.conf
            echo "ht_capab=[HT49][SHORT-GI-40][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]"                             >> /etc/hostapd/hostapd.conf
            echo "#[HT20][SHORT-GI-20] dejados fuera para forzar que la red n se cree en el canal de 40Mhz"        >> /etc/hostapd/hostapd.conf
            echo "vht_capab=[MAX-MPDU-3895][VHT160-80PLUS80][SHORT-GI-80][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]" >> /etc/hostapd/hostapd.conf

          ;;

          9)
          
            echo ""
            echo "  Configurando hostapd para AP abierto (WiFi n 5GHz canal 36)..."
            echo ""
            echo "#/etc/hostapd/hostapd.conf"                                                                       > /etc/hostapd/hostapd.conf
            echo ""                                                                                                >> /etc/hostapd/hostapd.conf
            echo "# Punto de acceso abierto"                                                                       >> /etc/hostapd/hostapd.conf
            echo "bridge=br0"                                                                                      >> /etc/hostapd/hostapd.conf
            echo "interface=wlan0"                                                                                 >> /etc/hostapd/hostapd.conf
            echo "ssid=HostAPD"                                                                                    >> /etc/hostapd/hostapd.conf
            echo ""                                                                                                >> /etc/hostapd/hostapd.conf
            echo "# Opciones para el adaptador con firmware Mediatek MT7610U"                                      >> /etc/hostapd/hostapd.conf
            echo "driver=nl80211"                                                                                  >> /etc/hostapd/hostapd.conf
            echo "channel=36                       # El canal a usar. 0 buscará el canal con menos interferencias" >> /etc/hostapd/hostapd.conf
            echo "hw_mode=a"                                                                                       >> /etc/hostapd/hostapd.conf
            echo "ieee80211n=1"                                                                                    >> /etc/hostapd/hostapd.conf
            echo "wme_enabled=1"                                                                                   >> /etc/hostapd/hostapd.conf
            echo "wmm_enabled=1                    # Soporte para QoS"                                             >> /etc/hostapd/hostapd.conf
            echo "ieee80211d=1                     # Limitar las frecuencias sólo a las disponibles en el país"    >> /etc/hostapd/hostapd.conf
            echo "country_code=ES"                                                                                 >> /etc/hostapd/hostapd.conf
            echo "ht_capab=[HT40][SHORT-GI-40][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]"                             >> /etc/hostapd/hostapd.conf
            echo "#[HT20][SHORT-GI-20] dejados fuera para forzar que la red n se cree en el canal de 40Mhz"        >> /etc/hostapd/hostapd.conf
            echo "vht_capab=[MAX-MPDU-3895][VHT160-80PLUS80][SHORT-GI-80][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]" >> /etc/hostapd/hostapd.conf

          ;;

         10)

            echo ""
            echo "  Configurando hostapd para AP cerrado (WiFi n 5GHz canal 36)..."
            echo ""
            echo "#/etc/hostapd/hostapd.conf"                                                                       > /etc/hostapd/hostapd.conf
            echo ""                                                                                                >> /etc/hostapd/hostapd.conf
            echo "# Punto de acceso cerrado"                                                                       >> /etc/hostapd/hostapd.conf
            echo "bridge=br0"                                                                                      >> /etc/hostapd/hostapd.conf
            echo "interface=wlan0"                                                                                 >> /etc/hostapd/hostapd.conf
            echo "ssid=HostAPD"                                                                                    >> /etc/hostapd/hostapd.conf
            echo "wpa=2"                                                                                           >> /etc/hostapd/hostapd.conf
            echo "wpa_key_mgmt=WPA-PSK"                                                                            >> /etc/hostapd/hostapd.conf
            echo "wpa_pairwise=TKIP"                                                                               >> /etc/hostapd/hostapd.conf
            echo "rsn_pairwise=CCMP"                                                                               >> /etc/hostapd/hostapd.conf
            echo "ignore_broadcast_ssid=0"                                                                         >> /etc/hostapd/hostapd.conf
            echo "eap_reauth_period=360000000"                                                                     >> /etc/hostapd/hostapd.conf
            echo "wpa_passphrase=HostAPD"                                                                          >> /etc/hostapd/hostapd.conf
            echo ""                                                                                                >> /etc/hostapd/hostapd.conf
            echo "# Opciones para el adaptador con firmware Mediatek MT7610U"                                      >> /etc/hostapd/hostapd.conf
            echo "driver=nl80211"                                                                                  >> /etc/hostapd/hostapd.conf
            echo "channel=36                       # El canal a usar. 0 buscará el canal con menos interferencias" >> /etc/hostapd/hostapd.conf
            echo "hw_mode=a"                                                                                       >> /etc/hostapd/hostapd.conf
            echo "ieee80211n=1"                                                                                    >> /etc/hostapd/hostapd.conf
            echo "wme_enabled=1"                                                                                   >> /etc/hostapd/hostapd.conf
            echo "wmm_enabled=1                    # Soporte para QoS"                                             >> /etc/hostapd/hostapd.conf
            echo "ieee80211d=1                     # Limitar las frecuencias sólo a las disponibles en el país"    >> /etc/hostapd/hostapd.conf
            echo "country_code=ES"                                                                                 >> /etc/hostapd/hostapd.conf
            echo "ht_capab=[HT40][SHORT-GI-40][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]"                             >> /etc/hostapd/hostapd.conf
            echo "#[HT20][SHORT-GI-20] dejados fuera para forzar que la red n se cree en el canal de 40Mhz"        >> /etc/hostapd/hostapd.conf
            echo "vht_capab=[MAX-MPDU-3895][VHT160-80PLUS80][SHORT-GI-80][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]" >> /etc/hostapd/hostapd.conf

          ;;

      esac

  done

fi

