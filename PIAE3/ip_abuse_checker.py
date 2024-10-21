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

def check_ip_abuse(ip_address):
    """
    Main function to validate the IP address and retrieve its abuse data.

    :param ip_address: The IP address to check
    :return: None
    """
    try:
        # Validate IP address format
        validate_ip(ip_address)

        # Fetch IP abuse data
        abuse_data = get_ip_abuse_data(ip_address)

        # Check abuse confidence score and print results
        confidence_score = abuse_data['data']['abuseConfidenceScore']
        last_reported = abuse_data['data']['lastReportedAt']

        print(f"IP Address: {ip_address}")
        print(f"Abuse Confidence Score: {confidence_score}")
        print(f"Last Reported: {last_reported}")

        if confidence_score > 0:
            print(f"Warning: IP {ip_address} is potentially malicious.")
        else:
            print(f"IP {ip_address} appears to be clean.")

    except InvalidIPError as ip_err:
        print(f"Error: {ip_err}")
    except APIError as api_err:
        print(f"Error: {api_err}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

if __name__ == '__main__':
    ip_address = input("Enter the IP address to check: ")
    check_ip_abuse(ip_address)