#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
#  Script de NiPeGun para instalar y configurar bind9 en un Debian configurado como router
#
#  Ejecución remota:
#  curl -s https://raw.githubusercontent.com/nipegun/r-scripts/master/PostInst/DNS-Servidor-InstalarYConfigurar.sh | bash
# ----------

# Declaraciones
  #vDominioLAN="home.arpa"
  #vTresOctetosClaseC="192.168.1"
  vDominioLAN="$1"
  vTresOctetosClaseC="$2"

# Variables automáticas
  vHostName="$(cat /etc/hostname)"
  vIPLANHost=$(hostname -I | cut -d' ' -f2)
  vOcteto1=$(echo $vTresOctetosClaseC | cut -d'.' -f1)
  vOcteto2=$(echo $vTresOctetosClaseC | cut -d'.' -f2)
  vOcteto3=$(echo $vTresOctetosClaseC | cut -d'.' -f3)

vColorAzul="\033[0;34m"
vColorAzulClaro="\033[1;34m"
vColorVerde='\033[1;32m'
vColorRojo='\033[1;31m'
vFinColor='\033[0m'

vCantArgsCorrectos=2
vArgsInsuficientes=65

if [ $# -ne $vCantArgsCorrectos ]
  then
    echo ""
    echo -e "${vColorRojo}  Mal uso del script. El uso correcto sería: ${vFinColor}"
    echo                 "    script [Dominio] [3OctetosDeLaSubred]"
    echo ""
    echo                 "  Ejemplo:"
    echo                 '    script "home.arpa" "192.168.1"'
    echo ""
    exit $vArgsInsuficientes
  else
    # Determinar la versión de Debian
      if [ -f /etc/os-release ]; then             # Para systemd y freedesktop.org
        . /etc/os-release
        OS_NAME=$NAME
        OS_VERS=$VERSION_ID
      elif type lsb_release >/dev/null 2>&1; then # linuxbase.org
        OS_NAME=$(lsb_release -si)
        OS_VERS=$(lsb_release -sr)
      elif [ -f /etc/lsb-release ]; then          # Para algunas versiones de Debian sin el comando lsb_release
        . /etc/lsb-release
        OS_NAME=$DISTRIB_ID
        OS_VERS=$DISTRIB_RELEASE
      elif [ -f /etc/debian_version ]; then       # Para versiones viejas de Debian.
        OS_NAME=Debian
        OS_VERS=$(cat /etc/debian_version)
      else                                        # Para el viejo uname (También funciona para BSD)
        OS_NAME=$(uname -s)
        OS_VERS=$(uname -r)
      fi

    if [ $OS_VERS == "7" ]; then

      echo ""
      echo -e "${vColorAzulClaro}  Iniciando el script de instalación de bind9 para Debian 7 (Wheezy)...${vFinColor}"
      echo ""

      echo ""
      echo -e "${vColorRojo}    Comandos para Debian 7 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${vFinColor}"
      echo ""

    elif [ $OS_VERS == "8" ]; then

      echo ""
      echo -e "${vColorAzulClaro}  Iniciando el script de instalación de bind9 para Debian 8 (Jessie)...${vFinColor}"
      echo ""

      echo ""
      echo -e "${vColorRojo}    Comandos para Debian 8 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${vFinColor}"
      echo ""

    elif [ $OS_VERS == "9" ]; then

      echo ""
      echo -e "${vColorAzulClaro}  Iniciando el script de instalación de bind9 para Debian 9 (Stretch)...${vFinColor}"
      echo ""

      echo ""
      echo -e "${vColorRojo}    Comandos para Debian 9 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${vFinColor}"
      echo ""

    elif [ $OS_VERS == "10" ]; then

      echo ""
      echo -e "${vColorAzulClaro}  Iniciando el script de instalación de bind9 para Debian 10 (Buster)...${vFinColor}"
      echo ""

      echo ""
      echo -e "${vColorRojo}    Comandos para Debian 10 todavía no preparados. Prueba ejecutarlo en otra versión de Debian.${vFinColor}"
      echo ""

    elif [ $OS_VERS == "11" ]; then

      echo ""
      echo -e "${vColorAzulClaro}  Iniciando el script de instalación de bind9 para Debian 11 (Bullseye)...${vFinColor}"
      echo ""

      # Borrar instalación existente
        echo ""
        echo "    Borrando instalación existente (si es que existe)..."
        echo ""
        mkdir -p /CopSegInt/              2> /dev/null
        mkdir -p /CopSegInt/DNS/etc/      2> /dev/null
        mv /etc/bind/ /CopSegInt/DNS/etc/ 2> /dev/null
        chattr -i /etc/resolv.conf        2> /dev/null
        rm -rf /var/cache/bind/
        rm -rf /etc/bind/
        systemctl stop bind9.service
        systemctl disable bind9.service
        apt-get -y purge bind9
        apt-get -y purge dnsutils
        apt-get -y autoremove
 
      # Cambiar el archivo /etc/hosts
        echo "127.0.0.1 $vHostName $vHostName.$vDominioLAN"   >> /etc/hosts
        echo "$vIPLANHost $vHostName $vHostName.$vDominioLAN" >> /etc/hosts

      # Instalar paquete
        echo ""
        echo "    Instalando bind9..."
        echo ""
        apt-get -y update && apt-get -y install bind9

      # named.conf.options
        echo ""
        echo "    Configurando el archivo /etc/bind/named.conf.options..."
        echo ""
        echo 'options {'                       > /etc/bind/named.conf.options
        echo '  directory "/var/cache/bind";' >> /etc/bind/named.conf.options # Carpeta donde se quiere guardar la cache con "rndc dumpdb -cache"
        echo '  forwarders {'                 >> /etc/bind/named.conf.options
        echo '    9.9.9.9;'                   >> /etc/bind/named.conf.options
        echo '    149.112.112.112;'           >> /etc/bind/named.conf.options
        echo '  };'                           >> /etc/bind/named.conf.options
        echo '  listen-on { any; };'          >> /etc/bind/named.conf.options # Que IPs tienen acceso al servicio
        echo '  allow-query { any; };'        >> /etc/bind/named.conf.options # Quién tiene permiso a hacer cualquier tipo de query
        echo '  allow-query-cache { any; };'  >> /etc/bind/named.conf.options # Quién tiene permiso a las queries guardadas en el cache
        echo '  recursion yes;'               >> /etc/bind/named.conf.options # Permitir las consultas recursivas
        echo '  allow-recursion { any; };'    >> /etc/bind/named.conf.options # Quién tiene acceso a consultas recursivas
        #echo '  dnssec-validation auto;'      >> /etc/bind/named.conf.options
        #echo '  listen-on-v6 { any; };'       >> /etc/bind/named.conf.options
        echo "};"                             >> /etc/bind/named.conf.options

      # Sintaxis named.conf.options
        echo ""
        echo "      Comprobando que la sintaxis del archivo /etc/bind/named.conf.options sea correcta..."
        echo ""
        vRespuestaCheckConf=$(named-checkconf  /etc/bind/named.conf.options)
        if [ "$vRespuestaCheckConf" = "" ]; then
          echo -e "${vColorVerde}        La sintaxis del archivo /etc/bind/named.conf.options es correcta:${vFinColor}"
        else
          echo ""
          echo -e "${vColorRojo}        La sintaxis del archivo /etc/bind/named.conf.options no es correcta:${vFinColor}"
          echo "        $vRespuestaCheckConf"
        fi

      # logs
        echo ""
        echo "    Configurando logs..."
        echo ""
        echo 'include "/etc/bind/named.conf.log";' >> /etc/bind/named.conf
        echo 'logging {'                                                            > /etc/bind/named.conf.log
        echo '  channel "default" {'                                               >> /etc/bind/named.conf.log
        echo '    file "/var/log/bind9/default.log" versions 10 size 10m;'         >> /etc/bind/named.conf.log
        echo '    print-time yes;'                                                 >> /etc/bind/named.conf.log
        echo '    print-severity yes;'                                             >> /etc/bind/named.conf.log
        echo '    print-category yes;'                                             >> /etc/bind/named.conf.log
        echo '    severity info;'                                                  >> /etc/bind/named.conf.log
        echo '  };'                                                                >> /etc/bind/named.conf.log
        echo ''                                                                    >> /etc/bind/named.conf.log
        echo '  channel "lame-servers" {'                                          >> /etc/bind/named.conf.log
        echo '    file "/var/log/bind9/lame-servers.log" versions 1 size 5m;'      >> /etc/bind/named.conf.log
        echo '    print-time yes;'                                                 >> /etc/bind/named.conf.log
        echo '    print-severity yes;'                                             >> /etc/bind/named.conf.log
        echo '    print-category yes;'                                             >> /etc/bind/named.conf.log
        echo '    severity info;'                                                  >> /etc/bind/named.conf.log
        echo '  };'                                                                >> /etc/bind/named.conf.log
        echo ''                                                                    >> /etc/bind/named.conf.log
        echo '  channel "queries" {'                                               >> /etc/bind/named.conf.log
        echo '    file "/var/log/bind9/queries.log" versions 10 size 10m;'         >> /etc/bind/named.conf.log
        echo '    print-time yes;'                                                 >> /etc/bind/named.conf.log
        echo '    print-severity yes;'                                             >> /etc/bind/named.conf.log
        echo '    print-category yes;'                                             >> /etc/bind/named.conf.log
        echo '    severity info;'                                                  >> /etc/bind/named.conf.log
        echo '  };'                                                                >> /etc/bind/named.conf.log
        echo ''                                                                    >> /etc/bind/named.conf.log
        #echo '  channel "security" {'                                              >> /etc/bind/named.conf.log
        #echo '    file "/var/log/bind9/security.log" versions 10 size 10m;'        >> /etc/bind/named.conf.log
        #echo '    print-time yes;'                                                 >> /etc/bind/named.conf.log
        #echo '    print-severity yes;'                                             >> /etc/bind/named.conf.log
        #echo '    print-category yes;'                                             >> /etc/bind/named.conf.log
        #echo '    severity info;'                                                  >> /etc/bind/named.conf.log
        #echo '  };'                                                                >> /etc/bind/named.conf.log
        #echo ''                                                                    >> /etc/bind/named.conf.log
        #echo '  channel "update" {'                                                >> /etc/bind/named.conf.log
        #echo '    file "/var/log/bind9/update.log" versions 10 size 10m;'          >> /etc/bind/named.conf.log
        #echo '    print-time yes;'                                                 >> /etc/bind/named.conf.log
        #echo '    print-severity yes;'                                             >> /etc/bind/named.conf.log
        #echo '    print-category yes;'                                             >> /etc/bind/named.conf.log
        #echo '    severity info;'                                                  >> /etc/bind/named.conf.log
        #echo '  };'                                                                >> /etc/bind/named.conf.log
        #echo ''                                                                    >> /etc/bind/named.conf.log
        #echo '  channel "update-security" {'                                       >> /etc/bind/named.conf.log
        #echo '    file "/var/log/bind9/update-security.log" versions 10 size 10m;' >> /etc/bind/named.conf.log
        #echo '    print-time yes;'                                                 >> /etc/bind/named.conf.log
        #echo '    print-severity yes;'                                             >> /etc/bind/named.conf.log
        #echo '    print-category yes;'                                             >> /etc/bind/named.conf.log
        #echo '    severity info;'                                                  >> /etc/bind/named.conf.log
        #echo '  };'                                                                >> /etc/bind/named.conf.log
        echo ''                                                                    >> /etc/bind/named.conf.log
        echo '  category "default"         { "default"; };'                        >> /etc/bind/named.conf.log
        echo '  category "lame-servers"    { "lame-servers"; };'                   >> /etc/bind/named.conf.log
        echo '  category "queries"         { "queries"; };'                        >> /etc/bind/named.conf.log
        #echo '  category "security"        { "security"; };'                       >> /etc/bind/named.conf.log
        #echo '  category "update"          { "update"; };'                         >> /etc/bind/named.conf.log
        #echo '  category "update-security" { "update-security"; };'                >> /etc/bind/named.conf.log
        echo ''                                                                    >> /etc/bind/named.conf.log
        echo '};'                                                                  >> /etc/bind/named.conf.log
        mkdir -p /var/log/bind9/ 2> /dev/null
        chown bind:bind /var/log/bind9 -R # El usuario bind necesita permisos de escritura en el la carpeta
        # Dar permisos de escritura a bind9 en el directorio /var/log/bind9 (No hace falta si se meten los logs en /var/log/named/)
          sed -i -e 's|/var/log/named/ rw,|/var/log/named/ rw,\n\n/var/log/bind9/** rw,\n/var/log/bind9/ rw,|g' /etc/apparmor.d/usr.sbin.named

      # Sintaxis /etc/bind/named.conf.log
        echo ""
        echo "      Comprobando que la sintaxis del archivo /etc/bind/named.conf.log sea correcta..."
        echo ""
        vRespuestaCheckConf=$(named-checkconf  /etc/bind/named.conf.log)
        if [ "$vRespuestaCheckConf" = "" ]; then
          echo -e "${vColorVerde}        La sintaxis del archivo /etc/bind/named.conf.log es correcta:${vFinColor}"
        else
          echo ""
          echo -e "${vColorRojo}        La sintaxis del archivo /etc/bind/named.conf.log no es correcta:${vFinColor}"
          echo "        $vRespuestaCheckConf"
        fi

      # resolvconf
        echo ""
        echo "    Indicando la IP loopback como servidor DNS..."
        echo ""
        echo "nameserver 127.0.0.1"        > /etc/resolv.conf
        echo "nameserver 9.9.9.9"         >> /etc/resolv.conf
        echo "nameserver 149.112.112.112" >> /etc/resolv.conf
        chattr +i /etc/resolv.conf

      # Herramientas extra
        echo ""
        echo "    Instalando herramientas extra..."
        echo ""
        apt-get -y install dnsutils

      # Crear y popular zona LAN directa...
        echo ""
        echo "    Creando y populando la base de datos de la zona LAN directa..."
        echo ""
        cp /etc/bind/db.local /etc/bind/db.$vDominioLAN.directa
        sed -i -e "s|localhost. root.localhost.|$vHostName.$vDominioLAN. root.$vDominioLAN.|g" /etc/bind/db.$vDominioLAN.directa
        sed -i -e "s|localhost.|$vHostName.$vDominioLAN.|g"                                    /etc/bind/db.$vDominioLAN.directa
        sed -i '/127.0.0.1/d'                                                                  /etc/bind/db.$vDominioLAN.directa
        sed -i '/::1/d'                                                                        /etc/bind/db.$vDominioLAN.directa
        echo -e "$vHostName.$vDominioLAN.\tIN\tA\t$vIPLANHost"                              >> /etc/bind/db.$vDominioLAN.directa
        echo -e "ubuntuserver.$vDominioLAN.\tIN\tA\t$vOcteto1.$vOcteto2.$vOcteto3.10"       >> /etc/bind/db.$vDominioLAN.directa
        echo -e "ubuntudesktop.$vDominioLAN.\tIN\tA\t$vOcteto1.$vOcteto2.$vOcteto3.20"      >> /etc/bind/db.$vDominioLAN.directa
        echo -e "windowsserver.$vDominioLAN.\tIN\tA\t$vOcteto1.$vOcteto2.$vOcteto3.30"      >> /etc/bind/db.$vDominioLAN.directa
        echo -e "windowsdesktop.$vDominioLAN.\tIN\tA\t$vOcteto1.$vOcteto2.$vOcteto3.40"     >> /etc/bind/db.$vDominioLAN.directa
  
      # Comprobar la LAN zona directa
        echo ""
        echo "      Comprobando la sintaxis de la zona LAN directa..."
        echo ""
        named-checkzone $vDominioLAN /etc/bind/db.$vDominioLAN.directa
  
      # Linkear zona LAN directa a /etc/bind/named.conf.local
        echo ""
        echo "      Linkeando zona LAN directa a /etc/bind/named.conf.local..."
        echo ""
        echo 'zone "'"$vDominioLAN"'" {'                       >> /etc/bind/named.conf.local
        echo "  type master;"                                  >> /etc/bind/named.conf.local
        echo "  allow-transfer { none; };"                     >> /etc/bind/named.conf.local
        echo '  file "'"/etc/bind/db.$vDominioLAN.directa"'";' >> /etc/bind/named.conf.local
        echo "};"                                              >> /etc/bind/named.conf.local

      # Crear y popular zona LAN inversa...
        echo ""
        echo "    Creando y populando la base de datos de la zona LAN inversa..."
        echo ""
        cp /etc/bind/db.127 /etc/bind/db.$vDominioLAN.inversa
        sed -i -e "s|localhost. root.localhost.|$vHostName.$vDominioLAN. root.$vDominioLAN.|g" /etc/bind/db.$vDominioLAN.inversa
        sed -i -e "s|localhost.|$vHostName.$vDominioLAN.|g"                                    /etc/bind/db.$vDominioLAN.inversa
        sed -i '/1.0.0/d'                                                                      /etc/bind/db.$vDominioLAN.inversa
        echo -e "10\tIN\tPTR\tubuntuserver.$vDominioLAN."                                   >> /etc/bind/db.$vDominioLAN.inversa
        echo -e "20\tIN\tPTR\tubuntudesktop.$vDominioLAN."                                  >> /etc/bind/db.$vDominioLAN.inversa
        echo -e "30\tIN\tPTR\twindowsserver.$vDominioLAN."                                  >> /etc/bind/db.$vDominioLAN.inversa
        echo -e "40\tIN\tPTR\twindowsdesktop.$vDominioLAN."                                 >> /etc/bind/db.$vDominioLAN.inversa

      # Comprobar la LAN zona inversa
        echo ""
        echo "      Comprobando la sintaxis de la zona LAN inversa..."
        echo ""
        named-checkzone $vOcteto3.$vOcteto2.$vOcteto1.in-addr-arpa /etc/bind/db.$vDominioLAN.inversa

      # Linkear zona LAN inversa a /etc/bind/named.conf.local
        echo ""
        echo "      Linkeando zona LAN inversa a /etc/bind/named.conf.local..."
        echo ""
        echo ''                                                        >> /etc/bind/named.conf.local
        echo 'zone "'"$vOcteto3.$vOcteto2.$vOcteto1.in-addr.arpa"'" {' >> /etc/bind/named.conf.local
        echo "  type master;"                                          >> /etc/bind/named.conf.local
        echo "  allow-transfer { none; };"                             >> /etc/bind/named.conf.local
        echo '  file "'"/etc/bind/db.$vDominioLAN.inversa"'";'         >> /etc/bind/named.conf.local
        echo "};"                                                      >> /etc/bind/named.conf.local

      # Sintaxis /etc/bind/named.conf.local
        echo ""
        echo "    Comprobando que la sintaxis del archivo /etc/bind/named.conf.local sea correcta..."
        echo ""
        vRespuestaCheckConf=$(named-checkconf /etc/bind/named.conf.local)
        if [ "$vRespuestaCheckConf" = "" ]; then
          echo -e "${vColorVerde}        La sintaxis del archivo /etc/bind/named.conf.local es correcta:${vFinColor}"
        else
          echo ""
          echo -e "${vColorRojo}        La sintaxis del archivo /etc/bind/named.conf.local no es correcta:${vFinColor}"
          echo "        $vRespuestaCheckConf"
        fi

      # Coregir errores IPv6
        echo ""
        echo "    Corrigiendo los posibles errores de IPv6..."
        echo ""
        sed -i -e 's|RESOLVCONF=no|RESOLVCONF=yes|g'           /etc/default/named
        sed -i -e 's|OPTIONS="-u bind"|OPTIONS="-4 -u bind"|g' /etc/default/named

      # Reiniciar servidor DNS
        echo ""
        echo "    Reiniciando el servidor DNS..."
        echo ""
        service bind9 restart

      # Mostrar estado del servidor
        echo ""
        echo "    Mostrando el estado del servidor DNS..."
        echo ""
        systemctl status bind9 --no-pager

    fi

  fi


