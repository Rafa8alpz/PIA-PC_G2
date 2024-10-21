import logging
from modulo_encrypt import encrypt_file, decrypt_file, key_file
from ip_abuse_checker import check_ip_abuse
from cybersec import search_shodan
from monitor_hashing import monitor_directory
from port_scanner import scan_ports


logging.basicConfig(filename='script_principal.log',
                    level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s'
)

def menu():
    """Muestra el menú principal y maneja las selecciones del usuario."""
    while True:
        print("------------------------------------")
        print("           Menú Principal           ")
        print("------------------------------------")
        print("1. Buscar dispositivos en Shodan")
        print("2. Monitorear un directorio")
        print("3. Consultar datos de abuso de IP")
        print("4. Escanear puertos de una IP")
        print("5. Cifrar un archivo")
        print("6. Descifrar un archivo")
        print("7. Salir")
        print("------------------------------------")
        option = input("Selecciona una opción: ")
        print("------------------------------------")
        try:
            if option == '1':
                query = input("Introduce la consulta para buscar en Shodan: ")
                search_shodan(query)

            elif option == '2':
                directory = input("Introduce la ruta del directorio a monitorear: ")
                monitor_directory(directory)

            elif option == '3':
                ip_address = input("Introduce la dirección IP a consultar: ")
                check_ip_abuse(ip_address)

            elif option == '4':
                ip_address = input("Introduce la dirección IP a escanear: ")
                start_port = int(input("Introduce el puerto inicial: "))
                end_port = int(input("Introduce el puerto final: "))
                port_states = scan_ports(ip_address, start_port, end_port)
                for port, state in port_states.items():
                    print(f"Puerto {port}: {state}")

            elif option == '5':
                file_path = input("Introduce la ruta del archivo a cifrar: ")
                encrypt_file(file_path)

            elif option == '6':
                enc_file_path = input("Introduce la ruta del archivo cifrado a descifrar: ")
                decrypt_file(enc_file_path)

            elif option == '7':
                logging.info("El usuario ha salido del programa.")
                print("Saliendo del programa...")
                break

            else:
                print("Opción no válida. Por favor, intenta nuevamente.")

            
            continue_option = input("¿Deseas volver al menú principal? (s/n): ").lower()
            if continue_option != 's':
                logging.info("El usuario ha salido del programa.")
                print("Saliendo del programa...")
                break

        except Exception as e:
            logging.error(f"Error en la opción seleccionada: {e}")
            print(f"Ocurrió un error: {e}")

if __name__ == "__main__":
    menu()
