#!/bin/bash

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

# Instalar el paquete oficial del repo de Dbian
  sudo apt-get -y install hostapd

# Desenmascarar y activar el servicio (Si no, con entorno gráfico NetworkManager no lo deja iniciar)
  echo ""
  echo "  Desenmascarando y activando el servicio hostapd..."
  echo ""
  sudo systemctl unmask hostapd
  sudo systemctl enable hostapd --now
  sudo systemctl status hostapd --no-pager

# Copiar el binario compilado reemplazando el binario instalado desde el repo
  sudo cp -fv hostapd /usr/sbin/
