import shodan
import logging
import re


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
def search_shodan(query):
    """Busca dispositivos conectados en Shodan usando una query (limitada por cuenta gratuita)."""
    try:
        api = shodan.Shodan(SHODAN_API_KEY)
        logging.info(f"Shodan search initiated with query: {query}")
        
        # Realizar la búsqueda con el límite de resultados por cuenta gratuita
        results = api.search(query, limit=100)
        
        # Procesar y mostrar los resultados
        logging.info(f"Search returned {len(results['matches'])} results (limited by free account)")
        for result in results['matches']:
            ip = result['ip_str']
            org = result.get('org', 'Unknown')
            os = result.get('os', 'Unknown')
            print(f"IP: {ip}, Organization: {org}, OS: {os}")
            logging.info(f"Device found: IP: {ip}, Organization: {org}, OS: {os}")
        return results
    
    except shodan.APIError as e:
        logging.error(f"Shodan API error: {e}")
        raise
    except Exception as e:
        logging.error(f"Unexpected error: {e}")
        raise


# Función para obtener información sobre una IP específica
def get_ip_info(ip_address):
    """Obtiene información básica sobre una dirección IP específica usando la API de Shodan."""
    if not validate_ip(ip_address):
        raise ValueError("Invalid IP address format")
    
    try:
        api = shodan.Shodan(SHODAN_API_KEY)
        logging.info(f"Getting info for IP address: {ip_address}")
        
        # Obtener información de la IP (limitado en cuenta gratuita)
        host_info = api.host(ip_address)
        
        # Mostrar la información
        print(f"IP: {host_info['ip_str']}")
        print(f"Organization: {host_info.get('org', 'Unknown')}")
        print(f"Operating System: {host_info.get('os', 'Unknown')}")
        print(f"Ports: {host_info['ports']}")
        logging.info(f"IP info: {host_info}")
        
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
