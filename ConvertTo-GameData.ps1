using module ./lib/EXHF.psm1
using module ./lib/EXDF.psm1

[CmdletBinding()]
param (
    # Input path to a single EXH (Required)
    [Parameter(Mandatory)]
    [System.IO.FileInfo]
    $ExhPath,
    # Input path to a strings file (Required)
    [Parameter(Mandatory)]
    [System.IO.FileInfo]
    $StringsPath,
    # Output file type (Required)
    # This option imports a module from ./lib/file_types folder.
    # You can create your own file type module. It must have the following functions:
    #  * Get-TargetPath -Path (directory) -Language (lang)
    #      Returns string - a full path of an expected export file.
    #  * Export-Strings -Table (ordered hashtable) -Language (lang) -Destination (directory)
    #      Returns 0 on success and 1 on failure.
    # Check out existing modules to get an idea of how to create a new one.
    [Parameter(Mandatory)]
    [string]
    $FileType,
    # Output language (Default: en)
    # Choose what official language to mod. EXD of specified language must exist.
    [Parameter()]
    [string]
    $TargetLanguage = 'en',
    # Add string IDs at the start? (Default: No)
    # For debugging or string identifying purposes.
    # Notes:
    #  * This ID is decimal.
    #  * If the string has its ID at the start already, it won't be added again.
    #  * The script can recognize quest/cutscene strings (they start with TEXT_).
    #    In this case the index would be added after <tab>.
    [Parameter()]
    [switch]
    $AddStringIDs = $false,
    # Overwrite EXD(s) if they exist? (Default: No)
    [Parameter()]
    [switch]
    $Overwrite = $false,
    # Destination path to a folder (Required)
    [Parameter(Mandatory)]
    [System.IO.DirectoryInfo]
    $Destination
)


# Start importing stuff
$ErrorActionPreference_before = $ErrorActionPreference
$ErrorActionPreference = 'Stop'

Import-Module -Name "./lib/Engine.psm1"
Import-Module -Name "./lib/file_types/$FileType.psm1"

$ErrorActionPreference = $ErrorActionPreference_before
# End of importing stuff


# MAIN START

if (-not $(Test-Path -Path $StringsPath)) {
    Write-Error "Not found - $StringsPath"
    return 2
}

try {
    $exh = [EXHF]::new($ExhPath)
}
catch {
    Write-Error "Read error or Not found - $ExhPath"
    return 2
}

$table = Import-Strings -Path $StringsPath

# Whenever error flag is set we stop writing strings into EXD
# but continue going through the strings to catch and report more
# potential errors.
$error_flag = $false
foreach ($page_number in [int[]] $exh.PageTable.Keys) {
    $exd_source_path = $exh.GetEXDPath($page_number, $TargetLanguage)
    $exd_target_path = "{0}/{1}" -f $Destination, (Split-Path $exd_source_path -Leaf)

    if (-not $Overwrite -and $(Test-Path -Path $exd_target_path)) {
        Write-Warning "EXD already exists - $exd_target_path"
        $error_flag = $true
        break
    }

    try {
        $exd = [EXDF]::new($exh, $exd_source_path)
    }
    catch {
        Write-Error "Read error or Not found - $exd_source_path"
        return 2
    }

    foreach ($row in $exd.DataRowTable.GetEnumerator()) {
        $index = $row.Key
        if ( $table[$index].Length -eq 0 ) {
            continue
        }

        if ($AddStringIDs) {
            $string_id_text = "{0}_" -f $index
            $quest_strings_regex = "^TEXT_[A-Z0-9_]+?<tab>{0}_" -f $index
            $quest_strings_replace = "<tab>{0}_" -f $index

            if ($table[$index] -cmatch '^TEXT_[A-Z0-9_]+?<tab>' -and
                $table[$index] -cnotmatch $quest_strings_regex) {
                $table[$index] = $table[$index] -creplace '<tab>', $quest_strings_replace
            } elseif (-not $table[$index].StartsWith($string_id_text)) {
                $table[$index] = "{0}{1}" -f $string_id_text, $table[$index]
            }
        }

        try {
            $result_bytes = Convert-TagsToVariables $table[$index]
        }
        catch {
            Write-Error "Syntax error at line $index - $StringsPath"
            $error_flag = $true
        }

        $amount_of_strings = $result_bytes.Where({ $_ -eq 0x00 }).Count
        if ($amount_of_strings -ne $exh.GetStringDatasetOffsets().Count) {
            Write-Error "Wrong amount of columns at line $index - $StringsPath"
            $error_flag = $true
        }

        if (-not $error_flag) {
            $row.Value.SetStringBytes($result_bytes)
        }
    }

    if (-not $error_flag) {
        $_parent_target_folder = Split-Path -Path $exd_target_path -Parent
        $null = New-Item -Path $_parent_target_folder -ItemType Directory -ErrorAction Ignore

        try {
            $exd.ExportEXD($exd_target_path)
        }
        catch {
            Write-Error "Error during EXD export - $exd_target_path"
            return 1
        }
        Write-Information "Converted - $exd_target_path" -InformationAction Continue

        # Compare output EXD with source one; if they're the same,
        # output EXD is not needed, delete it.
        $hash1 = $(Get-FileHash -Path $exd_source_path).hash
        $hash2 = $(Get-FileHash -Path $exd_target_path).hash
        if ($hash1 -eq $hash2) {
            Write-Information "Target EXD (p. $page_number) turned out the same, so it was deleted"
            Remove-Item -Path $exd_target_path
        }
    }
}

if ($error_flag) {
    Write-Warning "Not converted - $StringsPath"
    return 1
} else {
    return 0
}
