import socket

class InvalidIPAddressError(Exception):
    """Custom exception for invalid IP addresses."""
    pass


def validate_ip_address(ip_address):
    """
    Validates if the given IP address is in correct IPv4 format.

    :param ip_address: IP address to validate
    :raises InvalidIPAddressError: If the IP address is invalid
    :return: True if valid
    """
    try:
        socket.inet_aton(ip_address)
        return True
    except socket.error:
        raise InvalidIPAddressError(f"Invalid IP address format: {ip_address}")


def scan_port(ip_address, port):
    """
    Scan a specific port to check if it is open.

    :param ip_address: Target IP address
    :param port: Port number to scan
    :return: 'open' if the port is open, 'closed' otherwise
    """
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(1)  
    result = sock.connect_ex((ip_address, port))
    sock.close()
    return 'open' if result == 0 else 'closed'


def scan_ports(ip_address, start_port, end_port):
    """
    Scan a range of ports on the given IP address.

    :param ip_address: Target IP address
    :param start_port: Starting port in the range
    :param end_port: Ending port in the range
    :return: Dictionary of port states
    """
    try:
        # Validando la dirección IP.
        validate_ip_address(ip_address)

        print(f"Scanning ports from {start_port} to {end_port} on {ip_address}...")

        port_states = {}
        for port in range(start_port, end_port + 1):
            state = scan_port(ip_address, port)
            port_states[port] = state

        return port_states

    except InvalidIPAddressError as ip_err:
        print(f"Error: {ip_err}")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")


def save_report(report, filename="port_scan_report.txt"):
    """
    Saves the port scan report to a file.

    :param report: The port scan results
    :param filename: The name of the file to save the report
    :return: None
    """
    with open(filename, 'w') as file:
        for port, state in report.items():
            file.write(f"Port {port}: {state}\n")
    print(f"Report saved to {filename}")


def main():
    """
    Main function to handle user input and initiate the network scan.

    :return: None
    """
    try:
        ip_address = input("Enter the IP address to scan: ")
        start_port = int(input("Enter the starting port number: "))
        end_port = int(input("Enter the ending port number: "))

        port_states = scan_ports(ip_address, start_port, end_port)

        # Guarda los resultados en un archivo en lugar de imprimirlos en la terminal.
        if port_states:
            save_report(port_states)

    except ValueError:
        print("Invalid input. Please enter a valid number for port ranges.")
    except Exception as e:
        print(f"An unexpected error occurred: {e}")

def get_help():
    """
    Prints help information about how to use this script.

    :return: None
    """
    print("""
    This script scans a range of ports on a given IP address to check if they are open or closed.

    Usage:
        python port_scanner.py
    """)



if __name__ == "__main__":
    main()
