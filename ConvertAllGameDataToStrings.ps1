[CmdletBinding()]
param (
    # Output file type (Required)
    # Check out help message in ConvertFrom-GameData.ps1
    [Parameter(Mandatory)]
    [string]
    $FileType,
    # Languages
    # Check out help message in ConvertFrom-GameData.ps1
    [Parameter()]
    [string[]]
    $Languages,
    # Game version (Default: latest)
    # Default 'latest' takes the last folder in dump directory.
    # Otherwise specify the _name of the folder_ that you want
    # to dump from.
    [Parameter()]
    [string]
    $Version = 'latest',
    # Overwrite EXD(s) if they exist? (Default: No)
    [Parameter()]
    [switch]
    $Overwrite = $false,
    # Compress strings files (Default: No)
    # Some file formats like XLIFF may allow compressing
    # by dropping all whitespace except the one in strings.
    # This switch has no effect on file types without
    # compression support.
    [Parameter()]
    [switch]
    $Compress = $false
)


# Start importing stuff
$ErrorActionPreference_before = $ErrorActionPreference
$ErrorActionPreference = 'Stop'

Import-Module -Name "./lib/file_types/$FileType.psm1"
$CONFIG = Import-PowerShellDataFile -Path "./config/config.psd1"
foreach ($path_name in [string[]] $CONFIG.PATHS.Keys) {
    try {
        $CONFIG.PATHS.$path_name = (Resolve-Path -Path $CONFIG.PATHS.$path_name).Path
    }
    catch {
        Write-Error ("Path {0} could not be resolved." -f $CONFIG.PATHS.$path_name)
        return 2
    }
}

$ErrorActionPreference = $ErrorActionPreference_before
# Finish importing stuff


if ($Version -eq 'latest') {
    $version_list = Get-ChildItem -Path $CONFIG.PATHS.DUMP_EXTRACTED_DIR -Directory
    $dump_ver_path = $version_list[-1]
} else {
    $dump_ver_path = "{0}/{1}" -f $CONFIG.PATHS.DUMP_EXTRACTED_DIR, $Version
    if (-not $(Test-Path -Path $dump_ver_path)) {
        throw "Version $Version was not found in dump folder."
    }
}

$exh_list = Get-ChildItem -Path "$dump_ver_path/*.exh" -Recurse -File
foreach ($exh in $exh_list) {
    $sub_path = $exh.FullName.Replace("$dump_ver_path/",'') -creplace '\.exh$', ''
    $strings_path = "{0}/{1}" -f $CONFIG.PATHS.STRINGS_DIR, $sub_path

    $result = ./ConvertFrom-GameData.ps1 `
        -ExhPath $exh `
        -FileType $FileType `
        -Overwrite:$Overwrite `
        -Destination $strings_path `
        -Compress:$Compress
    
    if ($result -eq 2) {
        Write-Error "Critical error, stopping."
        return
    }
}
