#!/bin/bash

echo "--------------------"
echo "Indica una opción:"
echo "--------------------"
echo "1 - Instalar"
echo "2 - Actualizar"
echo "3 - Verificar Versión"
echo "4 - Desplegar servicio con dockers"
read -p "Selecciona una opción (1-4): " opcion

case $opcion in
    1)
        echo "Ejecutando instalación..."

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
        ;;
    2)
        echo "Ejecutando actualización..."
        echo "Actualizando el sistema..."
        sudo apt update && sudo apt upgrade -y

        echo "Verificando repositorio de Jellyfin..."
        if [ ! -f /usr/share/keyrings/jellyfin.asc ]; then
        echo "Clave GPG no encontrada. Descargando de nuevo..."
        wget -O - https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | sudo tee /usr/share/keyrings/jellyfin.asc
        fi

        if [ ! -f /etc/apt/sources.list.d/jellyfin.list ]; then
        echo "Repositorio de Jellyfin no encontrado. Agregándolo de nuevo..."
        echo "deb [signed-by=/usr/share/keyrings/jellyfin.asc] https://repo.jellyfin.org/debian $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list
        fi

        echo "Actualizando Jellyfin a la última versión disponible..."
        sudo apt update && sudo apt upgrade -y jellyfin

        echo "Reiniciando el servicio Jellyfin..."
        sudo systemctl restart jellyfin

        echo "Estado del servicio Jellyfin:"
        sudo systemctl status jellyfin --no-pager

        echo "Actualización completada. Accede a Jellyfin en: http://localhost:8096"

        ;;
    3)
        echo "Verificando versión..."
        
        ;;

    4)
echo "Verificando instalacion de docker"
output=$(docker --version )

if [[ "$output" == *"Docker version"* ]]; then
    echo "Instalacion de docker verificada"
    echo "Despegando servicio con jellyfin..."
    docker run jellyfin/jellyfin
    echo "Servicio desplegado correctamente, Accede a Jellyfin en: http://localhost:8096"
else
    echo "Docker no está instalado."
    read -p "¿Deseas instalar Docker? (S/n): " respuesta
    if [[ -z "$respuesta" || "$respuesta" =~ ^[Ss]$ ]]; then
        echo "Instalando Docker..."
        sudo apt update
        sudo apt install apt-transport-https ca-certificates curl software-properties-common
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
        sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
        apt-cache policy docker-ce
        sudo apt install docker-ce
        echo "Docker instalado correctamente."
        docker --version
        fi
        fi
      ;;  

      
    *)
        echo "Opción no válida. Por favor, elige entre 1 y 4."
        ;;
esac
