#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para crear un punto de acceso en modo puente en Debian con el adaptador WiFi Asus USB AC51 (Mediatek MT7610U)
#
#  Ejecución remota:
#  curl -s x | bash
# ----------

# Capacidades HT y VHT del adaptador
  # HT:
    # HT20/HT40
    # SM Power Save disabled
    # RX Greenfield
    # RX HT20 SGI                                    :[SHORT-GI-20]
    # RX HT40 SGI                                    :[SHORT-GI-40]
    # RX STBC 1-stream                               :[RX-STBC1]
    # Max AMSDU length: 3839 bytes                   :[MAX-AMSDU-3839]
    # No DSSS/CCK HT40                               :[DSSS_CCK-40]
  # VHT:
    # Max MPDU length: 3895                          :[MAX-MPDU-3895]
    # Supported Channel Width: neither 160 nor 80+80 :[VHT160-80PLUS80]
    # short GI (80 MHz)                              :[SHORT-GI-80]
    # RX antenna pattern consistency                 :[RX-ANTENNA-PATTERN]
    # TX antenna pattern consistency                 :[TX-ANTENNA-PATTERN]

echo ""
echo "    Configurando el demonio hostapd..."
echo ""
echo "#/etc/hostapd/hostapd.conf"                                                                                   > /etc/hostapd/hostapd.conf
echo ""                                                                                                            >> /etc/hostapd/hostapd.conf
echo "# Punto de acceso abierto"                                                                                   >> /etc/hostapd/hostapd.conf
echo "  bridge=br0"                                                                                                >> /etc/hostapd/hostapd.conf
echo "  interface=wlan0"                                                                                           >> /etc/hostapd/hostapd.conf
echo "  ssid=HostAPD"                                                                                              >> /etc/hostapd/hostapd.conf
echo ""                                                                                                            >> /etc/hostapd/hostapd.conf
echo "# Firmware Mediatek MT7610U"                                                                                 >> /etc/hostapd/hostapd.conf
echo "  driver=nl80211"                                                                                            >> /etc/hostapd/hostapd.conf
echo "  channel=0                               # El canal a usar. 0 buscará el canal con menos interferencias"    >> /etc/hostapd/hostapd.conf
echo "  hw_mode=a"                                                                                                 >> /etc/hostapd/hostapd.conf
echo "  ieee80211n=1"                                                                                              >> /etc/hostapd/hostapd.conf
echo "  wme_enabled=1"                                                                                             >> /etc/hostapd/hostapd.conf
echo "  wmm_enabled=1                           # Soporte para QoS"                                                >> /etc/hostapd/hostapd.conf
echo "  ieee80211d=1                            # Limitar las frecuencias sólo a las disponibles en el país"       >> /etc/hostapd/hostapd.conf
echo "  country_code=ES"                                                                                           >> /etc/hostapd/hostapd.conf
echo "  ht_capab=[SHORT-GI-20][SHORT-GI-40][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]"                                >> /etc/hostapd/hostapd.conf
echo "  vht_capab=[MAX-MPDU-3895][VHT160-80PLUS80][SHORT-GI-80][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]"           >> /etc/hostapd/hostapd.conf

echo ""
echo "    Configurando el demonio hostapd..."
echo ""
echo "#/etc/hostapd/hostapd.conf"                                                                                   > /etc/hostapd/hostapd.conf
echo ""                                                                                                            >> /etc/hostapd/hostapd.conf
echo "# Punto de acceso cerrado"                                                                                   >> /etc/hostapd/hostapd.conf
echo "  bridge=br0"                                                                                                >> /etc/hostapd/hostapd.conf
echo "  interface=wlan0"                                                                                           >> /etc/hostapd/hostapd.conf
echo "  ssid=HostAPD"                                                                                              >> /etc/hostapd/hostapd.conf
echo "    wpa=2"                                                                                                   >> /etc/hostapd/hostapd.conf
echo "    wpa_key_mgmt=WPA-PSK"                                                                                    >> /etc/hostapd/hostapd.conf
echo "    wpa_pairwise=TKIP"                                                                                       >> /etc/hostapd/hostapd.conf
echo "    rsn_pairwise=CCMP"                                                                                       >> /etc/hostapd/hostapd.conf
echo "    ignore_broadcast_ssid=0"                                                                                 >> /etc/hostapd/hostapd.conf
echo "    eap_reauth_period=360000000"                                                                             >> /etc/hostapd/hostapd.conf
echo "    wpa_passphrase=HostAPD"                                                                                  >> /etc/hostapd/hostapd.conf
echo ""                                                                                                            >> /etc/hostapd/hostapd.conf
echo ""                                                                                                            >> /etc/hostapd/hostapd.conf
echo "# Opciones para el adaptador con firmware Mediatek MT7610U"                                                  >> /etc/hostapd/hostapd.conf
echo "  driver=nl80211"                                                                                            >> /etc/hostapd/hostapd.conf
echo "  channel=0                               # El canal a usar. 0 buscará el canal con menos interferencias"    >> /etc/hostapd/hostapd.conf
echo "  hw_mode=a"                                                                                                 >> /etc/hostapd/hostapd.conf
echo "  ieee80211n=1"                                                                                              >> /etc/hostapd/hostapd.conf
echo "  wme_enabled=1"                                                                                             >> /etc/hostapd/hostapd.conf
echo "  wmm_enabled=1                           # Soporte para QoS"                                                >> /etc/hostapd/hostapd.conf
echo "  ieee80211d=1                            # Limitar las frecuencias sólo a las disponibles en el país"       >> /etc/hostapd/hostapd.conf
echo "  country_code=ES"                                                                                           >> /etc/hostapd/hostapd.conf
echo "  ht_capab=[SHORT-GI-20][SHORT-GI-40][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]"                                >> /etc/hostapd/hostapd.conf
echo "  vht_capab=[MAX-MPDU-3895][VHT160-80PLUS80][SHORT-GI-80][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]"           >> /etc/hostapd/hostapd.conf

















      echo "ht_capab=[RXLDPC][HT40+][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-7935][DSSS_CCK-40]"                                                                                                       >> /etc/hostapd/hostapd.conf
      echo "#[HT20][SHORT-GI-20] dejados fuera para forzar que la red n se cree en el canal de 40Mhz"                                                                                                    >> /etc/hostapd/hostapd.conf
      echo "vht_capab=[MAX-MPDU-11454][VHT160-80PLUS80][RXLDPC][SHORT-GI-80][SHORT-GI-160][TX-STBC][SU-BEAMFORMER][SU-BEAMFORMEE][MU-BEAMFORMER][MU-BEAMFORMEE][RX-ANTENNA-PATTERN][TX-ANTENNA-PATTERN]" >> /etc/hostapd/hostapd.conf
      echo ""


















vInterfazInalambrica="wlan0"
echo "#/etc/hostapd/hostapd.conf"                                                                > /etc/hostapd/hostapd.conf
echo "interface=$vInterfazInalambrica"                                                          >> /etc/hostapd/hostapd.conf
echo "driver=nl80211"                                                                           >> /etc/hostapd/hostapd.conf
echo "bridge=br0"                                                                               >> /etc/hostapd/hostapd.conf
echo "hw_mode=g"                                                                                >> /etc/hostapd/hostapd.conf
echo "wme_enabled=1"                                                                            >> /etc/hostapd/hostapd.conf
echo "ieee80211n=1"                                                                             >> /etc/hostapd/hostapd.conf
echo "ieee80211d=1"                                                                             >> /etc/hostapd/hostapd.conf
echo "channel=1"                                                                                >> /etc/hostapd/hostapd.conf
echo "country_code=ES"                                                                          >> /etc/hostapd/hostapd.conf
echo "wmm_enabled=1"                                                                            >> /etc/hostapd/hostapd.conf
echo "ht_capab=[RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]" >> /etc/hostapd/hostapd.conf
echo "ht_capab=[HT20+][HT40+][SHORT-GI-20][SHORT-GI-40]" >> /etc/hostapd/hostapd.conf

echo "ignore_broadcast_ssid=0"                                                                  >> /etc/hostapd/hostapd.conf
echo "ssid=RouterX86"                                                                           >> /etc/hostapd/hostapd.conf
echo "eap_reauth_period=360000000"                                                              >> /etc/hostapd/hostapd.conf
echo "wpa=2"                                                                                    >> /etc/hostapd/hostapd.conf
echo "wpa_key_mgmt=WPA-PSK"                                                                     >> /etc/hostapd/hostapd.conf
echo "wpa_pairwise=TKIP"                                                                        >> /etc/hostapd/hostapd.conf
echo "rsn_pairwise=CCMP"                                                                        >> /etc/hostapd/hostapd.conf
echo "wpa_passphrase=RouterX86"                                                                 >> /etc/hostapd/hostapd.conf



