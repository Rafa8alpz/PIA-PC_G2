import shodan
import logging
import re
import csv

# Definir tu clave API de Shodan
SHODAN_API_KEY = 'IYOp1l2Ytx17Vze10anvLj5NqoOUY7pR'


# Función para validar direcciones IP
def validate_ip(ip_address):
    """Valida si la entrada es una dirección IP válida."""
    ip_pattern = re.compile(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$')
    if ip_pattern.match(ip_address):
        return True
    else:
        logging.error(f"Invalid IP address format: {ip_address}")
        return False


# Función para realizar la búsqueda en Shodan (limitada a 1 página de resultados por cuenta gratuita)
def search_shodan(query, report_path="ShodanSearchReport.csv"):
    """Busca dispositivos conectados en Shodan usando una query (limitada por cuenta gratuita)."""
    try:
        api = shodan.Shodan(SHODAN_API_KEY)
        logging.info(f"Shodan search initiated with query: {query}")
        
        # Realizar la búsqueda con el límite de resultados por cuenta gratuita
        results = api.search(query, limit=100)
        
        # Generar reporte CSV
        with open(report_path, mode='w', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            writer.writerow(["IP", "Organization", "OS"])  # Cabeceras

            for result in results['matches']:
                ip = result['ip_str']
                org = result.get('org', 'Unknown')
                os = result.get('os', 'Unknown')
                writer.writerow([ip, org, os])
                logging.info(f"Device found: IP: {ip}, Organization: {org}, OS: {os}")
        
        logging.info(f"Report generated at {report_path}")
        print(f"Report generated at {report_path}")
        return results
    
    except shodan.APIError as e:
        logging.error(f"Shodan API error: {e}")
        raise
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        raise


# Función para obtener información sobre una IP específica
def get_ip_info(ip_address, report_path="ShodanIPInfoReport.csv"):
    """Obtiene información básica sobre una dirección IP específica usando la API de Shodan."""
    if not validate_ip(ip_address):
        raise ValueError("Invalid IP address format")
    
    try:
        api = shodan.Shodan(SHODAN_API_KEY)
        logging.info(f"Getting info for IP address: {ip_address}")
        
        # Obtener información de la IP (limitado en cuenta gratuita)
        host_info = api.host(ip_address)
        
        # Generar reporte CSV
        with open(report_path, mode='w', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            writer.writerow(["IP", "Organization", "Operating System", "Ports"])  # Cabeceras
            writer.writerow([
                host_info['ip_str'],
                host_info.get('org', 'Unknown'),
                host_info.get('os', 'Unknown'),
                host_info['ports']
            ])
        
        logging.info(f"IP info report generated at {report_path}")
        print(f"IP info report generated at {report_path}")
        return host_info
    
    except shodan.APIError as e:
        logging.error(f"Shodan API error: {e}")
        raise
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        raise


if __name__ == "__main__":
    try:
        # Ejemplo de uso: búsqueda con una query limitada
        query = "apache"
        search_shodan(query)

        # Ejemplo de uso: obtener información sobre una IP
        ip = "187.195.139.72"
        get_ip_info(ip)

    except Exception as e:
        logging.error(f"Error occurred during script execution: {e}")
