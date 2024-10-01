@{
    # Manifiesto del módulo 'CheckVirusTotal'
    # Información del módulo
    ModuleVersion = '1.0.0'
    GUID = 'a4e2d70b-5fc2-45f9-a302-d1dbf2d35c4a'
    Author = 'Karyme Gonzalez'
    CompanyName = 'Desconocido'
    Copyright = '© 2024 Karyme Gonzalez. Todos los derechos reservados.'
    Description = 'Un script de PowerShell que calcula el hash de un archivo y consulta la API de VirusTotal para verificar la seguridad del archivo.'

    # Requisitos del módulo
    PowerShellVersion = '5.0'
    FunctionsToExport = @('Analyze-File', 'Analyze-Directory')

    # Opciones de importación
    RootModule = 'CheckVirusTotal.ps1'
}
