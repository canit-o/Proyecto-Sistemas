#!/bin/bash

echo "--------------------"
echo "Indica una opción:"
echo "--------------------"
echo "1 - Instalar"
echo "2 - Actualizar"
echo "3 - Verificar versión"
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
        if apt list --upgradable 2>/dev/null | grep -q "jellyfin"; then
                echo "Jellyfin tiene una actualización disponible."
                read -p "¿Deseas actualizar Jellifin? (S/n): " actualizar
                if [[ -z "$actualizar" || "$actualizar" =~ ^[Ss]$ ]]; then
                    echo "Preparando actualizacion..."
                    echo "Deteniendo Jellyfin..."
                    sudo systemctl stop jellyfin
                    sudo apt install --only-upgrade jellyfin
                    echo "Actualización completada. Accede a Jellyfin en: http://localhost:8096"
                fi
            else
                echo "Jellyfin no tiene ninguna actualizacion"
            fi

        

        ;;
    3)
        echo "La version actual de Jellyfin es:" 
        jellyfin --version
        ;;

    4)
echo "Verificando instalacion de docker"
output=$(docker --version )

if [[ "$output" == *"Docker version"* ]]; then
    echo "Instalacion de docker verificada"
    echo "Despegando servicio con jellyfin..."
    sudo docker run jellyfin/jellyfin
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
