# AirPrint Server Docs

## Overview

The AirPrint Server addon provides AirPrint functionality to Home Assistant by running a CUPS (Common Unix Printing System) server with Avahi for service discovery. This allows Apple devices to discover and print to printers connected to your Home Assistant system.

## Features

- AirPrint support for iOS and macOS devices
- CUPS web interface for printer management
- SSL/TLS encryption support
- User authentication
- Avahi service discovery
- Nginx reverse proxy for web access
- Custom package installation
- Comprehensive logging options

## Installation

1. Add the repository to Home Assistant:

    [![Open your Home Assistant instance and show the add add-on repository dialog with a specific repository URL pre-filled.](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Frsperry79%2Fhomeassistant-airprint)

2. Install the "AirPrint Server" addon from the addon store.

3. Configure the addon options as needed.

4. Start the addon.

## Configuration

### Logins

Configure user accounts for accessing the CUPS web interface:

```yaml
LOGINS:
  - USERNAME: print
    PASSWORD: "print"
    USER_LEVEL: superuser
```

- `USERNAME`: The username for login
- `PASSWORD`: The password for login
- `USER_LEVEL`: User permission level (standard, admin, superuser)

### Avahi Settings

Configure Avahi (Bonjour) service discovery:

```yaml
AVAHI_SETTINGS:
  AVAHI_DEBUG: false
  AVAHI_REFLECTOR: false
  AVAHI_REFLECTOR_IPV: false
  AVAHI_USE_IPV6: false
```

- `AVAHI_DEBUG`: Enable debug logging for Avahi
- `AVAHI_REFLECTOR`: Enable reflector mode
- `AVAHI_REFLECTOR_IPV`: Enable IPv4 reflector
- `AVAHI_USE_IPV6`: Enable IPv6 support

### CUPS Settings

Configure CUPS encryption:

```yaml
CUPS_SETTINGS:
  CUPS_ENCRYPTION: IfRequested
```

- `CUPS_ENCRYPTION`: Encryption level (IfRequested, Required, Never)

### Custom Packages

Install additional packages:

```yaml
CUSTOM_PACKAGES:
  RUN_CUSTOM_INST_SCRIPT: false
  INSTALL_RECOMMENDS: false
  PACKAGES:
    - package1
    - package2
  PACKAGE_DEBUG: false
```

- `RUN_CUSTOM_INST_SCRIPT`: Run custom installation script
- `INSTALL_RECOMMENDS`: Install recommended packages
- `PACKAGES`: List of packages to install
- `PACKAGE_DEBUG`: Enable debug output for package installation

### CUPS Logging

Configure CUPS logging:

```yaml
CUPS_LOGGING:
  CUPS_FATAL_ERROR_LEVEL: none
  CUPS_LOG_TO_FILE: false
  CUPS_LOG_LEVEL: info
  CUPS_ACCESS_LOG_TO_FILE: false
  CUPS_ACCESS_LOG_LEVEL: all
```

- `CUPS_FATAL_ERROR_LEVEL`: Fatal error level
- `CUPS_LOG_TO_FILE`: Log to file instead of syslog
- `CUPS_LOG_LEVEL`: General log level
- `CUPS_ACCESS_LOG_TO_FILE`: Access log to file
- `CUPS_ACCESS_LOG_LEVEL`: Access log level

### Nginx Logging

Configure Nginx logging:

```yaml
NGINX_LOGGING:
  NGINX_ERROR_LOG_TO_FILE: false
  NGINX_ACCESS_LOG_TO_FILE: false
  NGINX_LOG_LEVEL: error
```

- `NGINX_ERROR_LOG_TO_FILE`: Error log to file
- `NGINX_ACCESS_LOG_TO_FILE`: Access log to file
- `NGINX_LOG_LEVEL`: Log level

## Usage

1. After starting the addon, printers connected to your system should be automatically detected.

2. Access the CUPS web interface at `http://your-ha-ip:631` or through the Home Assistant sidebar.

3. Use AirPrint from your Apple devices on the same network.

## Ports

- 631/tcp: CUPS web interface and IPP
- 631/udp: CUPS UDP
- 5353/udp: Avahi (mDNS)

## Troubleshooting

### Printer Not Detected

- Ensure the printer is properly connected and powered on.
- Check CUPS logs for errors.
- Verify network connectivity.
- Ensure you have the driver package installed

### SSL Issues

- Check SSL certificate configuration.
- Ensure proper permissions on certificate files.
- Review CUPS encryption settings.

### Authentication Problems

- Verify login credentials in the configuration.
- Check user levels for required permissions.

### Logs

Logs can be found in the addon logs or configured log files. Enable debug logging for more detailed information.

## Code Structure

The addon consists of several components:

- `entry.sh`: Main entry point script
- `src/cups/`: CUPS configuration and helper scripts
- `src/common/`: Shared utilities and settings
- `src/avahi/`: Avahi configuration
- `src/nginx/`: Nginx configuration
- `services/`: System service definitions
- `templates/`: Configuration templates

Key functions in `cups-ssl-helpers.sh`:

- `load_sources()`: Loads required source files
- `setup_ssl()`: Configures SSL/TLS for CUPS
- `setup_ssl_private()`: Sets up private SSL key
- `setup_ssl_public()`: Sets up public SSL certificate
- `convert_private_key()`: Converts private key format
- `convert_public_key()`: Converts public certificate format

## Contributing

Contributions are welcome. Please submit issues and pull requests to the GitHub repository.
