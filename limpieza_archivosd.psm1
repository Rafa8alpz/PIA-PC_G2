Set-StrictMode -Version Latest

function Remove-TempFiles {
    param (
        [string]$DirectoryPath
    )

    if (-Not (Test-Path -Path $DirectoryPath)) {
        Write-Host "El directorio $DirectoryPath no existe."
        return
    }

    $tempFiles = Get-ChildItem -Path $DirectoryPath -Recurse -Filter "*.tmp" -ErrorAction SilentlyContinue
    if ($tempFiles) {
        $tempFiles | ForEach-Object {
            Remove-Item -Path $_.FullName -Force -Verbose -ErrorAction SilentlyContinue
        }
        Write-Host "Archivos temporales eliminados en $DirectoryPath"
    } else {
        Write-Host "No se encontraron archivos temporales en $DirectoryPath."
    }
}

function Remove-OldFiles {
    param (
        [string]$DirectoryPath,
        [int]$DaysOld = 30
    )

    if (-Not (Test-Path -Path $DirectoryPath)) {
        Write-Host "El directorio $DirectoryPath no existe."
        return
    }

    $dateThreshold = (Get-Date).AddDays(-$DaysOld)

    $oldFiles = Get-ChildItem -Path $DirectoryPath -Recurse -ErrorAction SilentlyContinue | Where-Object {
        -not $_.PSIsContainer -and $_.LastWriteTime -lt $dateThreshold
    }
    if ($oldFiles) {
        $oldFiles | ForEach-Object {
            Remove-Item -Path $_.FullName -Force -Verbose -ErrorAction SilentlyContinue
        }
        Write-Host "Archivos más antiguos que $DaysOld días eliminados en $DirectoryPath"
    } else {
        Write-Host "No se encontraron archivos viejos en $DirectoryPath."
    }
}

function Clean-Directory {
    param (
        [string]$DirectoryPath,
        [int]$DaysOld = 30
    )
    
    if (-Not (Test-Path -Path $DirectoryPath)) {
        Write-Host "El directorio $DirectoryPath no existe."
        return
    }
    
    Write-Host "Iniciando limpieza en $DirectoryPath"

#Comandos para la eliminación de archivos temporales o viejos
    Remove-TempFiles -DirectoryPath $DirectoryPath
  
    Remove-OldFiles -DirectoryPath $DirectoryPath -DaysOld $DaysOld

    Write-Host "Limpieza completada en $DirectoryPath"
}