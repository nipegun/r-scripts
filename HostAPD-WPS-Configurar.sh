#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para agregar la configuración de WPS a hostapd
# ----------

# Crear el archivo hostapd.psk
 touch /etc/hostapd.psk

# Agregar líneas de configuración a /etc/hostapd/hostapd.conf
  echo "wpa_psk_file=/etc/hostapd.psk"                                      >> /etc/hostapd/hostapd.conf
  echo "ctrl_interface=/var/run/hostapd"                                    >> /etc/hostapd/hostapd.conf
  echo "eap_server=1"                                                       >> /etc/hostapd/hostapd.conf
  echo ""                                                                   >> /etc/hostapd/hostapd.conf
  echo "# WPS (No permite registradores WPS externos)"                      >> /etc/hostapd/hostapd.conf
  echo "wps_state=2 ap_setup_locked=1"                                      >> /etc/hostapd/hostapd.conf
  echo "uuid=87654321-9abc-def0-1234-56789abc0000 # Si no se proporciona un UUID se generará uno automáticamente basado en la dirección mac.">> /etc/hostapd/hostapd.conf
  echo "wps_pin_requests=/var/run/hostapd.pin-req"                          >> /etc/hostapd/hostapd.conf
  echo "device_name=Wireless AP manufacturer=Company"                       >> /etc/hostapd/hostapd.conf
  echo "model_name=WAP"                                                     >> /etc/hostapd/hostapd.conf
  echo "model_number=123"                                                   >> /etc/hostapd/hostapd.conf
  echo "serial_number=12345"                                                >> /etc/hostapd/hostapd.conf
  echo "device_type=6-0050F204-1"                                           >> /etc/hostapd/hostapd.conf
  echo "os_version=01020300"                                                >> /etc/hostapd/hostapd.conf
  echo "config_methods=label display push_button keypad"                    >> /etc/hostapd/hostapd.conf
  echo ""                                                                   >> /etc/hostapd/hostapd.conf
  echo "# if external Registrars are allowed, UPnP support could be added:" >> /etc/hostapd/hostapd.conf
  echo "#upnp_iface=br0"                                                    >> /etc/hostapd/hostapd.conf
  echo "#friendly_name=WPS Access Point"                                    >> /etc/hostapd/hostapd.conf
  
  
