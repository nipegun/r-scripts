#!/bin/bash

# Pongo a disposición pública este script bajo el término de "software de dominio público".
# Puedes hacer lo que quieras con él porque es libre de verdad; no libre con condiciones como las licencias GNU y otras patrañas similares.
# Si se te llena la boca hablando de libertad entonces hazlo realmente libre.
# No tienes que aceptar ningún tipo de términos de uso o licencia para utilizarlo o modificarlo porque va sin CopyLeft.

# ----------
# Script de NiPeGun para editar la configuración del servicio hostapd
# ----------

echo ""
echo "  Editando el archivo de configuración del servicio de hostapd..."
echo ""
nano /etc/systemd/system/multi-user.target.wants/hostapd.service

echo ""
echo "  Recargando los daemons..."
echo ""
systemctl daemon-reload

echo ""
echo "  Reiniciando el servicio hostapd..."
echo ""
systemctl restart hostapd.service

