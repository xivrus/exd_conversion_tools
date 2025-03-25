using module ./lib/EXHF.psm1

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Version = 'latest'
)

function Test-File ([string]$Path, [string]$PathGame) {
    if ( $(Get-Item -Path $Path).Length ) {
        Write-Information "Dumped - $Path" -InformationAction Continue
        return 0
    }
    Write-Warning "Not found - $PathGame"
    Remove-Item -Path $Path
    return 1
}



# Start importing stuff
$ErrorActionPreference_before = $ErrorActionPreference
$ErrorActionPreference = 'Stop'

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
    $dump_raw_dir = Join-Path -Path $CONFIG.PATHS.DUMP_RAW_DIR -ChildPath 'current'
} else {
    $dump_raw_dir = Join-Path -Path $CONFIG.PATHS.DUMP_RAW_DIR -ChildPath $Version
}

$ffxiv_install_ver = Get-Content -Path "$dump_raw_dir/game/ffxivgame.ver"
$full_dump_extracted_dir = "$($CONFIG.PATHS.DUMP_EXTRACTED_DIR)/$ffxiv_install_ver"
$null = New-Item -Path $full_dump_extracted_dir -ItemType Directory -ErrorAction Ignore

$RootExl = Invoke-Expression "./tools/tomestone-dump --ffxiv-install-dir $dump_raw_dir raw exd/root.exl"

foreach ($line in $RootExl) {
    $exh_path_game = "exd/{0}.exh" -f $($line -replace ',.*$', '')
    $exh_path_extracted = "$full_dump_extracted_dir/$exh_path_game"

    $exh_path_extracted_dir = Split-Path $exh_path_extracted
    $null = New-Item -Path $exh_path_extracted_dir -ItemType Directory -ErrorAction Ignore

    Invoke-Expression "./tools/tomestone-dump --ffxiv-install-dir $dump_raw_dir raw $exh_path_game > $exh_path_extracted"
    $error_code = Test-File -Path $exh_path_extracted -PathGame $exh_path_game
    if ($error_code) {
        continue
    }

    $exh = [EXHF]::new( (Resolve-Path -Path $exh_path_extracted) )
    foreach ($page_num in [int[]] $exh.PageTable.Keys) {
        foreach ($lang in [LanguageCodes].GetEnumNames()) {
            if ($exh.IsLanguageDeclared($lang)) {
                if ($lang -eq 'none') {
                    $exd_file_ending = "_{0}.exd" -f $page_num
                } else {
                    $exd_file_ending = "_{0}_{1}.exd" -f $page_num, $lang
                }
                $exd_path_game = $exh_path_game -replace '\.exh$', $exd_file_ending
                $exd_path_real = Join-Path -Path $full_dump_extracted_dir -ChildPath $exd_path_game

                Invoke-Expression "./tools/tomestone-dump --ffxiv-install-dir $dump_raw_dir raw $exd_path_game > $exd_path_real"
                $null = Test-File -Path $exd_path_real -PathGame $exd_path_game
            }
        }
    }
}
