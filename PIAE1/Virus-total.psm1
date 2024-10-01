Set-ExecutionPolicy RemoteSigned
Set-StrictMode -Version Latest

<#
.SYNOPSIS
    Analiza archivos y directorios usando la API de VirusTotal.
.DESCRIPTION
    Este script proporciona dos funciones: una para analizar un archivo individual y otra para analizar todos los archivos en un directorio especificado. Utiliza la API de VirusTotal para obtener información sobre la seguridad de los archivos.
.PARAMETER FilePath
    La ruta completa al archivo que se desea analizar.
.PARAMETER DirectoryPath
    La ruta completa al directorio que contiene los archivos a analizar.
.EXAMPLE
    Analyze-File -FilePath "C:\Users\Ramiro Gonzalez\Desktop\horario.exe"
    Analiza el archivo especificado usando la API de VirusTotal.
.EXAMPLE
    Analyze-Directory -DirectoryPath "C:\Users\Ramiro Gonzalez\Desktop"
    Analiza todos los archivos en el directorio especificado utilizando la función `Analyze-File` para cada archivo.
.NOTES
    Asegúrese de que la clave API de VirusTotal sea válida y que la ruta al archivo o directorio sea correcta antes de llamar a estas funciones.
#>

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

Analyze-File -FilePath "C:\Users\Ramiro Gonzalez\Desktop\horario.exe"


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

# Llamar a la función para analizar todos los archivos en el directorio
# Cambia la ruta al directorio que deseas analizar si es necesario
Analyze-Directory -DirectoryPath "C:\Users\Ramiro Gonzalez\Desktop"
