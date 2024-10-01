Set-StrictMode -Version Latest

<#
.SYNOPSIS
Módulo para la supervisión de recursos del sistema.
.DESCRIPTION
Este módulo contiene varias funciones que proporcionan información detallada 
sobre el uso de los recursos del sistema, como el uso de disco, memoria, CPU 
y red. Además, una función consolidada, `SystemResourceData`, ejecuta todas 
estas funciones y proporciona un resumen completo del sistema.

Este módulo es útil para administradores de sistemas que necesitan monitorear
 el rendimiento y estado de los recursos en tiempo real.

.FUNCTIONS
- DiskInfo: Muestra el uso del disco en gigabytes.
- MemoryInfo: Muestra el uso de la memoria en megabytes.
- CPUInfo: Proporciona detalles del procesador, como núcleos y porcentaje de uso.
- NetworkInfo: Muestra el tráfico de red en kilobytes por segundo.
- SystemResourceData: Consolida y muestra toda la información de recursos del sistema.

.NOTES
Versión: 1.0
#>

<#
.SYNOPSIS
Obtiene el uso del disco en gigabytes.
.DESCRIPTION
La función `DiskInfo` obtiene una lista de todas las unidades de disco conectadas 
y muestra información detallada sobre el espacio total, el espacio utilizado y el 
espacio libre, todo en gigabytes (GB).

El objetivo de esta función es ofrecer una visión rápida y clara del estado de 
almacenamiento de las unidades del sistema, lo cual es especialmente útil para 
monitorear el uso de disco en servidores o estaciones de trabajo con múltiples 
unidades de almacenamiento.

.EXAMPLE
DiskInfo
Este comando mostrará el espacio total, utilizado y libre para cada unidad de disco 
del sistema.

.EXAMPLE
DiskInfo | Out-File "DiskUsageReport.txt"
Este comando exportará la información del uso de disco a un archivo de texto llamado 
`DiskUsageReport.txt`.

.NOTES
Se recomienda ejecutar esta función con privilegios de administrador para obtener 
resultados precisos en todas las unidades.
#>
function DiskInfo {
    try {
        $Drives = Get-PSDrive -PSProvider FileSystem
        Write-Host "Datos de Disco:" -ForegroundColor Cyan
        foreach ($Drive in $Drives) {
            $UsedSpace = ($Drive.Used / 1GB)
            $FreeSpace = ($Drive.Free / 1GB)
            $TotalSpace = $UsedSpace + $FreeSpace

            $UsedS = [math]::round($UsedSpace, 3)
            $FreeS = [math]::round($FreeSpace, 3)
            $TotalS = [math]::round($TotalSpace, 3)

            Write-Host "Unidad $($Drive.Name):" -ForegroundColor DarkCyan
            Write-Host "  Espacio total: $TotalS GB"
            Write-Host "  Espacio usado: $UsedS GB" -BackgroundColor DarkGreen
            Write-Host "  Espacio libre: $FreeS GB"
        }
    } catch {
        Write-Error "Error al obtener el uso del disco: $_"
    }
}

<#
.SYNOPSIS
Muestra el uso de la memoria física en megabytes.
.DESCRIPTION
La función `MemoryInfo` proporciona información detallada sobre la memoria física total 
del sistema, la cantidad de memoria en uso y la memoria libre en megabytes (MB). Es útil 
para monitorear la carga de memoria y detectar posibles problemas de rendimiento debidos 
al uso excesivo de RAM.

.EXAMPLE
MemoryInfo
Este comando mostrará la memoria total, la memoria usada y la memoria libre en megabytes.

.EXAMPLE
$memoria = MemoryInfo
Este comando guardará los datos de memoria en la variable `$memoria` para su posterior 
análisis o reporte.

.NOTES
Esta función usa el cmdlet `Get-CimInstance` para obtener información sobre el sistema 
operativo, por lo que podría requerir permisos administrativos para acceder a todos los datos.
#>
function MemoryInfo {
    try {
        $Total = (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1KB
        $Free = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1KB
        $MemoryUsage  = $Total - $Free

        $TotalM  = [math]::Round($Total, 3)
        $FreeM = [math]::Round($Free, 3)
        $UsageM = [math]::Round($MemoryUsage, 3)

        Write-Host "Datos de Memoria:" -ForegroundColor Cyan
        Write-Host "Memoria total: $TotalM MB"
        Write-Host "Memoria usada: $UsageM MB" -BackgroundColor DarkGreen
        Write-Host "Memoria libre: $FreeM MB"
    } catch {
        Write-Error "Error al obtener el uso de memoria: $_" 
    }
}

<#
.SYNOPSIS
Proporciona detalles del procesador del sistema.
.DESCRIPTION
La función `CPUInfo` muestra información clave del procesador, como el nombre, el número 
de núcleos, la velocidad actual del reloj en MHz y el porcentaje de uso del procesador. 
Esta función es útil para monitorear el rendimiento de la CPU en tiempo real y diagnosticar
 problemas de carga excesiva en los núcleos del procesador.

.EXAMPLE
CPUInfo
Este comando mostrará el nombre del procesador, el número de núcleos y el uso actual en 
porcentaje.

.EXAMPLE
$cpu = CPUInfo
Este comando almacenará la información del procesador en la variable `$cpu` para su 
posterior análisis.

.NOTES
Esta función es compatible con sistemas multinúcleo y puede mostrar información de cada 
procesador en sistemas multiprocesador.
#>
function CPUInfo {
    try {
        $CPUInfo = Get-CimInstance -ClassName Win32_Processor
        foreach ($CPU in $CPUInfo) {
            Write-Host "Datos del CPU:" -ForegroundColor Cyan
            Write-Host "Nombre del procesador: $($CPU.Name)"
            Write-Host "Número de núcleos: $($CPU.NumberOfCores)"
            Write-Host "Velocidad actual: $($CPU.CurrentClockSpeed) MHz"
            Write-Host "Uso actual de CPU: $($CPU.LoadPercentage)%" -BackgroundColor DarkGreen
        }
    } catch {
        Write-Error "Error al obtener la información de la CPU: $_"  
    }
}

<#
.SYNOPSIS
Muestra el tráfico de red en kilobytes por segundo.
.DESCRIPTION
La función `NetworkInfo` muestra el tráfico de red en tiempo real, proporcionando detalles 
sobre los bytes enviados, recibidos y el total de bytes procesados por cada interfaz de red en el sistema.

.EXAMPLE
NetworkInfo
Este comando mostrará el tráfico de red actual en KB/s para cada interfaz de red activa.

.EXAMPLE
$red = NetworkInfo
Este comando almacenará la información de red en la variable `$red` para análisis posteriores.

.NOTES
Los resultados pueden variar según la velocidad de la red y la carga actual del tráfico. 
Recomendado para monitorear el rendimiento de la red en tiempo real.
#>
function NetworkInfo {
    try {
        $NetWork = Get-CimInstance -ClassName Win32_PerfFormattedData_Tcpip_NetworkInterface
        Write-Host "Datos del uso de la red:" -ForegroundColor Cyan
        foreach ($Interface in $Network) {
            $BytesSent = [math]::round($Interface.BytesSentPersec / 1KB, 3)
            $BytesReceived = [math]::round($Interface.BytesReceivedPersec / 1KB, 3)
            $BytesTotal = [math]::round($Interface.BytesTotalPersec / 1KB, 3)

            Write-Host "Interfaz: $($Interface.Name)" -ForegroundColor DarkCyan
            Write-Host "  Bytes enviados por segundo: $BytesSent KB/s"
            Write-Host "  Bytes recibidos por segundo: $BytesReceived KB/s"
            Write-Host "  Bytes totales por segundo: $BytesTotal KB/s" -BackgroundColor DarkGreen
        }
    } catch {
        Write-Error "Error al obtener el uso de la red: $_"
    }
}

<#
.SYNOPSIS
Consolida y muestra todos los datos de recursos del sistema.
.DESCRIPTION
La función `SystemResourceData` ejecuta las funciones `DiskInfo`, `MemoryInfo`, `CPUInfo` y 
`NetworkInfo` en secuencia, proporcionando un resumen completo de todos los recursos del 
sistema. Es útil para obtener una visión general del estado del sistema en una sola ejecución.

.EXAMPLE
SystemResourceData
Este comando mostrará un resumen del uso de disco, memoria, CPU y red en una sola ejecución.

.EXAMPLE
SystemResourceData | Out-File "SystemResourceReport.txt"
Este comando exportará el reporte completo del uso de recursos del sistema a un archivo 
de texto llamado `SystemResourceReport.txt`.

.NOTES
Ideal para informes periódicos o para diagnósticos rápidos del rendimiento del sistema.

Para ver la ayuda de la funcion DiskInfo usa: Get-Help DiskInfo
Para ver la ayuda de la funcion MemoryInfo usa: Get-Help MemoryInfo
Para ver la ayuda de la funcion CPUInfo usa: Get-Help CPUInfo
Para ver la ayuda de la funcion NetworkInfo usa: Get-Help NetworkInfo
#>
function SystemResourceData {
    Write-Host "Datos del uso de recursos del sistema:" -ForegroundColor Magenta
    Write-Host "================================================================="
    DiskInfo
    Write-Host "-----------------------------------------------------------------"
    MemoryInfo
    Write-Host "-----------------------------------------------------------------"
    CPUInfo
    Write-Host "-----------------------------------------------------------------"
    NetworkInfo
}
