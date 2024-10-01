#!/bin/bash

#Funcion para escaneo de puertoss
function scan_ports() {
    local host=$1
    local start_port=$2
    local end_port=$3

    echo "Escaneando puertos del $start_port al $end_port en $host..."

    for ((port=$start_port; port<=$end_port; port++))
    do
        nc -zv $host $port &> /dev/null
        if [ $? -eq 0 ]; then
            echo "Puerto $port esta abierto en $host"
        else
            echo "Puerto $port esta cerrado en $host"
        fi
    done
}

#Funcion para escaneo rápido en los puertos más comunes
function quick_scan() {
    local host=$1
    local common_ports=(21 22 23 25 53 80 110 143 443 445 3389)
    local file="escaneo_rapido_reporte_$(date +%Y%m%d%H%M%S).txt"

    echo "Realizando escaneo rápido en puertos comunes en $host..."
    echo "Generando reporte en $file..."

    for port in "${common_ports[@]}"
    do
        nc -zv $host $port &> /dev/null
        if [ $? -eq 0 ]; then
            echo "Puerto $port esta abierto en $host" | tee -a $file
        else
            echo "Puerto $port esta cerrado en $host" | tee -a $file
        fi
    done

    echo "Reporte de escaneo rapido generado: $file"
}

#Funcion para generar un reporte del escaneo
function generate_report() {
    local host=$1
    local start_port=$2
    local end_port=$3
    local file="scan_report_$(date +%Y%m%d%H%M%S).txt"

    echo "Generando reporte en $file..."
    scan_ports $host $start_port $end_port > $file
    echo "Reporte generado: $file"
}

#Menu
function show_menu() {
    echo "1.Realizar escaneo de puertos"
    echo "2.Generar reporte del escaneo"
    echo "3.Realizar escaneo rápido y reporte"
    echo "4.Salir"
}

#Programa Principal
while true; do
    show_menu
    read -p "Elija una opcion: " option

    case $option in
        1)
            read -p "Ingrese la IP o dominio del host: " host
            read -p "Ingrese el puerto inicial: " start_port
            read -p "Ingrese el puerto final: " end_port
            if [[ ! $start_port =~ ^[0-9]+$ ]] || [[ ! $end_port =~ ^[0-9]+$ ]]; then
                echo "Error: Los puertos deben ser números."
                continue
            fi
            scan_ports $host $start_port $end_port
            ;;
        2)
            if [[ -z $host || -z $start_port || -z $end_port ]]; then
                echo "Error: No hay datos de escaneo previos para generar el reporte."
                continue
            fi
            generate_report $host $start_port $end_port
            ;;
        3)
            read -p "Ingrese la IP o dominio del host: " host
            quick_scan $host
            ;;
        4)
            echo "Saliendo del programa..."
            break
            ;;
        *)
            echo "Opción no válida. Intente de nuevo."
            ;;
    esac
done