#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para agregar un host de Ubuntu a Nagios
#
# Ejecución remota:
#  curl -sL https://raw.githubusercontent.com/nipegun/r-scripts/master/Nagios4-Agregar-Host-Ubuntu.sh | bash -s URL Servicio
#
#  Ejemplo:
#  curl -sL https://raw.githubusercontent.com/nipegun/r-scripts/master/Nagios4-Agregar-Host-Ubuntu.sh | bash -s miubuntu "Mi Ubuntu" "192.168.0.123"
# ----------

# Definir constantes de color
  cColorAzul="\033[0;34m"
  cColorAzulClaro="\033[1;34m"
  cColorVerde='\033[1;32m'
  cColorRojo='\033[1;31m'
  # Para el color rojo también:
    #echo "$(tput setaf 1)Mensaje en color rojo. $(tput sgr 0)"
  cFinColor='\033[0m'

# Definir la cantidad de argumentos esperados
  cCantArgumEsperados=3

# Controlar que la cantidad de argumentos ingresados sea la correcta
  if [ $# -ne $cCantArgumEsperados ]
    then
      echo ""
      echo -e "${cColorRojo}  Mal uso del script. El uso correcto sería: ${cFinColor}"
      echo "    $0 [NombreDelHost] [AliasDelHost] [IPDelHost]"
      echo ""
      echo "  Ejemplo:"
      echo "    $0 'servdebian' 'servdebian' '192.168.1.10'"
      echo ""
      exit
    else

      NombreDelHost=$1
      AliasDelHost=$2
      IPDelHost=$3

      mkdir -p /etc/nagios4/computers/ 2> /dev/null

      echo "define host {"                                             > /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  use             linux-server"                           >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  host_name       $NombreDelHost"                         >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  alias           $AliasDelHost"                          >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  address         $IPDelHost"                             >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  icon_image      ubuntu.png"                             >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  icon_image_alt  Ubuntu"                                 >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  vrml_image      ubuntu.png"                             >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  statusmap_image ubuntu.gd2"                             >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "}"                                                        >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo ""                                                         >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "define service {"                                         >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  use                 generic-service"                    >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  host_name           $NombreDelHost"                     >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  service_description PING"                               >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  check_command       check_ping!100.0,20%!500.0,60%"     >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "}"                                                        >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo ""                                                         >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "define service {"                                         >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  use                 generic-service"                    >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  host_name           $NombreDelHost"                     >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  service_description SSH"                                >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  check_command       check_ssh"                          >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "}"                                                        >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo ""                                                         >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "define service{"                                          >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  use                 generic-service"                    >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  host_name           $NombreDelHost"                     >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  service_description Procesador"                         >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  check_command       comprobar_nrpe!check_load"          >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "}"                                                        >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo ""                                                         >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "define service{"                                          >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  use                 generic-service"                    >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  host_name           $NombreDelHost"                     >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  service_description Disco"                              >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  check_command       comprobar_nrpe!check_disk"          >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "}"                                                        >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo ""                                                         >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "define service{"                                          >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  use                 generic-service"                    >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  host_name           $NombreDelHost"                     >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  service_description Procesos"                           >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  check_command       comprobar_nrpe!check_total_procs"   >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "}"                                                        >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo ""                                                         >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "define service{"                                          >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  use                 generic-service"                    >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  host_name           $NombreDelHost"                     >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  service_description Usuarios"                           >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "  check_command       comprobar_nrpe!check_users"         >> /etc/nagios4/computers/$NombreDelHost.cfg
      echo "}"                                                        >> /etc/nagios4/computers/$NombreDelHost.cfg

      chown nagios:nagios /etc/nagios4/computers/$NombreDelHost.cfg
      chmod 664 /etc/nagios4/computers/$NombreDelHost.cfg

      sed -i -e "s-$NombreDelHost-$IPDelHost-g" /etc/nagios4/computers/$NombreDelHost.cfg

      systemctl restart nagios4

      echo ""
      echo "  Host agregado."
      echo "  Recuerda correr el siguiente script en el host, para que la monitorización funcione:"
      echo ""
      echo "    curl -sL https://raw.githubusercontent.com/nipegun/d-scripts/master/SoftInst/ParaCLI/Nagios-RemotePluginExecutor-InstalarEnHost.sh | bash"
      echo ""
      echo "    ...y también revisa que hays activado en ese host la IP del servidor nagios:"
      echo ""
      echo "      sed -i -e 's/allowed_hosts=127.0.0.1,::1/allowed_hosts=127.0.0.1,::1,IpDelServidorNagios/g' /etc/nagios/nrpe.cfg"
      echo "      service nagios-nrpe-server restart"
      echo ""
      echo "  Para comprobar manualmente nrpe desde el servidor Nagios4, ejecuta:"
      echo "  /usr/lib/nagios/plugins/check_nrpe -H IPDelHostAComprobar -c Comando"
      echo ""
      echo "  Si al haber agregado este host, Nagios4 no incia, comprueba que error de da la configuración, ejecutando:"
      echo "  /usr/sbin/nagios4 -v /etc/nagios4/nagios.cfg"
      echo ""

  fi

