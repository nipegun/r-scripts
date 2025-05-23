#!/bin/bash

# Desinstalar todo lo instalado previamente
  sudo mv /etc/hostapd/hostapd.conf /tmp/
  sudo apt-get -y autoremove --purge hostapd
  sudo rm -rf /etc/hostapd/

# Instalar el paquete oficial del repo de Dbian
  sudo apt-get -y install hostapd

# Indicar la ubicación del archivo de configuración de hostapd
  echo ""
  echo "  Indicando la ubicación del archivo de configuración de hostapd..."
  echo ""
  sudo cp /etc/default/hostapd /etc/default/hostapd.bak
  sudo sed -i -e 's|#DAEMON_CONF=""|DAEMON_CONF="/etc/hostapd/hostapd.conf"|g'      /etc/default/hostapd
  sudo sed -i -e 's|#DAEMON_OPTS=""|DAEMON_OPTS="-dd -t -f /var/log/hostapd.log"|g' /etc/default/hostapd

# Volver a copiar el archivo de configuración viejo, si es que existía
  sudo cp -fv /tmp/hostapd.conf /etc/hostapd/hostapd.conf

# Desenmascarar y activar el servicio (Si no, con entorno gráfico NetworkManager no lo deja iniciar)
  echo ""
  echo "  Desenmascarando y activando el servicio hostapd..."
  echo ""
  sudo systemctl unmask hostapd
  sudo systemctl enable hostapd --now
  sudo systemctl status hostapd --no-pager


# Instalar herramientas para compilar
  sudo apt-get -y install build-essential
  sudo apt-get -y install pkg-config
  sudo apt-get -y install libnl-3-dev
  sudo apt-get -y install libssl-dev
  sudo apt-get -y install libnl-genl-3-dev

# Clonar repositorio con la última versión
  cd /tmp
  sudo rm -rf /tmp/hostap
  git clone https://w1.fi/hostap.git

# Compilar
  cd hostap/hostapd
  cp defconfig .config
  make -j$(nproc)

# Copiar el binario compilado reemplazando el binario instalado desde el repo
  sudo cp -fv hostapd /usr/sbin/

