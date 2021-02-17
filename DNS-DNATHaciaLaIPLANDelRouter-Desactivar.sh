#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

#--------------------------------------------------------------------------------------------------
#  Script de NiPeGun para desactivar el reenvio de todo el tráfico DNS hacia la IP LAN del router
#--------------------------------------------------------------------------------------------------

# Borrar el archivo de reglas
rm -rf /root/scripts/NFTables-DNS-DNATHaciaLaIPLANDelRouter.nft

# Borrar la inclusión de la reglas en el archivo de configuración de NFTables
sed -i -e 's|include "/root/scripts/NFTables-DNS-DNATHaciaLaIPLANDelRouter.nft"||g' /etc/nftables.conf

# Recargar NFTables
nft --file /etc/nftables.conf

