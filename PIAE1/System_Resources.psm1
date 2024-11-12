Set-StrictMode -Version Latest
Import-Module BitsTransfer 

<#
.SYNOPSIS
Genera un reporte en formato .txt y muestra información sobre el archivo generado.
.DESCRIPTION
La función `Generate-Report` guarda el contenido de un reporte en un archivo de texto, genera el hash del archivo 
y muestra en la terminal la fecha de ejecución, el hash y la ubicación del archivo.
.PARAMETER Content
El contenido que se guardará en el archivo de reporte.
.PARAMETER ReportName
El nombre base del archivo de reporte.
.EXAMPLE
Generate-Report -Content "Datos del sistema" -ReportName "SystemInfo_Report"
Este comando generará un archivo llamado `SystemInfo_Report_<timestamp>.txt` con el contenido especificado.
#>
function Generate-Report {
    param (
        [string]$Content,
        [string]$ReportName
    )

    $Timestamp = (Get-Date -Format "yyyy-MM-dd_HH-mm-ss")
    $ReportPath = "$PSScriptRoot\$ReportName`_$Timestamp.txt"
    $Content | Out-File -FilePath $ReportPath -Encoding UTF8

    # Generar el hash del archivo (usando SHA256 como ejemplo)
    $Hash = Get-FileHash -Path $ReportPath -Algorithm SHA256 | Select-Object -ExpandProperty Hash

    Write-Host "La tarea $ReportName se ejecutó en la fecha $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')."
    Write-Host "Hash del reporte: $Hash"
    Write-Host "Nombre y ubicación del archivo: $ReportPath"
}

<#
.SYNOPSIS
Obtiene el uso del disco en gigabytes.
.DESCRIPTION
La función `DiskInfo` obtiene una lista de todas las unidades de disco conectadas y muestra información detallada 
sobre el espacio total, el espacio utilizado y el espacio libre, todo en gigabytes (GB).
.EXAMPLE
DiskInfo
Este comando generará un reporte con el espacio total, utilizado y libre para cada unidad de disco del sistema.
#>
function DiskInfo {
    try {
        $Drives = Get-PSDrive -PSProvider FileSystem
        $DiskReport = "Datos de Disco:`n"
        foreach ($Drive in $Drives) {
            $UsedSpace = ($Drive.Used / 1GB)
            $FreeSpace = ($Drive.Free / 1GB)
            $TotalSpace = $UsedSpace + $FreeSpace

            $DiskReport += "Unidad $($Drive.Name):`n"
            $DiskReport += "  Espacio total: $([math]::round($TotalSpace, 3)) GB`n"
            $DiskReport += "  Espacio usado: $([math]::round($UsedSpace, 3)) GB`n"
            $DiskReport += "  Espacio libre: $([math]::round($FreeSpace, 3)) GB`n`n"
        }
        Generate-Report -Content $DiskReport -ReportName "DiskInfo_Report"
    } catch {
        Write-Error "Error al obtener el uso del disco: $_"
    }
}

<#
.SYNOPSIS
Muestra el uso de la memoria física en megabytes.
.DESCRIPTION
La función `MemoryInfo` proporciona información detallada sobre la memoria física total del sistema, la cantidad 
de memoria en uso y la memoria libre en megabytes (MB).
.EXAMPLE
MemoryInfo
Este comando generará un reporte con la memoria total, la memoria usada y la memoria libre en megabytes.
#>
function MemoryInfo {
    try {
        $Total = (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1KB
        $Free = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1KB
        $MemoryUsage = $Total - $Free

        $MemoryReport = "Datos de Memoria:`n"
        $MemoryReport += "Memoria total: $([math]::Round($Total, 3)) MB`n"
        $MemoryReport += "Memoria usada: $([math]::Round($MemoryUsage, 3)) MB`n"
        $MemoryReport += "Memoria libre: $([math]::Round($Free, 3)) MB`n"

        Generate-Report -Content $MemoryReport -ReportName "MemoryInfo_Report"
    } catch {
        Write-Error "Error al obtener el uso de memoria: $_"
    }
}

<#
.SYNOPSIS
Proporciona detalles del procesador del sistema.
.DESCRIPTION
La función `CPUInfo` muestra información clave del procesador, como el nombre, el número de núcleos, 
la velocidad actual del reloj en MHz y el porcentaje de uso del procesador.
.EXAMPLE
CPUInfo
Este comando generará un reporte con el nombre del procesador, el número de núcleos y el uso actual en porcentaje.
#>
function CPUInfo {
    try {
        $CPUReport = "Datos del CPU:`n"
        $CPUInfo = Get-CimInstance -ClassName Win32_Processor
        foreach ($CPU in $CPUInfo) {
            $CPUReport += "Nombre del procesador: $($CPU.Name)`n"
            $CPUReport += "Número de núcleos: $($CPU.NumberOfCores)`n"
            $CPUReport += "Velocidad actual: $($CPU.CurrentClockSpeed) MHz`n"
            $CPUReport += "Uso actual de CPU: $($CPU.LoadPercentage)%`n`n"
        }
        Generate-Report -Content $CPUReport -ReportName "CPUInfo_Report"
    } catch {
        Write-Error "Error al obtener la información de la CPU: $_"
    }
}

<#
.SYNOPSIS
Muestra el tráfico de red en kilobytes por segundo.
.DESCRIPTION
La función `NetworkInfo` muestra el tráfico de red en tiempo real, proporcionando detalles sobre 
los bytes enviados, recibidos y el total de bytes procesados por cada interfaz de red en el sistema.
.EXAMPLE
NetworkInfo
Este comando generará un reporte con el tráfico de red actual en KB/s para cada interfaz de red activa.
#>
function NetworkInfo {
    try {
        $NetworkReport = "Datos del uso de la red:`n"
        $Network = Get-CimInstance -ClassName Win32_PerfFormattedData_Tcpip_NetworkInterface
        foreach ($Interface in $Network) {
            $NetworkReport += "Interfaz: $($Interface.Name)`n"
            $NetworkReport += "  Bytes enviados por segundo: $([math]::round($Interface.BytesSentPersec / 1KB, 3)) KB/s`n"
            $NetworkReport += "  Bytes recibidos por segundo: $([math]::round($Interface.BytesReceivedPersec / 1KB, 3)) KB/s`n"
            $NetworkReport += "  Bytes totales por segundo: $([math]::round($Interface.BytesTotalPersec / 1KB, 3)) KB/s`n`n"
        }
        Generate-Report -Content $NetworkReport -ReportName "NetworkInfo_Report"
    } catch {
        Write-Error "Error al obtener el uso de la red: $_"
    }
}

<#
.SYNOPSIS
Consolida y muestra todos los datos de recursos del sistema.
.DESCRIPTION
La función `SystemResourceData` ejecuta las funciones `DiskInfo`, `MemoryInfo`, `CPUInfo` y `NetworkInfo` en secuencia, 
proporcionando un resumen completo de todos los recursos del sistema.
.EXAMPLE
SystemResourceData
Este comando generará reportes de uso de disco, memoria, CPU y red en una sola ejecución.
#>
function SystemResourceData {
    Write-Host "Recopilando datos de recursos del sistema: "
    DiskInfo
    MemoryInfo
    CPUInfo
    NetworkInfo
}
