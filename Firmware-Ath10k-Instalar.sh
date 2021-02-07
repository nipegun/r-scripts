#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

#------------------------------------------------------------------------------------
#  Script de NiPeGun para crear instalar el firmware ath10k de Candela Technologies
#------------------------------------------------------------------------------------

ColorVerde="\033[1;32m"
FinColor="\033[0m"

echo ""
echo -e "${ColorVerde}--------------------------------------------------------------------------${FinColor}"
echo -e "${ColorVerde}Iniciando el script de instalación de los drivers ath10k de CandelaTech...${FinColor}"
echo -e "${ColorVerde}--------------------------------------------------------------------------${FinColor}"
echo ""

echo ""
echo -e "${ColorVerde}Instalando paquetes desde los repositorios...${FinColor}"
echo ""
apt-get -y update
apt-get -y purge firmware-atheros
apt-get -y autoremove
apt-get -y install firmware-atheros

echo ""
echo -e "${ColorVerde}-----------------------------------------------------------------------${FinColor}"
echo -e "${ColorVerde}Script de instalación de los drivers ath10k de CandelaTech, finalizado.${FinColor}"
echo -e "${ColorVerde}-----------------------------------------------------------------------${FinColor}"
echo ""

