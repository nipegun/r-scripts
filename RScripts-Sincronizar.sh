#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para sincronizar los r-scripts
#
# Ejecución remota:
# curl -s https://raw.githubusercontent.com/nipegun/d-scripts/master/DScripts-Sincronizar.sh | bash
# ----------

vColorAzul="\033[0;34m"
vColorAzulClaro="\033[1;34m"
vColorVerde='\033[1;32m'
vColorRojo='\033[1;31m'
vFinColor='\033[0m'

# Comprobar si el paquete wget está instalado. Si no lo está, instalarlo.
  if [[ $(dpkg-query -s wget 2>/dev/null | grep installed) == "" ]]; then
    echo ""
    echo "wget no está instalado. Iniciando su instalación..."
    echo ""
    sudo apt-get -y update
    sudo apt-get -y install wget
  fi

# Comprobar si hay conexión a Internet antes de sincronizar los r-scripts
  wget -q --tries=10 --timeout=20 --spider https://github.com
    if [[ $? -eq 0 ]]; then
      echo ""
      echo -e "${vColorAzulClaro}  Sincronizando los r-scripts con las últimas versiones y descargando nuevos r-scripts (si es que existen)...${vFinColor}"
      echo ""
      rm /root/scripts/r-scripts -R 2> /dev/null
      mkdir /root/scripts 2> /dev/null
      cd /root/scripts
      git clone --depth=1 https://github.com/nipegun/r-scripts
      mkdir -p /root/scripts/r-scripts/Alias/
      rm /root/scripts/r-scripts/.git -R 2> /dev/null
      find /root/scripts/r-scripts/ -type f -iname "*.sh" -exec chmod +x {} \;
      /root/scripts/r-scripts/RScripts-CrearAlias.sh
      echo ""
      echo -e "${vColorVerde}    r-scripts sincronizados correctamente.${vFinColor}"
      echo ""
    else
      echo ""
      echo -e "${vColorRojo}  No se pudo iniciar la sincronización de los r-scripts porque no se detectó conexión a Internet.${vFinColor}"
      echo ""
    fi

