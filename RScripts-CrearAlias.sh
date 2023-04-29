#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para crear los alias de los r-scripts 
# ----------

vColorAzul="\033[0;34m"
vColorAzulClaro="\033[1;34m"
vColorVerde='\033[1;32m'
vColorRojo='\033[1;31m'
vFinColor='\033[0m'

echo ""
echo -e "${vColorAzulClaro}  Creando alias para los r-scripts...${vFinColor}"
echo ""

ln -s /root/scripts/r-scripts/RScripts-Sincronizar.sh      /root/scripts/r-scripts/Alias/sinrs

ln -s /root/scripts/r-scripts/DHCP-Editar.sh               /root/scripts/r-scripts/Alias/edhcp
ln -s /root/scripts/r-scripts/HostAPD-Editar.sh            /root/scripts/r-scripts/Alias/ehostapd
ln -s /root/scripts/r-scripts/MostrarAparatosConectados.sh /root/scripts/r-scripts/Alias/aparatos
ln -s /root/scripts/r-scripts/WireGuard-Editar.sh          /root/scripts/r-scripts/Alias/ewireguard

echo ""
echo -e "${vColorVerde}    Alias creados. Deberías poder ejecutar los r-scripts escribiendo el nombre de su alias.${vFinColor}"
echo ""

