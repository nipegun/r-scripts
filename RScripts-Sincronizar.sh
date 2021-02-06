#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

#----------------------------------------------------
#  Script de NiPeGun para sincronizar los r-scripts
#----------------------------------------------------

ColorRojo='\033[1;31m'
ColorVerde='\033[1;32m'
FinColor='\033[0m'

# Comprobar si hay conexión a Internet antes de sincronizar los r-scripts
wget -q --tries=10 --timeout=20 --spider https://github.com
  if [[ $? -eq 0 ]]; then
    echo ""
    echo -e "${ColorVerde}-----------------------------------------------------${FinColor}"
    echo -e "${ColorVerde}Sincronizando los r-scripts con las últimas versiones${FinColor}"
    echo -e "${ColorVerde} y descargando nuevos r-scripts si es que existen... ${FinColor}"
    echo -e "${ColorVerde}-----------------------------------------------------${FinColor}"
    echo ""
    rm /root/scripts/r-scripts -R 2> /dev/null
    mkdir /root/scripts 2> /dev/null
    cd /root/scripts
    git clone --depth=1 https://github.com/nipegun/r-scripts
    mkdir -p /root/scripts/r-scripts/Alias/
    rm /root/scripts/r-scripts/.git -R 2> /dev/null
    find /root/scripts/r-scripts/ -type f -iname "*.sh" -exec chmod +x {} \;
    /root/scripts/r-scripts/RScripts-CrearAlias.sh.sh
    echo ""
    echo -e "${ColorVerde}-------------------------------------${FinColor}"
    echo -e "${ColorVerde}r-scripts sincronizados correctamente${FinColor}"
    echo -e "${ColorVerde}-------------------------------------${FinColor}"
    echo ""
  else
    echo ""
    echo -e "${ColorRojo}-----------------------------------------------------------------------------------------------${FinColor}"
    echo -e "${ColorRojo}No se pudo iniciar la sincronización de los r-scripts porque no se detectó conexión a Internet.${FinColor}"
    echo -e "${ColorRojo}-----------------------------------------------------------------------------------------------${FinColor}"
    echo ""
  fi

