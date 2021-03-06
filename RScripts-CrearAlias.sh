#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

#-----------------------------------------------------------
#  Script de NiPeGun para crear los alias de los r-scripts 
#-----------------------------------------------------------

ColorVerde="\033[1;32m"
FinColor="\033[0m"

echo ""
echo -e "${ColorVerde}Creando alias para los r-scripts...${FinColor}"
echo ""

ln -s /root/scripts/r-scripts/RScripts-Sincronizar.sh      /root/scripts/r-scripts/Alias/sinrs

ln -s /root/scripts/r-scripts/DHCP-Editar.sh               /root/scripts/r-scripts/Alias/edhcp
ln -s /root/scripts/r-scripts/HostAPD-Editar.sh            /root/scripts/r-scripts/Alias/ehostapd
ln -s /root/scripts/r-scripts/MostrarAparatosConectados.sh /root/scripts/r-scripts/Alias/aparatos

echo ""
echo -e "${ColorVerde}Alias creados. Deberías poder ejecutar los r-scripts escribiendo el nombre de su alias.${FinColor}"
echo ""

