Mediatek MT7610U

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





interface=wlan0
driver=nl80211
ssid=test
channel=1








          echo ""
          echo "    Configurando el demonio hostapd..."
          echo ""
          echo "#/etc/hostapd/hostapd.conf"                                                                                 > /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "# Punto de acceso básico"                                                                                  >> /etc/hostapd/hostapd.conf
          echo "#bridge=br0"                                                                                               >> /etc/hostapd/hostapd.conf
          echo "#interface=wlan0"                                                                                          >> /etc/hostapd/hostapd.conf
          echo "#ssid=BasicAP"                                                                                             >> /etc/hostapd/hostapd.conf
          echo "#channel=0"                                                                                                >> /etc/hostapd/hostapd.conf
          echo "#hw_mode=a"                                                                                                >> /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "# Primer punto de acceso"                                                                                  >> /etc/hostapd/hostapd.conf
          echo "bridge=br0"                                                                                                >> /etc/hostapd/hostapd.conf
          echo "interface=$vInterfazWLAN1"                                                                                 >> /etc/hostapd/hostapd.conf
          echo "wpa=2"                                                                                                     >> /etc/hostapd/hostapd.conf
          echo "wpa_key_mgmt=WPA-PSK"                                                                                      >> /etc/hostapd/hostapd.conf
          echo "wpa_pairwise=TKIP"                                                                                         >> /etc/hostapd/hostapd.conf
          echo "rsn_pairwise=CCMP"                                                                                         >> /etc/hostapd/hostapd.conf
          echo "ignore_broadcast_ssid=0"                                                                                   >> /etc/hostapd/hostapd.conf
          echo "eap_reauth_period=360000000"                                                                               >> /etc/hostapd/hostapd.conf
          echo "ssid=RouterX86"                                                                                            >> /etc/hostapd/hostapd.conf
          echo "wpa_passphrase=RouterX86"                                                                                  >> /etc/hostapd/hostapd.conf
          echo ""                                                                                                          >> /etc/hostapd/hostapd.conf
          echo "#Tarjeta TP-LINK TL-WDN4800 Atheros 9380 (168c:0030)"                                                      >> /etc/hostapd/hostapd.conf
          echo "driver=nl80211"                                                                                            >> /etc/hostapd/hostapd.conf
          echo "channel=0                               # El canal a usar. 0 buscará el canal con menos interferencias"    >> /etc/hostapd/hostapd.conf
          echo "hw_mode=a"                                                                                                 >> /etc/hostapd/hostapd.conf
          echo "ieee80211n=1"                                                                                              >> /etc/hostapd/hostapd.conf
          echo "wme_enabled=1"                                                                                             >> /etc/hostapd/hostapd.conf
          echo "wmm_enabled=1                           # Soporte para QoS"                                                >> /etc/hostapd/hostapd.conf
          echo "ieee80211d=1                            # Limitar las frecuencias sólo a las disponibles en el país"       >> /etc/hostapd/hostapd.conf
          echo "country_code=ES"                                                                                           >> /etc/hostapd/hostapd.conf
          echo "ht_capab=[RXLDPC][HT20+][HT40+][SHORT-GI-20][SHORT-GI-40][TX-STBC][RX-STBC1][MAX-AMSDU-3839][DSSS_CCK-40]" >> /etc/hostapd/hostapd.conf




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










HT20/HT40
SM Power Save disabled
RX Greenfield
RX HT20 SGI
RX HT40 SGI


Max MPDU length: 3895
Supported Channel Width: neither 160 nor 80+80
short GI (80 MHz)
RX antenna pattern consistency
TX antenna pattern consistency
