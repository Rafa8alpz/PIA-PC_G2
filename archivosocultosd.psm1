Set-StrictMode -Version Latest

function Get-HiddenFiles {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path
    )

    if (-Not (Test-Path $Path)) {
        Write-Error "La ruta especificada no existe."
        return
    }

    $files = Get-ChildItem -Path $Path -Force | Where-Object { $_.Attributes -match "Hidden" }

    if ($files.Count -eq 0) {
        Write-Output "No se encontraron archivos ocultos."
    } else {
        $files | Select-Object FullName, Name, Length, LastWriteTime
    }
}