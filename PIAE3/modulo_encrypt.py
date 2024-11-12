from cryptography.fernet import Fernet
import logging
import os
import hashlib
from datetime import datetime

"""
Este script proporciona funcionalidades para cifrar y descifrar archivos
utilizando la biblioteca 'cryptography' en Python. Se generan y almacenan
claves de cifrado, permitiendo proteger la información contenida en archivos.

Cada actividad de cifrado y descifrado genera un reporte en formato .txt que
incluye la fecha de ejecución, el nombre y la ubicación del archivo procesado,
y un hash SHA-256 del reporte, que se muestra en la terminal para verificación.

Funciones incluidas:
1. key_file(): Genera una nueva clave de cifrado y la guarda en un archivo
llamado 'clave.key'.
   - Se registra un mensaje de éxito o error en el registro y en la consola.

2. key_load(): Carga la clave de cifrado desde el archivo 'clave.key'.
   - Si el archivo no existe, se lanza un error.
   - Se registra un mensaje de éxito o error en el registro y en la consola.

3. encrypt_file(file_path): Cifra el archivo especificado por 'file_path'.
   - Comprueba si el archivo existe y, si es así, carga la clave de cifrado.
   - Guarda el archivo cifrado con la extensión '.enc'.
   - Genera un reporte en formato .txt que contiene la fecha de ejecución,
     el nombre y la ubicación del archivo cifrado, y el hash SHA-256 del reporte.
   - Se registran mensajes de éxito o error en el registro y en la consola.

4. decrypt_file(enc_file_path): Descifra el archivo cifrado especificado por
'enc_file_path'.
   - Comprueba si el archivo existe y, si es así, carga la clave de cifrado.
   - Guarda el archivo descifrado con la extensión '.dec' o '.decrypted'
     según corresponda.
   - Genera un reporte en formato .txt que contiene la fecha de ejecución,
     el nombre y la ubicación del archivo descifrado, y el hash SHA-256 del reporte.
   - Se registran mensajes de éxito o error en el registro y en la consola.

5. report(file_path, action): Genera un reporte de la actividad 
   realizada (cifrado o descifrado) en formato .txt. Calcula y registra el
   hash SHA-256 del reporte para integridad.

Manejo de Errores:
Se implementa manejo de excepciones para capturar y registrar errores comunes,
como archivos no encontrados o problemas al cargar la clave.

Requisitos:
- La biblioteca 'cryptography' debe estar instalada.
- Configurar un sistema de registro para capturar la información del proceso.
"""

def report(file_path, action):
   
    report_path = f"{file_path}_{action}_report.txt"
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
   
    with open(report_path, "w") as report_file:
        report_file.write(f"Tarea: {action.capitalize()}\n")
        report_file.write(f"Archivo procesado: {file_path}\n")
        report_file.write(f"Fecha de ejecución: {timestamp}\n")
    
    with open(report_path, "rb") as report_file:
        report_hash = hashlib.sha256(report_file.read()).hexdigest()

    with open(report_path, "a") as report_file:
        report_file.write(f"Hash del reporte: {report_hash}\n")

    logging.info(f"Reporte generado en: {report_path}")
    print(f"Tarea '{action.capitalize()}' ejecutada el {timestamp}.")
    print(f"Hash del reporte: {report_hash}")
    print(f"Ubicación del reporte: {os.path.abspath(report_path)}\n")
    return report_path, report_hash

def key_file():
   
    try:
        key = Fernet.generate_key()
        with open("clave.key", "wb") as file:
            file.write(key)
        logging.info("Clave generada y guardada en el archivo 'clave.key'.")
        print("Clave generada y guardada en el archivo 'clave.key'.")
       
    except Exception as e:
        logging.error(f"Error al generar la clave: {e}")
        print(f"Error al generar la clave: {e}")

def key_load():
   
    try:
        if not os.path.exists("clave.key"):
            raise FileNotFoundError("El archivo 'clave.key' no existe.")
        with open("clave.key", "rb") as file:
            key = file.read()
        logging.info("La clave se cargó exitosamente.")
        print("La clave se cargó exitosamente.")
        return key
       
    except FileNotFoundError as fnfe:
        logging.error(fnfe)
        print(fnfe)
    except Exception as e:
        logging.error(f"Error al cargar la clave: {e}")
        print(f"Error al cargar la clave: {e}")

def encrypt_file(file_path):
    try:
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"El archivo {file_path} no existe.")
        key = key_load()
        fernet_key = Fernet(key)
        with open(file_path, "rb") as file:
            data = file.read()
        enc_data = fernet_key.encrypt(data)
        enc_file_path = file_path + ".enc"
        with open(enc_file_path, "wb") as enc_file:
            enc_file.write(enc_data)
        logging.info(f"El archivo {file_path} ha sido cifrado exitosamente.")
        report_path, report_hash = generate_report(file_path, "cifrado")
       
    except FileNotFoundError as fnfe:
        logging.error(fnfe)
        print(fnfe)
    except Exception as e:
        logging.error(f"Error al cifrar el archivo: {e}")
        print(f"Error al cifrar el archivo: {e}")

def decrypt_file(enc_file_path):
   
    try:
        if not os.path.exists(enc_file_path):
            raise FileNotFoundError(f"El archivo {enc_file_path} no existe.")
        key = key_load()
        fernet_key = Fernet(key)
        with open(enc_file_path, "rb") as enc_file:
            enc_data = enc_file.read()
        dec_data = fernet_key.decrypt(enc_data)
        if enc_file_path.endswith(".encrypted"):
            dec_file_path = enc_file_path.replace(".encrypted", ".decrypted")
        elif enc_file_path.endswith(".enc"):
            dec_file_path = enc_file_path.replace(".enc", ".dec")
        else:
            raise ValueError("El archivo no tiene una extensión válida (.encrypted o .enc).")
        with open(dec_file_path, "wb") as dec_file:
            dec_file.write(dec_data)
        logging.info(f"El archivo {enc_file_path} fue descifrado exitosamente.")
        report_path, report_hash = report(enc_file_path, "descifrado")
       
    except FileNotFoundError as fnfe:
        logging.error(fnfe)
        print(fnfe)
    except Exception as e:
        logging.error(f"Error al descifrar el archivo: {e}")
        print(f"Error al descifrar el archivo: {e}")
        
