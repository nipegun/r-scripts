#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para agregar la configuración de WPS a hostapd
# ----------

# Lanzar WPS
  # hostapd_cli wps_pin 53b63a98-d29e-4457-a2ed-094d7e6a669c 12345678
  # wpa_cli wps_pbc -i wlan0
  hostapd_cli wps_pbc

