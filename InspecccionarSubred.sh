#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

#----------------------------------------------------------------------
#  Script de NiPeGun para inspeccionar la subred indicada usando nmap
#----------------------------------------------------------------------

CantArgsCorrectos=1
ArgsInsuficientes=65

ColorRojo='\033[1;31m'
ColorVerde='\033[1;32m'
FinColor='\033[0m'

if [ $# -ne $CantArgsCorrectos ]
  then
    echo ""
    echo "--------------------------------------------------------------------------"
    echo -e "${ColorRojo}Mal uso del script.${FinColor} El uso correcto sería:"
    echo ""
    echo -e "  $0 ${ColorVerde}[IP de la red]${FinColor}"
    echo ""
    echo "Ejemplo:"
    echo ""
    echo "  $0 192.168.0.0/24"
    echo "--------------------------------------------------------------------------"
    echo ""
    exit $ArgsInsuficientes
  else
    echo ""
    echo -e "${ColorVerde}Inspeccionando la subred...${FinColor}"
    echo ""

    apt-get update
    apt-get -y install nmap > /dev/null
    nmap -sP $1
fi

