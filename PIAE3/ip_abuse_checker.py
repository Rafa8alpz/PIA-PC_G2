import requests
import re

class InvalidIPError(Exception):
    """Custom exception for invalid IP addresses."""
    pass

class APIError(Exception):
    """Custom exception for API-related errors."""
    pass

def validate_ip(ip_address):
    """
    Validate if the provided IP address is in the correct format (IPv4).

    :param ip_address: IP address to validate
    :raises InvalidIPError: If IP is not valid
    :return: True if IP is valid
    """
    ip_pattern = re.compile(r"^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$")
    if not ip_pattern.match(ip_address):
        raise InvalidIPError(f"Invalid IP address: {ip_address}")
    return True

def get_ip_abuse_data(ip_address):
    """
    Query the IP Abuse Database API for data on the provided IP address.

    :param ip_address: The IP address to check
    :return: Dictionary containing IP abuse data
    :raises APIError: If the API request fails
    """
    api_key = "eb926b903c9ffcc6a945401ea9c8f4f168cdd816b9607b22a2a595da528f1b46a08c29e38c0b3ee6"
    url = f"https://api.abuseipdb.com/api/v2/check"
    headers = {
        'Accept': 'application/json',
        'Key': api_key
    }
    params = {
        'ipAddress': ip_address,
        'maxAgeInDays': 90  # Limit data to the last 90 days
    }

    try:
        response = requests.get(url, headers=headers, params=params)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        raise APIError(f"API request failed: {e}")

def save_report(ip_address, abuse_data, filename="report.txt"):
    """
    Save the abuse data report to a specified file.

    :param ip_address: The IP address checked
    :param abuse_data: Data containing IP abuse information
    :param filename: File to save the report
    :return: None
    """
    try:
        with open(filename, 'w') as file:
            confidence_score = abuse_data['data']['abuseConfidenceScore']
            last_reported = abuse_data['data']['lastReportedAt']
            file.write(f"IP Address: {ip_address}\n")
            file.write(f"Abuse Confidence Score: {confidence_score}\n")
            file.write(f"Last Reported: {last_reported}\n")

            if confidence_score > 0:
                file.write(f"Warning: IP {ip_address} is potentially malicious.\n")
            else:
                file.write(f"IP {ip_address} appears to be clean.\n")

        print(f"Report saved in {filename}")

    except IOError as e:
        print(f"Error saving report: {e}")

def check_ip_abuse(ip_address):
    """
    Main function to validate the IP address and retrieve its abuse data.
    Saves the data to a report file instead of printing to terminal.

    :param ip_address: The IP address to check
    :return: None
    """
    try:
        # Validar el formato de la dirección IP
        validate_ip(ip_address)

        # Obtener datos de abuso de IP
        abuse_data = get_ip_abuse_data(ip_address)

        # Guardar el informe en un archivo
        save_report(ip_address, abuse_data, filename="ip_abuse_report.txt")

    except InvalidIPError as ip_err:
        print(f"Error: {ip_err}")
    except APIError as api_err:
        print(f"Error: {api_err}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

# Get-Help: Verificar el Script de Reporte de Check Abuse IP
# SYNOPSIS
#   Este script verifica una dirección IP en la API de la base de datos de abuso de IP y guarda un informe en un archivo de texto.
#
# SYNTAX
#   Ejecuta el script ingresando una dirección IP cuando se te solicite.
#
# PARAMETERS
#  ip_address : str - Dirección IP que se verificará por abuso.
#
# EXAMPLE
#   Ingresa una dirección IP, por ejemplo, 192.168.0.1, para recuperar y guardar el informe de abuso en 'ip_abuse_report.txt'.
#
# OUTPUT
#   Un archivo de texto llamado 'ip_abuse_report.txt' que contiene detalles sobre el abuso de IP.

if __name__ == '__main__':
    ip_address = input("Enter the IP address to check: ")
    check_ip_abuse(ip_address)
