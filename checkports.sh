#!/bin/bash

# ==============================================================================
# Script de Configuracion de Red para CentOS 10
# Network Configuration Script for CentOS 10
#
# Autor: Eduardo Ayala (eduayaqq14@gmail.com)
# Creador: Eduardo Ayala (eduayaqq14@gmail.com)
# GitHub: https://github.com/eduayaqq/easymail
#
# Este script automatiza la configuración de una interfaz de red con una
# dirección IP estática en CentOS 10 y configura el firewall para permitir
# los servicios de correo, web y base de datos.
#
# This script automates the configuration of a network interface with a
# static IP address on CentOS 10 and configures the firewall to allow
# mail, web, and database services.
# ==============================================================================

# --- Variables globales y de lenguaje ---
# --- Global and language variables ---
LOG_FILE="./network_setup_$(date +'%Y-%m-%d').log"
LANG_CHOICE=""

# Puertos y servicios necesarios para la configuración de EasyMail
# Required ports and services for EasyMail setup
PORTS_TO_CHECK=(
    "80/tcp"      # HTTP
    "443/tcp"     # HTTPS
    "3306/tcp"    # MariaDB
    "25/tcp"      # SMTP
    "587/tcp"     # Submission
    "465/tcp"     # SMTPS
    "143/tcp"     # IMAP
    "993/tcp"     # IMAPS
    "110/tcp"     # POP3
    "995/tcp"     # POP3S
)
SERVICES_TO_CHECK=(
    "http"
    "https"
    "mysql"
    "smtp"
    "submission"
    "smtps"
    "imap"
    "imaps"
    "pop3"
    "pop3s"
)

# --- Funciones de soporte ---
# --- Support functions ---

# Función para registrar mensajes en el archivo de log
# Function to log messages to the log file
log_message() {
    local type="$1"
    local message="$2"
    echo "$(date +'%Y-%m-%d %H:%M:%S') [$type] $message" | tee -a "$LOG_FILE"
}

# Función para manejar errores y salir del script
# Function to handle errors and exit the script
handle_error() {
    local message="$1"
    log_message "ERROR" "$message"
    if [[ "$LANG_CHOICE" == "es" ]]; then
        echo "¡Error crítico! El script se detendrá. Revisa el archivo de log para más detalles: $LOG_FILE"
    else
        echo "Critical error! The script will stop. Check the log file for more details: $LOG_FILE"
    fi
    exit 1
}

# Función para verificar si el usuario es root
# Function to check if the user is root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        if [[ "$LANG_CHOICE" == "es" ]]; then
            echo "Este script debe ser ejecutado como root. Utiliza 'sudo $0' o cambia a la cuenta de root."
        else
            echo "This script must be run as root. Use 'sudo $0' or switch to the root account."
        fi
        exit 1
    fi
}

# Función para obtener la interfaz, IP y Gateway
# Function to get the interface, IP, and Gateway
get_network_info() {
    if [[ "$LANG_CHOICE" == "es" ]]; then
        log_message "INFO" "Obteniendo información de red..."
    else
        log_message "INFO" "Obtaining network information..."
    fi

    # Extraer la interfaz y la IP usando ifconfig
    # Extract the interface and IP using ifconfig
    local ifconfig_output=$(ifconfig)
    # Busca el nombre de la interfaz que no es lo (loopback) y que tiene una dirección IP
    # Find the name of the interface that is not lo (loopback) and has an IP address
    NETWORK_INTERFACE=$(echo "$ifconfig_output" | grep -B1 "inet " | grep -v -- '--' | grep -o '^[a-zA-Z0-9]\+' | head -n 1)
    # Busca la IP asociada a esa interfaz
    # Find the IP associated with that interface
    IP_ADDRESS=$(echo "$ifconfig_output" | grep -A1 "^$NETWORK_INTERFACE" | grep "inet " | awk '{print $2}')

    # Si no se encuentra la interfaz o la IP, salir
    # If the interface or IP is not found, exit
    if [[ -z "$NETWORK_INTERFACE" ]] || [[ -z "$IP_ADDRESS" ]]; then
        handle_error "No se pudo obtener la información de la interfaz de red y/o la dirección IP."
    fi

    if [[ "$LANG_CHOICE" == "es" ]]; then
        log_message "INFO" "Interfaz de red detectada: $NETWORK_INTERFACE"
        log_message "INFO" "Dirección IP local detectada: $IP_ADDRESS"
    else
        log_message "INFO" "Network interface detected: $NETWORK_INTERFACE"
        log_message "INFO" "Local IP address detected: $IP_ADDRESS"
    fi

    # Extraer el Gateway usando ip route
    # Extract the Gateway using ip route
    GATEWAY=$(ip route | grep default | awk '{print $3}')
    if [[ -z "$GATEWAY" ]]; then
        handle_error "No se pudo obtener la dirección del Gateway."
    fi

    if [[ "$LANG_CHOICE" == "es" ]]; then
        log_message "INFO" "Gateway detectado: $GATEWAY"
    else
        log_message "INFO" "Gateway detected: $GATEWAY"
    fi
}

# Función para verificar y configurar firewalld
# Function to check and configure firewalld
check_and_configure_firewall() {
    if [[ "$LANG_CHOICE" == "es" ]]; then
        log_message "INFO" "Paso 1.1: Verificando y configurando el firewall..."
    else
        log_message "INFO" "Step 1.1: Checking and configuring the firewall..."
    fi

    # Verificar si firewalld está instalado, si no, instalarlo
    # Check if firewalld is installed, if not, install it
    if ! dnf list installed firewalld > /dev/null; then
        if [[ "$LANG_CHOICE" == "es" ]]; then
            log_message "INFO" "firewalld no está instalado. Instalando..."
        else
            log_message "INFO" "firewalld is not installed. Installing..."
        fi
        dnf install -y firewalld >> "$LOG_FILE" 2>&1 || handle_error "Error al instalar firewalld"
        systemctl enable --now firewalld >> "$LOG_FILE" 2>&1 || handle_error "Error al habilitar firewalld"
    fi

    # Asegurarse de que firewalld esté activo
    # Ensure firewalld is active
    systemctl start firewalld >> "$LOG_FILE" 2>&1
    systemctl enable firewalld >> "$LOG_FILE" 2>&1

    # Verificar y abrir puertos
    # Check and open ports
    if [[ "$LANG_CHOICE" == "es" ]]; then
        log_message "INFO" "Verificando y abriendo los puertos necesarios..."
    else
        log_message "INFO" "Checking and opening required ports..."
    fi

    for port in "${PORTS_TO_CHECK[@]}"; do
        if firewall-cmd --permanent --query-port="$port" >> "$LOG_FILE" 2>&1; then
            if [[ "$LANG_CHOICE" == "es" ]]; then
                log_message "INFO" "El puerto $port ya está abierto."
            else
                log_message "INFO" "Port $port is already open."
            fi
        else
            if [[ "$LANG_CHOICE" == "es" ]]; then
                log_message "WARNING" "El puerto $port está cerrado. Abriendo..."
            else
                log_message "WARNING" "Port $port is closed. Opening..."
            fi
            firewall-cmd --permanent --add-port="$port" >> "$LOG_FILE" 2>&1 || handle_error "Error al abrir el puerto $port"
        fi
    done

    # Recargar el firewall para aplicar los cambios
    # Reload the firewall to apply changes
    if [[ "$LANG_CHOICE" == "es" ]]; then
        log_message "INFO" "Recargando firewalld..."
    else
        log_message "INFO" "Reloading firewalld..."
    fi
    firewall-cmd --reload >> "$LOG_FILE" 2>&1 || handle_error "Error al recargar firewalld"

    if [[ "$LANG_CHOICE" == "es" ]]; then
        log_message "SUCCESS" "Configuración de firewall local completada. Todos los puertos necesarios están abiertos."
    else
        log_message "SUCCESS" "Local firewall configuration complete. All necessary ports are open."
    fi

    # Advertencia sobre firewalls externos
    # Warning about external firewalls
    if [[ "$LANG_CHOICE" == "es" ]]; then
        log_message "WARNING" "¡Atención! La configuración anterior solo aplica al firewall local de CentOS 10."
        log_message "WARNING" "Si tu servidor está detrás de un router o en un proveedor de nube (cloud),"
        log_message "WARNING" "es posible que necesites abrir estos mismos puertos en su configuración."
    else
        log_message "WARNING" "Attention! The above configuration only applies to the local CentOS 10 firewall."
        log_message "WARNING" "If your server is behind a router or on a cloud provider,"
        log_message "WARNING" "you may need to open these same ports in its configuration."
    fi
}

# --- Bloque principal del script ---
# --- Main script block ---
clear

# 1. Preguntar por el idioma
# 1. Ask for language
echo "Please select a language / Por favor, selecciona un idioma:"
echo "1. English"
echo "2. Español"
read -p "Enter your choice (1 or 2): " lang_choice_input

# Configurar la variable de idioma según la elección
# Set the language variable based on the choice
if [[ "$lang_choice_input" == "1" ]]; then
    LANG_CHOICE="en"
elif [[ "$lang_choice_input" == "2" ]]; then
    LANG_CHOICE="es"
else
    echo "Invalid choice. Exiting."
    exit 1
fi

# Preguntar si desea continuar
# Ask if the user wants to continue
if [[ "$LANG_CHOICE" == "es" ]]; then
    echo "¡Bienvenido al script de configuración de red!"
    echo "Este script realizará cambios importantes en el sistema."
    echo "Asegúrate de ejecutarlo con permisos de root."
    read -p "¿Deseas continuar? (s/n): " confirm_choice
else
    echo "Welcome to the network setup script!"
    echo "This script will make significant changes to your system."
    echo "Ensure you are running it with root permissions."
    read -p "Do you want to continue? (y/n): " confirm_choice
fi

# Salir si el usuario no confirma
# Exit if the user doesn't confirm
if [[ "$LANG_CHOICE" == "es" ]]; then
    if [[ "$confirm_choice" != "s" && "$confirm_choice" != "S" ]]; then
        echo "Saliendo del script. ¡Hasta luego!"
        exit 0
    fi
else
    if [[ "$confirm_choice" != "y" && "$confirm_choice" != "Y" ]]; then
        echo "Exiting script. Goodbye!"
        exit 0
    fi
fi

# 2. Verificar permisos de root
# 2. Check for root permissions
check_root

# 3. Obtener la información de la red
# 3. Get network information
get_network_info

# 4. Actualizar sistema e instalar paquetes necesarios
# 4. Update the system and install necessary packages
if [[ "$LANG_CHOICE" == "es" ]]; then
    log_message "INFO" "Iniciando la actualización del sistema y la instalación de paquetes..."
else
    log_message "INFO" "Starting system update and package installation..."
fi

# Ejecutar comandos de instalación y redirigir la salida al log
# Execute installation commands and redirect output to log
dnf update -y >> "$LOG_FILE" 2>&1 || handle_error "Error al ejecutar 'dnf update'"
dnf install -y epel-release >> "$LOG_FILE" 2>&1 || handle_error "Error al instalar 'epel-release'"
dnf install -y dnf >> "$LOG_FILE" 2>&1 || handle_error "Error al instalar 'dnf'"
dnf install -y firewalld >> "$LOG_FILE" 2>&1 || handle_error "Error al instalar 'firewalld'"

if [[ "$LANG_CHOICE" == "es" ]]; then
    log_message "INFO" "Paquetes instalados satisfactoriamente."
else
    log_message "INFO" "Packages installed successfully."
fi

# 5. Gestionar el servicio de NetworkManager
# 5. Manage the NetworkManager service
if [[ "$LANG_CHOICE" == "es" ]]; then
    log_message "INFO" "Deteniendo NetworkManager para aplicar la configuración..."
else
    log_message "INFO" "Stopping NetworkManager to apply the configuration..."
fi
systemctl stop NetworkManager >> "$LOG_FILE" 2>&1 || handle_error "Error al detener NetworkManager"

# 6. Modificar el archivo de configuración de red
# 6. Modify the network configuration file
if [[ "$LANG_CHOICE" == "es" ]]; then
    log_message "INFO" "Modificando el archivo de configuración de red: /etc/NetworkManager/system-connections/$NETWORK_INTERFACE.nmconnection"
else
    log_message "INFO" "Modifying the network configuration file: /etc/NetworkManager/system-connections/$NETWORK_INTERFACE.nmconnection"
fi

CONFIG_DIR="/etc/NetworkManager/system-connections"
CONFIG_FILE="$CONFIG_DIR/$NETWORK_INTERFACE.nmconnection"

# Crear el directorio si no existe
# Create the directory if it doesn't exist
mkdir -p "$CONFIG_DIR" >> "$LOG_FILE" 2>&1 || handle_error "Error al crear el directorio de configuración de NetworkManager."

# Escribir el nuevo contenido del archivo de configuración
# Write the new content to the configuration file
cat > "$CONFIG_FILE" << EOF
[connection]
id=$NETWORK_INTERFACE
uuid=$(uuidgen)
type=ethernet
autoconnect=true

[ipv4]
address1=$IP_ADDRESS/24
gateway=$GATEWAY
dns=8.8.8.8;8.8.4.4;
method=manual

[ipv6]
addr-gen-mode=stable-privacy
method=auto
EOF

# Aplicar permisos al archivo de configuración
# Apply permissions to the configuration file
chmod 600 "$CONFIG_FILE" >> "$LOG_FILE" 2>&1 || handle_error "Error al aplicar permisos al archivo de configuración."

# 7. Reiniciar NetworkManager
# 7. Restart NetworkManager
if [[ "$LANG_CHOICE" == "es" ]]; then
    log_message "INFO" "Reiniciando el servicio NetworkManager..."
else
    log_message "INFO" "Restarting the NetworkManager service..."
fi
systemctl restart NetworkManager >> "$LOG_FILE" 2>&1 || handle_error "Error al reiniciar el servicio NetworkManager"
systemctl enable NetworkManager >> "$LOG_FILE" 2>&1 || handle_error "Error al habilitar el servicio NetworkManager"

# 8. Configurar el Firewall (Nuevo paso)
# 8. Configure the Firewall (New step)
check_and_configure_firewall

# 9. Verificar la conexión a internet y obtener IP pública
# 9. Verify internet connection and get public IP
if [[ "$LANG_CHOICE" == "es" ]]; then
    log_message "INFO" "Verificando la conexión a internet..."
else
    log_message "INFO" "Verifying internet connection..."
fi
ping -c 4 google.com >> "$LOG_FILE" 2>&1
if [[ $? -ne 0 ]]; then
    handle_error "No se pudo establecer conexión a internet."
fi

if [[ "$LANG_CHOICE" == "es" ]]; then
    log_message "INFO" "Conexión a internet verificada con éxito."
    log_message "INFO" "Obteniendo la IP pública..."
else
    log_message "INFO" "Internet connection verified successfully."
    log_message "INFO" "Getting public IP..."
fi
dnf install -y curl >> "$LOG_FILE" 2>&1 || handle_error "Error al instalar 'curl'"
PUBLIC_IP=$(curl -s icanhazip.com)

# 10. Mostrar resultados finales y guardar en un archivo
# 10. Display final results and save to a file
SUMMARY_FILE="./network_summary_$(date +'%Y-%m-%d').txt"
if [[ "$LANG_CHOICE" == "es" ]]; then
    SUMMARY_MESSAGE="
Configuración de red completada con éxito.
-----------------------------------------------------
- Interfaz de red: $NETWORK_INTERFACE
- Dirección IP fija: $IP_ADDRESS
- Máscara de subred: 255.255.255.0
- Gateway: $GATEWAY
- Conexión a Internet: Satisfactoria
- IP Pública: $PUBLIC_IP
- Firewall local: Configurado correctamente
-----------------------------------------------------
¡Todos los cambios han sido aplicados!"
    echo "$SUMMARY_MESSAGE" | tee "$SUMMARY_FILE"
else
    SUMMARY_MESSAGE="
Network configuration completed successfully.
-----------------------------------------------------
- Network Interface: $NETWORK_INTERFACE
- Static IP Address: $IP_ADDRESS
- Subnet Mask: 255.255.255.0
- Gateway: $GATEWAY
- Internet Connection: Successful
- Public IP: $PUBLIC_IP
- Local Firewall: Configured successfully
-----------------------------------------------------
All changes have been applied!"
    echo "$SUMMARY_MESSAGE" | tee "$SUMMARY_FILE"
fi

log_message "SUCCESS" "Script finalizado. Los detalles se han guardado en $SUMMARY_FILE"
