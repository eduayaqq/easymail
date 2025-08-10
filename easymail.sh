#!/bin/bash


#*********EASYMAILTOTAL beta 1.0*******
#*                                    *
#*         For English Press 1        *
#*         For Spanish Press 2        *
#*        Para Ingles Presione 1      *
#*        Para Espanol Presione 2     *
#*                                    *
#*https://github.com/eduayaqq/easymail*
#**************************************


# Este script interactivo configura un servidor de correo Postfix con
# PostfixAdmin en CentOS 10.
# La lista de dominios y usuarios se configura de forma interactiva.
# --- Variables de configuración predeterminadas ---
POSTFIXADMIN_DIR="/var/www/html/postfixadmin"

# --- Funciones de control de flujo y seguridad ---

# Función para verificar si el usuario es root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "Este script debe ser ejecutado como root. Utiliza 'sudo $0'."
        exit 1
    fi
}

# Función para manejar errores y revertir cambios de forma básica
revert_changes() {
    echo "¡Error detectado en el paso: $1! El script se detendrá."
    echo "Revirtiendo cambios básicos..."

    # Revertir archivos de configuración si existen copias de seguridad
    if [[ -f "/etc/postfix/main.cf.bak" ]]; then
        cp /etc/postfix/main.cf.bak /etc/postfix/main.cf
        echo "Se ha restaurado el archivo /etc/postfix/main.cf."
    fi

    # Limpieza de directorios (no se revierte completamente la instalación)
    if [[ -d "$POSTFIXADMIN_DIR" ]]; then
        rm -rf "$POSTFIXADMIN_DIR"
    fi

    echo "Por favor, revisa los logs para más detalles y ejecuta los siguientes comandos manualmente si es necesario:"
    echo "sudo systemctl stop postfix dovecot httpd mariadb"
    echo "sudo dnf remove -y postfix dovecot dovecot-mysql httpd mariadb-server php php-fpm php-mysqlnd php-imap php-mbstring php-json php-xml php-zip"

    # Esperar confirmación del usuario para salir
    read -p "Presiona Enter para salir de la consola."
    exit 1
}

# Función para solicitar confirmación antes de continuar
confirm_action() {
    read -p "$1 (s/n): " confirm
    if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
        echo "Operación cancelada. Saliendo..."
        exit 0
    fi
}

# --- Bloque principal del script ---
check_root

echo "--- Script de Configuración de Postfix y PostfixAdmin ---"
echo "Este script instalará y configurará Postfix, Dovecot y PostfixAdmin en CentOS 10."
confirm_action "¿Estás seguro de que deseas continuar? Se realizarán cambios permanentes en el sistema."

# --- Configuración de Hostname ---
echo "--- Configuración de Hostname ---"
current_hostname=$(hostname)
echo "El hostname actual de la máquina es: $current_hostname"
read -p "¿Deseas mantener este hostname o modificarlo? (presiona 1 para mantener / presiona 2 para modificar): " choice
if [[ "$choice" == "2" ]]; then
    read -p "Por favor, introduce el nuevo hostname. Se recomienda usar un formato como 'srv.tudominio.com': " new_hostname
    if [[ -z "$new_hostname" ]]; then
        echo "El hostname no puede estar vacío. Saliendo del script."
        exit 1
    fi
    hostnamectl set-hostname "$new_hostname"
    echo "El hostname ha sido cambiado a: $new_hostname"
    current_hostname="$new_hostname" # Actualiza la variable para la siguiente sección
else
    echo "Se mantendrá el hostname actual: $current_hostname"
fi

# --- Configuración de Dominios de Correo Interactiva ---
echo "--- Configuración de Dominios de Correo ---"
DOMAINS=()
while true; do
    if [[ ${#DOMAINS[@]} -eq 0 ]]; then
        # El primer dominio es obligatorio
        read -p "¿Tu hostname actual ($current_hostname) contiene el dominio principal que deseas utilizar? (s/n): " use_hostname_domain_choice
        if [[ "$use_hostname_domain_choice" == "s" || "$use_hostname_domain_choice" == "S" ]]; then
            # Extraer el dominio del hostname
            new_domain=$(echo "$current_hostname" | sed -E 's/^srv\.//')
            if [[ -z "$new_domain" ]]; then
                echo "No se pudo extraer el dominio del hostname. Por favor, introdúcelo manualmente."
                read -p "Introduce un dominio para añadir a la lista: " new_domain
            fi
            if [[ -z "$new_domain" ]]; then
                echo "Es necesario introducir al menos un dominio. Por favor, inténtalo de nuevo."
                continue
            fi
            
            # Confirmación del primer dominio
            while true; do
                read -p "El dominio a añadir es '$new_domain'. ¿Es correcto? (1 para confirmar / 2 para editar): " confirm_domain_choice
                if [[ "$confirm_domain_choice" == "1" ]]; then
                    DOMAINS+=("$new_domain")
                    echo "Se ha añadido el dominio '$new_domain' a la lista."
                    break
                elif [[ "$confirm_domain_choice" == "2" ]]; then
                    echo "Volviendo a introducir el dominio..."
                    # Volver a preguntar si desea usar el hostname o introducir uno manualmente
                    break 2
                else
                    echo "Opción no válida. Por favor, usa '1' o '2'."
                fi
            done

        else
            while true; do
                read -p "Introduce el primer dominio para añadir a la lista: " new_domain
                if [[ -z "$new_domain" ]]; then
                    echo "El nombre de dominio no puede estar vacío. Por favor, inténtalo de nuevo."
                    continue
                fi
                read -p "El dominio a añadir es '$new_domain'. ¿Es correcto? (1 para confirmar / 2 para editar): " confirm_domain_choice
                if [[ "$confirm_domain_choice" == "1" ]]; then
                    DOMAINS+=("$new_domain")
                    echo "Se ha añadido el dominio '$new_domain' a la lista."
                    break
                elif [[ "$confirm_domain_choice" == "2" ]]; then
                    echo "Volviendo a introducir el dominio..."
                    continue
                else
                    echo "Opción no válida. Por favor, usa '1' o '2'."
                    continue
                fi
            done
        fi
    else
        read -p "¿Deseas añadir otro dominio a la lista? (s/n): " add_more_choice
        if [[ "$add_more_choice" == "s" || "$add_more_choice" == "S" ]]; then
            while true; do
                read -p "Introduce otro dominio para añadir a la lista: " new_domain
                if [[ -z "$new_domain" ]]; then
                    echo "El nombre de dominio no puede estar vacío. Por favor, inténtalo de nuevo."
                    continue
                fi
                read -p "El dominio a añadir es '$new_domain'. ¿Es correcto? (1 para confirmar / 2 para editar): " confirm_domain_choice
                if [[ "$confirm_domain_choice" == "1" ]]; then
                    DOMAINS+=("$new_domain")
                    echo "Se ha añadido el dominio '$new_domain' a la lista."
                    break
                elif [[ "$confirm_domain_choice" == "2" ]]; then
                    echo "Volviendo a introducir el dominio..."
                    continue
                else
                    echo "Opción no válida. Por favor, usa '1' o '2'."
                    continue
                fi
            done
        else
            echo "Se han añadido los siguientes dominios: ${DOMAINS[*]}"
            break
        fi
    fi
done

# --- Configuración de Reenvío Catch-All y Usuarios ---
echo "--- Configuración de Reenvío Catch-All y Usuarios de Correo ---"
ADMIN_EMAIL=""
USER_ALIASES=()
CATCHALL_DOMAINS=()

# Explicación de la funcionalidad de Catch-All
echo ""
echo "--- ¿Qué es un 'Catch-All'? ---"
echo "Un 'catch-all' es una regla de reenvío de correo que asegura que cualquier correo enviado a un dominio, sin importar si el usuario existe o no, será redirigido a un buzón de correo específico. Por ejemplo, si el catch-all para 'tudominio.com' está configurado para 'admin@tudominio.com', los correos enviados a 'usuario_inexistente@tudominio.com' no serán rechazados, sino que se entregarán al buzón de 'admin'."
echo "---"
echo ""

read -p "¿Deseas configurar un correo catch-all principal para redirigir los correos de los dominios? (s/n): " enable_catchall_choice

# Determinar el email principal para catch-all y reenvío
while true; do
    if [[ "$enable_catchall_choice" == "s" || "$enable_catchall_choice" == "S" ]]; then
        # Sugerir el dominio del hostname como correo principal
        suggested_admin_email="admin@$(echo "$current_hostname" | sed -E 's/^srv\.//')"
        read -p "¿Cuál será el correo electrónico principal al que se redirigirán los correos (p. ej., $suggested_admin_email)? " ADMIN_EMAIL
        # Si el usuario no ingresa nada, usar la sugerencia
        if [[ -z "$ADMIN_EMAIL" ]]; then
            ADMIN_EMAIL="$suggested_admin_email"
        fi
        echo "El correo electrónico principal será: $ADMIN_EMAIL"
        break
    else
        echo "No se configurará el reenvío de correos 'catch-all' de forma automática."
        # Aún se necesita una dirección de correo principal para la configuración de PostfixAdmin
        suggested_admin_email="admin@$(echo "$current_hostname" | sed -E 's/^srv\.//')"
        read -p "Por favor, introduce una dirección de correo principal para la administración (p. ej., $suggested_admin_email): " ADMIN_EMAIL
        # Si el usuario no ingresa nada, usar la sugerencia
        if [[ -z "$ADMIN_EMAIL" ]]; then
            ADMIN_EMAIL="$suggested_admin_email"
        fi
        echo "La dirección de correo de administración será: $ADMIN_EMAIL"
        break
    fi
done

# Bucle para la configuración de usuarios y catch-all por dominio
for domain in "${DOMAINS[@]}"; do
    echo "Configurando usuarios y catch-all para el dominio: $domain"

    # Pregunta sobre el usuario 'admin' para cada dominio
    while true; do
        read -p "¿Deseas crear un usuario de correo 'admin' para el dominio $domain? (s/n): " create_admin_choice
        if [[ "$create_admin_choice" == "s" || "$create_admin_choice" == "S" ]]; then
            username="admin"

            # Verificar si el usuario del sistema ya existe
            if id "$username" &>/dev/null; then
                echo "Advertencia: El usuario del sistema '$username' ya existe. Solo se configurará el buzón de correo."
            else
                read -p "Se creará un usuario de sistema '$username'. Ingresa su contraseña: " user_password
                useradd "$username"
                echo "$user_password" | passwd --stdin "$username"
                if [[ $? -ne 0 ]]; then
                    echo "¡Error al crear el usuario del sistema '$username'!"
                    revert_changes "creación de usuario del sistema"
                fi
                echo "El usuario de sistema '$username' ha sido creado."
            fi

            # Añadir el alias a la lista que se usará más adelante
            USER_ALIASES+=("$username@$domain $ADMIN_EMAIL")
            echo "Se ha configurado la cuenta de correo virtual para '$username@$domain'."
            break
        elif [[ "$create_admin_choice" == "n" || "$create_admin_choice" == "N" ]]; then
            echo "No se creará la cuenta 'admin' para el dominio $domain."
            break
        else
            echo "Respuesta no válida. Por favor, usa 's' o 'n'."
        fi
    done

    # Bucle para agregar más usuarios a este dominio
    while true; do
        read -p "¿Deseas añadir otro usuario de correo para el dominio $domain? (s/n): " add_user_choice
        if [[ "$add_user_choice" == "s" || "$add_user_choice" == "S" ]]; then
            read -p "Ingresa el nombre del usuario (p. ej., 'eduardo' para eduardo@$domain): " username
            if [[ -z "$username" ]]; then
                echo "El nombre de usuario no puede estar vacío. Por favor, inténtalo de nuevo."
                continue
            fi

            # Preguntar si desea crear un usuario del sistema para este buzón
            read -p "¿Deseas crear un usuario de sistema '$username'? (s/n): " create_sys_user_choice
            if [[ "$create_sys_user_choice" == "s" || "$create_sys_user_choice" == "S" ]]; then
                # Verificar si el usuario del sistema ya existe
                if id "$username" &>/dev/null; then
                    echo "Advertencia: El usuario del sistema '$username' ya existe. Solo se configurará el buzón de correo."
                else
                    read -p "Ingresa la contraseña para el usuario de sistema '$username': " user_password
                    useradd "$username"
                    echo "$user_password" | passwd --stdin "$username"
                    if [[ $? -ne 0 ]]; then
                        echo "¡Error al crear el usuario del sistema '$username'!"
                        revert_changes "creación de usuario del sistema"
                    fi
                    echo "El usuario de sistema '$username' ha sido creado."
                fi
            fi
            # Añadir el alias a la lista
            USER_ALIASES+=("$username@$domain $ADMIN_EMAIL")
            echo "Se ha configurado la cuenta de correo virtual para '$username@$domain'."

        elif [[ "$add_user_choice" == "n" || "$add_user_choice" == "N" ]]; then
            break
        else
            echo "Respuesta no válida. Por favor, usa 's' o 'n'."
        fi
    done

    # Preguntar sobre el catch-all para este dominio solo si se habilitó globalmente
    if [[ "$enable_catchall_choice" == "s" || "$enable_catchall_choice" == "S" ]]; then
        read -p "¿Deseas configurar una regla 'catch-all' para el dominio $domain, que redirija todos los correos a $ADMIN_EMAIL? (s/n): " catchall_choice
        if [[ "$catchall_choice" == "s" || "$catchall_choice" == "S" ]]; then
            CATCHALL_DOMAINS+=("$domain")
            echo "Se ha habilitado la regla 'catch-all' para $domain."
        else
            echo "No se configurará una regla 'catch-all' para $domain."
        fi
    fi
done

# --- Paso 1: Instalación de paquetes ---
echo "Paso 1: Instalando los repositorios EPEL y Remi y dependencias..."

echo "Instalando epel-release..."
dnf install -y epel-release
if [[ $? -ne 0 ]]; then revert_changes "instalación de epel-release"; fi

echo "Instalando remi-release desde su URL..."
dnf install -y https://rpms.remirepo.net/enterprise/remi-release-10.rpm
if [[ $? -ne 0 ]]; then revert_changes "instalación de remi-release"; fi

echo "Instalando dnf-utils, git, wget, curl, y las dependencias de PHP necesarias..."
dnf install -y dnf-utils git wget curl postfix dovecot dovecot-mysql httpd mariadb-server php-cli php-fpm php-mysqlnd php-imap php-mbstring php-json policycoreutils-python-utils php-xml php-zip
if [[ $? -ne 0 ]]; then revert_changes "instalación de paquetes"; fi

dnf config-manager --set-enabled remi
if [[ $? -ne 0 ]]; then revert_changes "habilitación del repositorio Remi"; fi

dnf module enable -y php:remi-8.3
if [[ $? -ne 0 ]]; then revert_changes "habilitación del módulo PHP 8.3"; fi

# --- Paso 2: Habilitar y arrancar servicios ---
echo "Paso 2: Habilitando y arrancando los servicios..."
systemctl enable --now postfix dovecot httpd mariadb
if [[ $? -ne 0 ]]; then revert_changes "habilitación de servicios"; fi

# --- Paso 3: Configuración de Postfix ---
echo "Paso 3: Configurando Postfix..."
echo "Creando copia de seguridad del archivo main.cf."
cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
if [[ $? -ne 0 ]]; then revert_changes "copia de seguridad de main.cf"; fi

DOMAINS_STR=$(IFS=,; echo "${DOMAINS[*]}")

# Modificar mydestination si existe, o agregarlo si no
if grep -q "^mydestination = " /etc/postfix/main.cf; then
    sed -i 's/^mydestination = .*/mydestination = $myhostname, localhost.$mydomain, localhost/' /etc/postfix/main.cf
else
    echo "mydestination = \$myhostname, localhost.\$mydomain, localhost" >> /etc/postfix/main.cf
fi

# Modificar virtual_alias_domains y virtual_alias_maps si existen, o agregarlos si no
if grep -q "^virtual_alias_domains = " /etc/postfix/main.cf; then
    sed -i "s|^virtual_alias_domains = .*|virtual_alias_domains = $DOMAINS_STR|" /etc/postfix/main.cf
else
    echo "virtual_alias_domains = $DOMAINS_STR" >> /etc/postfix/main.cf
fi

if grep -q "^virtual_alias_maps = " /etc/postfix/main.cf; then
    sed -i 's|^virtual_alias_maps = .*|virtual_alias_maps = hash:/etc/postfix/virtual|' /etc/postfix/main.cf
else
    echo "virtual_alias_maps = hash:/etc/postfix/virtual" >> /etc/postfix/main.cf
fi

if [[ $? -ne 0 ]]; then revert_changes "modificación de main.cf"; fi

echo "Creando el archivo de alias virtual para el reenvío de correos."
# Limpiar el archivo y construir el contenido dinámicamente
echo "# Redirección de usuarios específicos" > /etc/postfix/virtual
for alias_entry in "${USER_ALIASES[@]}"; do
    echo "$alias_entry" >> /etc/postfix/virtual
done
echo "" >> /etc/postfix/virtual
echo "# Redirección catch-all para dominios seleccionados" >> /etc/postfix/virtual
for domain in "${CATCHALL_DOMAINS[@]}"; do
    echo "@$domain          $ADMIN_EMAIL" >> /etc/postfix/virtual
done

if [[ $? -ne 0 ]]; then revert_changes "creación de /etc/postfix/virtual"; fi

echo "Generando la base de datos de alias de Postfix..."
postmap /etc/postfix/virtual
if [[ $? -ne 0 ]]; then revert_changes "generación de postmap"; fi

echo "Reiniciando el servicio Postfix..."
systemctl restart postfix
if [[ $? -ne 0 ]]; then revert_changes "reinicio de Postfix"; fi

# --- Paso 4: Instalación de PostfixAdmin ---
echo "Paso 4: Instalando PostfixAdmin..."
cd /var/www/html
if [ -d "postfixadmin" ]; then
    echo "El directorio postfixadmin ya existe. Se eliminará para una nueva instalación."
    rm -rf "postfixadmin"
fi
echo "Clonando el repositorio de PostfixAdmin..."
git clone https://github.com/postfixadmin/postfixadmin.git
if [[ $? -ne 0 ]]; then revert_changes "clonando el repositorio de PostfixAdmin"; fi

echo "Instalando Composer y dependencias de PostfixAdmin..."
cd "$POSTFIXADMIN_DIR"
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
if [[ $? -ne 0 ]]; then revert_changes "instalación de composer"; fi

# Ejecutar composer install usando la ruta completa
/usr/local/bin/composer install --no-dev
if [[ $? -ne 0 ]]; then revert_changes "ejecución de composer install"; fi

# --- Paso 5: Configuración de MariaDB y PostfixAdmin ---
echo "Paso 5: Configurando MariaDB y PostfixAdmin."
read -sp "Ingresa la contraseña para el nuevo usuario de la base de datos: " db_password
echo
DB_NAME="postfixadmin"
DB_USER="postfixadmin_user"
mysql -u root -e "DROP DATABASE IF EXISTS $DB_NAME; CREATE DATABASE $DB_NAME; DROP USER IF EXISTS '$DB_USER'@'localhost'; CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$db_password'; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost'; FLUSH PRIVILEGES;"
if [[ $? -ne 0 ]]; then revert_changes "configuración de MariaDB"; fi

read -sp "Ingresa la contraseña para la página de setup de PostfixAdmin: " setup_password
echo
if [[ -z "$setup_password" ]]; then
    echo "La contraseña de setup no puede estar vacía. Saliendo..."
    exit 1
fi
GENERATED_SETUP_HASH=$(php -r 'echo password_hash("'"$setup_password"'", PASSWORD_DEFAULT);')

echo "Configurando el archivo config.local.php de PostfixAdmin..."
# Crea el archivo de configuración con el contenido necesario en la ruta correcta.
tee "$POSTFIXADMIN_DIR/config.local.php" > /dev/null <<EOF
<?php
\$CONF['database_type'] = 'mysqli';
\$CONF['database_user'] = '$DB_USER';
\$CONF['database_password'] = '$db_password';
\$CONF['database_name'] = '$DB_NAME';
\$CONF['database_host'] = 'localhost';
\$CONF['encrypt'] = 'md5crypt';
\$CONF['setup_password'] = '$GENERATED_SETUP_HASH';
\$CONF['admin_email'] = '$ADMIN_EMAIL';
\$CONF['super_admins'] = array('$ADMIN_EMAIL', 'root', 'eduardo', 'admin');
\$CONF['configured'] = true;
?>
EOF
if [[ $? -ne 0 ]]; then revert_changes "creando el archivo config.local.php"; fi

# --- Se reubicó la configuración de permisos aquí ---
echo "Configurando permisos de archivos y SELinux..."
# Permisos para el usuario del servidor web (Apache)
chown -R apache:apache "$POSTFIXADMIN_DIR"
chmod -R 755 "$POSTFIXADMIN_DIR"
if [[ $? -ne 0 ]]; then revert_changes "configuración de permisos de archivos"; fi

# Permisos especiales para templates_c
echo "Configurando permisos para la carpeta templates_c..."
# Se crea la carpeta templates_c si no existe
if [ ! -d "$POSTFIXADMIN_DIR/templates_c" ]; then
    mkdir "$POSTFIXADMIN_DIR/templates_c"
fi
chown -R apache:apache "$POSTFIXADMIN_DIR/templates_c"
chmod -R 750 "$POSTFIXADMIN_DIR/templates_c"
if [[ $? -ne 0 ]]; then revert_changes "configuración de permisos para templates_c"; fi

# --- Paso 6: Configuración de SELinux para PostfixAdmin ---
echo "Paso 6: Configurando SELinux para el correcto funcionamiento de PostfixAdmin."

# --- Habilitar los booleanos de SELinux ---
echo "Habilitando booleanos de SELinux..."
semanage boolean -m --on httpd_can_network_connect
if [[ $? -ne 0 ]]; then revert_changes "configuración del booleano httpd_can_network_connect"; fi
semanage boolean -m --on httpd_can_network_connect_db
if [[ $? -ne 0 ]]; then revert_changes "configuración del booleano httpd_can_network_connect_db"; fi
semanage boolean -m --on httpd_can_sendmail
if [[ $? -ne 0 ]]; then revert_changes "configuración del booleano httpd_can_sendmail"; fi
semanage boolean -m --on httpd_unified
if [[ $? -ne 0 ]]; then revert_changes "configuración del booleano httpd_unified"; fi
semanage boolean -m --on nis_enabled
if [[ $? -ne 0 ]]; then revert_changes "configuración del booleano nis_enabled"; fi
semanage boolean -m --on virt_sandbox_use_all_caps
if [[ $? -ne 0 ]]; then revert_changes "configuración del booleano virt_sandbox_use_all_caps"; fi
semanage boolean -m --on virt_use_nfs
if [[ $? -ne 0 ]]; then revert_changes "configuración del booleano virt_use_nfs"; fi

# --- Configuración del contexto de archivos (fcontext) ---
echo "Configurando contextos de archivos (fcontext)..."
semanage fcontext -a -f a -t httpd_sys_content_t '/var/www/html/postfixadmin(/.*)?'
if [[ $? -ne 0 ]]; then revert_changes "configuración de fcontext para PostfixAdmin"; fi
semanage fcontext -a -f a -t httpd_sys_rw_content_t '/var/www/html/postfixadmin/templates_c(/.*)?'
if [[ $? -ne 0 ]]; then revert_changes "configuración de fcontext para plantillas"; fi
semanage fcontext -a -f a -t httpd_log_t '/var/log/php-fpm(/.*)?'
if [[ $? -ne 0 ]]; then revert_changes "configuración de fcontext para logs de PHP-FPM"; fi

# --- Aplicar el contexto de archivos ---
echo "Aplicando el contexto de archivos con restorecon..."
restorecon -Rv /var/www/html/postfixadmin
if [[ $? -ne 0 ]]; then revert_changes "aplicación de restorecon a PostfixAdmin"; fi
restorecon -Rv /var/log/php-fpm
if [[ $? -ne 0 ]]; then revert_changes "aplicación de restorecon a logs de PHP-FPM"; fi

# --- Paso 7: Verificación y finalización ---
echo "Paso 7: Verificación final."
echo "Reiniciando los servicios finales..."
systemctl restart httpd mariadb
if [[ $? -ne 0 ]]; then revert_changes "reinicio de servicios finales"; fi

echo "--------------------------------------------------------"
echo "¡Configuración completada! Para que los cambios surtan efecto, tu sistema debe ser reiniciado."
echo "Guarda la siguiente URL para continuar con el setup de PostfixAdmin después del reinicio:"
echo "Visita http://127.0.0.1/postfixadmin/public/setup.php"
echo ""
read -p "Opciones: [1] Reiniciar más tarde (salir) | [2] Reiniciar ahora: " RESTART_CHOICE

case "$RESTART_CHOICE" in
    1)
        echo "Reiniciando más tarde. El script ha terminado. Por favor, reinicia manualmente cuando estés listo."
        exit 0
        ;;
    2)
        echo "Reiniciando el sistema ahora. ¡Hasta pronto!"
        reboot
        ;;
    *)
        echo "Opción no válida. El script ha terminado. Por favor, reinicia manualmente cuando estés listo."
        exit 1
        ;;
esac

