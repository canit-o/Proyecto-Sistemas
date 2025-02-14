#!/bin/bash

echo "Actualizando el sistema..."
sudo apt update && sudo apt upgrade -y

echo "Agregando el repositorio de Jellyfin..."
sudo apt install -y software-properties-common apt-transport-https
wget -O - https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | sudo tee /usr/share/keyrings/jellyfin.asc

echo "deb [signed-by=/usr/share/keyrings/jellyfin.asc] https://repo.jellyfin.org/debian $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list

echo "Instalando Jellyfin..."
sudo apt update && sudo apt install -y jellyfin

echo "Habilitando y arrancando el servicio Jellyfin..."
sudo systemctl enable jellyfin
sudo systemctl start jellyfin

echo "Estado del servicio Jellyfin:"
sudo systemctl status jellyfin --no-pager

echo "Instalación completada. Accede a Jellyfin en: http://localhost:8096"