EASYMAILTOTAL beta 1.0

Web Oficial: La única web oficial para EASYMAILTOTAL es: https://github.com/eduayaqq/easymail.git NO DESCARGUE DE NINGUNA OTRA FUENTE.

Official Website: The only official website for EASYMAILTOTAL is: https://github.com/eduayaqq/easymail.git DO NOT DOWNLOAD FROM ANY OTHER SOURCE.

🚀 Postfix, Dovecot & PostfixAdmin Setup Script for CentOS 10

✅ ENGLISH ON BOTTOM

Este README está disponible en español e inglés. A continuación, se encuentra la versión en español, seguida de la versión en inglés.

💻 Resumen del Proyecto

Este script interactivo de Bash automatiza la instalación y configuración de un servidor de correo completo utilizando Postfix, Dovecot y PostfixAdmin en una distribución CentOS 10. Simplifica un proceso complejo, desde la instalación de dependencias hasta la configuración de la base de datos y la seguridad SELinux, permitiéndote tener un servidor de correo funcional en poco tiempo.

✅ Características principales

    Instalación interactiva: Te guía paso a paso a través de la configuración de dominios, usuarios y contraseñas.

    Configuración de software: Instala y configura Postfix, Dovecot, Apache, MariaDB y PHP.

    Gestión de correo virtual: Configura Postfix para manejar múltiples dominios y usuarios virtuales.

    Interfaz web: Instala PostfixAdmin para una administración de correo sencilla a través de una interfaz web.

    Seguridad avanzada: Configura SELinux para asegurar que todos los servicios funcionen correctamente sin comprometer la seguridad del sistema.


📝 Funcionamiento del Script

El script te guiará a través de los siguientes pasos:

    Verificación de permisos: Asegura que el script se ejecute como root.

    Configuración de hostname: Te permite definir el hostname de tu servidor.

    Definición de dominios: Solicitá ingresar uno o más dominios de correo electrónico.

    Configuración de usuarios: Te permite crear usuarios de correo y definir una dirección de correo principal para la administración y reenvío.

    Instalación y configuración: Descarga e instala todas las dependencias, configura los servicios de correo y la base de datos MariaDB.

    Configuración de PostfixAdmin: Clona el repositorio de PostfixAdmin y lo configura con los datos de tu base de datos.

    Seguridad SELinux: Configura las reglas necesarias para SELinux, permitiendo que PostfixAdmin funcione correctamente.

⚠️ Advertencias, Términos y Condiciones de Uso

Por favor, lea atentamente antes de ejecutar este script.

    Este script solo ha sido probado en la distribución CentOS 10 de Red Hat. Úselo bajo su propia responsabilidad.

    No garantiza su ejecución en otra distribución que no sea CentOS 10, ni en una instalación que no sea limpia. Se solicita una instalación limpia por motivos de posible incompatibilidad en repositorios o reglas de seguridad ya implementadas.

    Requiere ejecución como root. Úselo bajo su propia responsabilidad.

    Este script usa root para ejecuciones no maliciosas, utilizando software libre que no es seguido por el desarrollador. Tome sus precauciones.

    Código Abierto: Descargue únicamente desde este repositorio de GitHub. No confíe en páginas externas que no sean de GitHub o de la web oficial del desarrollador.

    Gratuito para uso personal y no comercial: Este script NO ES DE PAGO. Si le vendieron este script, NO LO EJECUTE BAJO NINGÚN MOTIVO.

    Código no ofuscado: Si usted no puede ver el código fuente, NO LO EJECUTE BAJO NINGÚN MOTIVO.

    Uso comercial: Este script NO ESTÁ HECHO PARA EMPRESAS NI CON FINES COMERCIALES. Si es una empresa, pertenece a una o utilizará el script con fines comerciales, contacte al desarrollador para obtener una licencia comercial (con un costo de $100 dólares americanos).

    PROHIBIDO SU USO COMERCIAL SIN PERMISO POR ESCRITO DEL DESARROLLADOR.

    El desarrollador se reserva el derecho de exigir remuneración económica en caso de detectar fines de lucro de este script.

    Reglas de seguridad: Este script permitirá el paso a aplicaciones de terceros a través de las reglas de seguridad de su distribución. Úselo con precaución y bajo su responsabilidad.

    Limitación de responsabilidad: El creador no se hace responsable por fallas en este script, errores o repositorios de terceros deshabilitados, inexistentes, desactualizados y/o sin soporte.

    Acuerdo de uso: Al usar este script, usted reconoce haber leído en su totalidad estas indicaciones, advertencias y términos de uso.

    Contacto oficial: Para fines comerciales o modificaciones, el único contacto oficial es: eduayaqq14@gmail.com (Eduardo Ayala). La alteración o manipulación de este contenido está prohibida sin el contacto del desarrollador original. La descarga de este código modificado por un tercero no exime de las responsabilidades aquí mencionadas.

    Web Oficial: La única web oficial para EASYMAILTOTAL es: https://github.com/eduayaqq/easymail NO DESCARGUE DE NINGUNA OTRA FUENTE.

💻 USO:

    sudo ./easymail.sh

✅ Y solo siga instrucciones.

🇬🇧 Postfix, Dovecot & PostfixAdmin Setup Script for CentOS 10

💻 Project Overview

This interactive Bash script automates the installation and configuration of a complete email server using Postfix, Dovecot, and PostfixAdmin on a CentOS 10 distribution. It simplifies a complex process, from dependency installation to database configuration and SELinux security, allowing you to have a functional email server up and running in no time.
✅ Key Features

    Interactive Installation: Guides you step-by-step through the setup of domains, users, and passwords.

    Software Configuration: Installs and configures Postfix, Dovecot, Apache, MariaDB, and PHP.

    Virtual Mail Management: Configures Postfix to handle multiple virtual domains and users.

    Web Interface: Installs PostfixAdmin for easy email administration via a web interface.

    Advanced Security: Sets up SELinux to ensure all services run correctly without compromising system security.

    Automatic Reboot: Offers the option to reboot the system upon completion to apply all configuration changes.

📝 How the Script Works

The script will walk you through the following steps:

    Permission Check: Ensures the script is run as root.

    Hostname Configuration: Allows you to define your server's hostname.

    Domain Definition: Prompts you to enter one or more email domains.

    User Setup: Lets you create email users and define a main email address for administration and forwarding.

    Installation and Configuration: Downloads and installs all dependencies, configures email services and the MariaDB database.

    PostfixAdmin Setup: Clones the PostfixAdmin repository and configures it with your database details.

    SELinux Security: Sets up the necessary SELinux rules, allowing PostfixAdmin to function correctly.

⚠️ Warnings, Terms, and Conditions of Use

Please read carefully before running this script.

    This script has only been tested on the CentOS 10 distribution of Red Hat. Use it at your own risk.

    It does not guarantee its execution on any distribution other than CentOS 10, nor on a non-clean installation. A clean installation is requested due to possible incompatibility with existing repositories or security rules.

    Requires root execution. Use it at your own risk.

    This script uses root for non-malicious executions, utilizing free software that is not maintained by the developer. Exercise caution.

    Open Source: Download only from this GitHub repository. Do not trust external pages that are not from GitHub or the official developer's website.

    Free for personal and non-commercial use: This script is NOT FOR SALE. If this script was sold to you, DO NOT RUN IT UNDER ANY CIRCUMSTANCES.

    Unobfuscated code: If you cannot see the source code, DO NOT RUN IT UNDER ANY CIRCUMSTANCES.

    Commercial Use: This script is NOT MADE FOR COMPANIES OR FOR COMMERCIAL PURPOSES. If you are a company, belong to one, or will use the script for commercial purposes, please contact the developer to obtain a commercial license for this script (at a cost of $100 US dollars).

    COMMERCIAL USE IS PROHIBITED WITHOUT WRITTEN PERMISSION FROM THE DEVELOPER.

    The developer reserves the right to demand economic compensation if any profit-making use of this script is detected.

    Security Rules: This script will allow third-party applications to pass through your distribution's security rules. Use it with caution and at your own risk.

    Disclaimer of Liability: The creator is not responsible for failures in this script, errors, or disabled, nonexistent, outdated, and/or unsupported third-party repositories.

    Terms of Agreement: By using this script, you acknowledge that you have fully read these instructions, warnings, and terms of use.

    Official Contact: For commercial purposes or modifications, the only official contact is: eduayaqq14@gmail.com (Eduardo Ayala). The alteration or manipulation of this content is prohibited without contact with the original developer. Downloading this code modified by a third party does not exempt you from the responsibilities mentioned herein.

    Official Website: The only official website for EASYMAILTOTAL is: https://github.com/eduayaqq/easymail DO NOT DOWNLOAD FROM ANY OTHER SOURCE.

💻 USE:

    sudo ./easymail.sh

✅ And only follow instructions.
