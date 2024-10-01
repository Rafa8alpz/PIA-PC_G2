@{
    # Información del módulo
    ModuleVersion = '1.0.0'
    GUID = 'e6b12345-6789-4abc-def0-1234567890ab'
    Author = 'Max Gómez'
    CompanyName = 'Desconocido'
    Copyright = '© 2024 Max Gomez. Todos los derechos reservados.'
    Description = 'Un módulo de PowerShell para limpiar directorios eliminando archivos temporales y archivos viejos.'

    # Requisitos del módulo
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Remove-TempFiles', 'Remove-OldFiles', 'Clean-Directory')
    
    # Opciones de importación
    RootModule = 'limpieza_archivos.psm1'
}