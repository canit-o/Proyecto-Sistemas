#!/bin/bash

install_jellyfin() {
    echo "Instalando Jellyfin..."
    sudo apt update
    sudo apt install -y wget apt-transport-https curl gnupg
    
    # Eliminar claves antiguas si existen
    sudo rm -f /usr/share/keyrings/jellyfin_team-archive-keyring.gpg
    
    # Descargar y agregar la clave GPG correctamente
    curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/jellyfin_team-archive-keyring.gpg
    
    # Agregar el repositorio de Jellyfin
    echo "deb [signed-by=/usr/share/keyrings/jellyfin_team-archive-keyring.gpg] https://repo.jellyfin.org/ubuntu $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/jellyfin.list > /dev/null
    
    sudo apt update
    sudo apt install -y jellyfin
    echo "Jellyfin instalado correctamente."
}

# Función para desinstalar Jellyfin
uninstall_jellyfin() {
    echo "Desinstalando Jellyfin..."
    sudo systemctl stop jellyfin
    sudo apt remove --purge -y jellyfin
    sudo rm -rf /var/lib/jellyfin /etc/jellyfin /var/log/jellyfin
    echo "Jellyfin ha sido desinstalado."
}

# Función para iniciar Jellyfin
start_jellyfin() {
    echo "Iniciando Jellyfin..."
    sudo systemctl start jellyfin
    echo "Jellyfin iniciado."
}

# Función para detener Jellyfin
stop_jellyfin() {
    echo "Deteniendo Jellyfin..."
    sudo systemctl stop jellyfin
    echo "Jellyfin detenido."
}

# Función para ver logs de Jellyfin
logs_jellyfin() {
    echo "Mostrando logs de Jellyfin..."
    sudo journalctl -u jellyfin -n 50 --no-pager
}


clear
echo "--------------------"
echo "Indica una opción:"
echo "--------------------"
echo "1 - Instalar mediate comandos"
echo "2 - Actualizar"
echo "3 - Verificar versión"
echo "4 - Desplegar servicio con dockers"
read -p "Selecciona una opción (1-4): " opcion

case $opcion in
    1)
    clear
        while true; do
    echo "1) Instalar Jellyfin"
    echo "2) Desinstalar Jellyfin"
    echo "3) Iniciar Jellyfin"
    echo "4) Detener Jellyfin"
    echo "5) Ver logs de Jellyfin"
    echo "6) Salir"
    read -p "Seleccione una opción: " option

    case "$option" in
        1)
            install_jellyfin
            ;;
        2)
            uninstall_jellyfin
            ;;
        3)
            start_jellyfin
            ;;
        4)
            stop_jellyfin
            ;;
        5)
            logs_jellyfin
            ;;
        6)
            echo "Saliendo..."
            exit 0
            ;;
        *)
            echo "Opción no válida, intente de nuevo."
            ;;
    esac

done
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

if [[ "$output" == "Docker version" ]]; then
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
