Set-StrictMode -Version Latest
<#
.SYNOPSIS
    Importa los módulos necesarios desde una carpeta especificada por el usuario.

.DESCRIPTION
    La función `ImportModules` solicita al usuario que ingrese la dirección 
    de la carpeta donde se encuentran los módulos requeridos.
    Luego, intenta importar los módulos especificados desde esa carpeta a la
     sesión actual de PowerShell. Proporciona retroalimentación
    sobre el éxito o fracaso de cada importación de módulo.

.PARAMETER ModulePath
    Especifica la ruta completa a la carpeta que contiene los módulos. Esta 
    ruta es ingresada por el usuario mediante `Read-Host`.
    La ruta debe ser válida y contener los módulos necesarios con los nombres
     correctos, de lo contrario, se mostrará un mensaje
    de error y la función se detendrá.

.EXAMPLE
    ImportModules
    Este ejemplo solicita al usuario la ruta de la carpeta que contiene los 
    módulos y luego intenta importar los módulos
    `System_Resources.psm1`, `Virus-total.psm1`, `limpieza_archivosd.psm1`
     y `archivosocultosd.psm1` desde la carpeta especificada.
    
    Si la ruta o los módulos no existen, se muestra un mensaje de error.

.NOTES
    Asegúrate de que:
    - La carpeta especificada existe y contiene los módulos.
    - Los módulos tienen los nombres correctos.
    - La función está diseñada para detener la ejecución si uno o más módulos 
    no se pueden importar.
    
#>
function ImportModules { 
    try {
        $ModulePath = Read-Host "Ingresa la dirección de la carpeta donde se encuentran los módulos"
        if (Test-Path -Path $ModulePath) {
            try {
            Import-Module "$ModulePath\System_Resources.psm1"
            Import-Module "$ModulePath\Virus-total.psm1"
            Import-Module "$ModulePath\limpieza_archivosd.psm1"
            Import-Module "$ModulePath\archivosocultosd.psm1"
            Write-Host "Módulos importados con éxito." -ForegroundColor Green
            } catch {
                Write-Error "Error al importar los módulos: $_"
            }
        } else {
            Write-Host "La ruta especificada no existe. Por favor, verifica la dirección." -ForegroundColor Red
        }
    } catch {
        Write-Error "Error al importar los módulos: $_"
    }
}

<#
    .SYNOPSIS
    Muestra un menú de opciones para la ciberseguridad.

    .DESCRIPTION
    La función `Menu` muestra una lista de opciones al usuario, permitiéndole seleccionar qué acción desea realizar. Las opciones incluyen recursos del sistema, eliminación de archivos, limpieza de directorios, y consulta con VirusTotal.

    .EXAMPLE
    Menu
    Este ejemplo muestra el menú de opciones al usuario y permite seleccionar una acción.

    .NOTES
    El menú proporciona opciones numeradas que corresponden a diferentes funcionalidades de ciberseguridad.
    #>
function Menu {
    
    Write-Host "Opciones de Ciberseguridad:" -ForegroundColor Cyan
    Write-Host "Selecciona una Opción:"
    Write-Host "1: Recursos del sistema"
    Write-Host "2: Remover archivos temporales"
    Write-Host "3: Remover archivos antiguos"
    Write-Host "4: Limpiar directorio"
    Write-Host "5: Archivos ocultos"
    Write-Host "6: Consulta API-VirusTotal"
    Write-Host "7: Salir"
}
<#
    .SYNOPSIS
    Maneja la selección del menú y ejecuta la opción elegida por el usuario.

    .DESCRIPTION
    La función `options` muestra el menú, solicita al usuario que elija una opción, y ejecuta la función correspondiente según la selección del usuario. Incluye opciones para recursos del sistema, eliminación de archivos, limpieza de directorios, y consulta con VirusTotal.

    .PARAMETER option
    Número de opción elegido por el usuario. Acepta valores del 1 al 7, donde cada número corresponde a una acción específica.

    .PARAMETER DirectoryPath
    Ruta completa al directorio para las opciones de eliminación de archivos temporales, eliminación de archivos antiguos, y limpieza de directorios. Se solicita al usuario mediante `Read-Host`.

    .PARAMETER Path
    Ruta completa al directorio para la opción de archivos ocultos. Se solicita al usuario mediante `Read-Host`.

    .PARAMETER FilePath
    La ruta completa al archivo que se desea analizar con el Virus-total.

    .PARAMETER DirectoryPath
    La ruta completa al directorio que contiene los archivos a analizar.

    .EXAMPLE
    Analyze-File -FilePath "C:\Users\Usuario\Desktop\archivo-a-analizar.exe"
    Analiza el archivo especificado usando la API de VirusTotal.

    .EXAMPLE
    Analyze-Directory -DirectoryPath "C:\Users\Usuario\Desktop"
    Analiza todos los archivos en el directorio especificado utilizando la función `Analyze-File` para cada archivo.

    .EXAMPLE
    options
    Este ejemplo muestra el menú de opciones, permite al usuario seleccionar una opción y ejecuta la acción correspondiente.

    .NOTES
    La función proporciona retroalimentación si la opción seleccionada no es válida y muestra un mensaje de error en ese caso.
    #>
function options {
    do {
        try {
            Menu
            $option = Read-Host "Elija una opción"
            switch ($option) {
                1 { 
                    SystemResourceData 
                }
                2 {
                    $DirectoryPath = Read-Host "Ingrese la dirección de la carpeta para remover archivos temporales"
                    if (Test-Path -Path $DirectoryPath) {
                        Remove-TempFiles -DirectoryPath $DirectoryPath
                    } else {
                        Write-Host "La ruta especificada no existe." -ForegroundColor Red
                    }
                }
                3 {
                    $DirectoryPath = Read-Host "Ingrese la dirección de la carpeta para remover archivos antiguos"
                    if (Test-Path -Path $DirectoryPath) {
                        Remove-OldFiles -DirectoryPath $DirectoryPath
                    } else {
                        Write-Host "La ruta especificada no existe." -ForegroundColor Red
                    }
                }
                4 {
                    $DirectoryPath = Read-Host "Ingrese la dirección de la carpeta para limpiar"
                    if (Test-Path -Path $DirectoryPath) {
                        Clean-Directory -DirectoryPath $DirectoryPath
                    } else {
                        Write-Host "La ruta especificada no existe." -ForegroundColor Red
                    }
                }
                5 {
                    $Path = Read-Host "Ingrese la dirección de la carpeta para buscar archivos ocultos"
                    if (Test-Path -Path $Path) {
                        Get-HiddenFiles -Path $Path
                    } else {
                        Write-Host "La ruta especificada no existe." -ForegroundColor Red
                    }
                }
                6 {
                    $apiKey = "eae7f14254551615300ede2d104b88395322289543319e0675782b7ddc06cf85"
                    function Analyze-File {
                        param (
                            [string]$FilePath
                         )

    
                         if (-Not (Test-Path -Path $FilePath)) {
                            Write-Output "El archivo no se encuentra en la ruta especificada: $FilePath"
                            return
                         }
                    
                        $hash = (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash

                        $url = "https://www.virustotal.com/api/v3/files/$($hash)"
                        $headers = @{
                             "x-apikey" = $apiKey
                        }

                         try {
                            $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
                            Write-Output "Hash: $($response.data.id)"
                            Write-Output "Resultado: $($response.data.attributes.last_analysis_stats)"
                         } catch {
                                Write-Output "Error al consultar la API: $_"
                         }
                    }

                    Analyze-File -FilePath "C:\Users\Usuario\Desktop\archivo-a-analizar.exe"

                    function Analyze-Directory {
                        param (
                            [string]$DirectoryPath
                        )
    
                        if (-Not (Test-Path -Path $DirectoryPath)) {
                            Write-Output "El directorio no se encuentra en la ruta especificada: $DirectoryPath"
                            return
                        }
    
                        $files = Get-ChildItem -Path $DirectoryPath -File
    
                        foreach ($file in $files) {
                             Write-Output "Analizando archivo: $($file.FullName)"
                            Analyze-File -FilePath $file.FullName
                        }
                    }

                    Analyze-Directory -DirectoryPath "C:\Users\Usuario\Desktop"      
                }
                7 {
                    Write-Host "Saliendo..."
                    exit
                }
                default {
                    Write-Host "Opción no válida. Por favor, selecciona un número del 1 al 7." -ForegroundColor Red
                }
            }
        } catch {
            Write-Error "Error al procesar la opción seleccionada: $_"
        }

        $continue = Read-Host "¿Desea realizar otra acción? (S/N)"
    } while ($continue -eq "S" -or $continue -eq "s")
}

ImportModules
options