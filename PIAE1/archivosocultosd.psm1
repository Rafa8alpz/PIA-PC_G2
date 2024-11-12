Set-StrictMode -Version Latest

function Get-HiddenFiles {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Path,
        [Parameter(Mandatory=$false)]
        [string]$OutputPath = "HiddenFilesReport.csv"
    )

    if (-Not (Test-Path $Path)) {
        Write-Error "La ruta especificada no existe."
        return
    }

    $files = Get-ChildItem -Path $Path -Force | Where-Object { $_.Attributes -match "Hidden" }

    if ($files.Count -eq 0) {
        Write-Output "No se encontraron archivos ocultos."
    } else {
        $report = $files | Select-Object FullName, Name, Length, LastWriteTime

        # Exportar a CSV
        try {
            $report | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8
            Write-Output "Reporte generado en: $OutputPath"
        } catch {
            Write-Error "No se pudo generar el reporte: $_"
        }
    }
}
