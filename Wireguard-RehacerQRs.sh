#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para rehacer todos los códigos QR de las conexiones de los peers de WireGuard
#
# Ejecución remota:
#   curl -s https://raw.githubusercontent.com/nipegun/r-scripts/master/WireGuard-RehacerQRs.sh | bash
# ----------

vColorAzul="\033[0;34m"
vColorAzulClaro="\033[1;34m"
vColorVerde='\033[1;32m'
vColorRojo='\033[1;31m'
vFinColor='\033[0m'

echo ""
echo -e "${vColorAzulClaro}  Rehaciendo todos los códigos QR de las conexiones de los peers de WireGuard..${vFinColor}"
echo ""

# Comprobar si el paquete qrencode está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s qrencode 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo -e "${vColorRojo}    El paquete qrencode no está instalado. Iniciando su instalación...${vFinColor}"
    echo ""
    apt-get -y update
    apt-get -y install qrencode
    echo ""
  fi

for vNumPeer in {2..254}
  do
    echo ""
    echo "    Rehaciendo el código QR para la conexión del peer User$vNumPeer a partir del archivo /root/WireGuard/WireGuardUser$vNumPeer.conf..."
    echo ""
    qrencode -t png -o /root/WireGuard/WireGuardUser"$vNumPeer"QR.png -r /root/WireGuard/WireGuardUser"$vNumPeer".conf 2> /dev/null
    cat /root/WireGuard/WireGuardUser"$vNumPeer".conf | qrencode -t ansiutf8 2> /dev/null
  done

