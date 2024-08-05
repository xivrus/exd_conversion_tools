#!/usr/bin/pwsh
[CmdletBinding()]
param (
    [Parameter()]
    [ValidateSet("release","test")]
    [string]
    $BuildType = 'test',
    [Parameter()]
    [switch]
    $IsHotfix = $false
)

# Start importing stuff
$ErrorActionPreference_before = $ErrorActionPreference
$ErrorActionPreference = 'Stop'

Import-Module -Name "./lib/file_types/XLIFFMonolingual.psm1"
$CONFIG = Get-Content -Path "./config.cfg" | ConvertFrom-StringData

$ErrorActionPreference = $ErrorActionPreference_before
# End of importing stuff


$include_exds_dir      = Get-ChildItem -Path './output' -Filter 'exd' -Directory
$include_textures_dir  = Get-ChildItem -Path './textures/root_mod_png_dds_tex/*' -Directory
$include_raw_dir       = Get-ChildItem -Path './include_raw/*' -Directory
$default_mod_json_path = './meta/default_mod.json'
$meta_json_path        = './meta/meta.json'

# Construct default_mod.json
$files_redirections = [PSCustomObject]@{}

# Grab raw includes
$include_raw_files = Get-ChildItem -Path $include_raw_dir -File -Recurse
foreach ($file in $include_raw_files) {
    $game_path = $file.FullName -creplace "^.*$($include_raw_dir.Parent.Name)/"
    $real_path = $game_path -creplace '/', '\'
    $files_redirections | Add-Member -MemberType NoteProperty -Name $game_path -Value $real_path
}

# Grab modded textures
$include_textures_files = Get-ChildItem -Path $include_textures_dir -File -Recurse
foreach ($file in $include_textures_files) {
    $game_path = $file.FullName -replace "^.*$($include_textures_dir[0].Parent.Name)/"
    $real_path = $game_path -replace '/', '\'
    $files_redirections | Add-Member -MemberType NoteProperty -Name $game_path -Value $real_path
}

# Grab modded EXDs
$include_exds_files = Get-ChildItem -Path $include_exds_dir -File -Recurse
foreach ($file in $include_exds_files) {
    $game_path = $file.FullName -replace "^.*$($include_exds_dir.Parent.Name)/"
    $real_path = $game_path -replace '/', '\'
    $files_redirections | Add-Member -MemberType NoteProperty -Name $game_path -Value $real_path
}

# Prepare JSON and output it to file
$default_mod_json = [PSCustomObject]@{
    Name          = ''
    Priority      = 0
    Files         = $files_redirections
    FileSwaps     = [PSCustomObject]@{}
    Manipulations = @()
}
$default_mod_json | ConvertTo-Json | Out-File $default_mod_json_path

# Increment version in meta.json
$meta_json = Get-Content $meta_json_path -Raw -Encoding utf8 | ConvertFrom-Json
$version_json = $meta_json.Version
$is_testing = $false
if ($version_json -match '-test') {
    $version_json = $version_json -creplace '-test', '.'
    $is_testing = $true
}
$version = [version]::new( $version_json )
$version_numbers = @{
    Major    = $version.Major
    Minor    = $version.Minor
    Build    = $version.Build
    Revision = $version.Revision
}

switch ($BuildType) {
    'test' {
        if ($is_testing) {
            $version_numbers.Revision++
        } else {
            $version_numbers.Revision = 1

            if ($IsHotfix) {
                $version_numbers.Build++
            } else {
                $version_numbers.Minor++
            }
        }

        $new_version = "{0}.{1}.{2}-test{3}" -f `
            $version_numbers.Major, $version_numbers.Minor,
            $version_numbers.Build, $version_numbers.Revision
        break
    }
    'release' {
        if ($is_testing) {
            $version_numbers.Revision = -1
        } else {
            Write-Warning "You're making a new release without testing!"
            $version_numbers.Minor++
            $version_numbers.Build = 0
        }

        $new_version = "{0}.{1}.{2}" -f `
            $version_numbers.Major, $version_numbers.Minor,
            $version_numbers.Build
        break
    }
}

$meta_json.Version = $new_version

# Add version to Lobby file and convert it

$version_list = Get-ChildItem -Path $CONFIG.DUMP_DIR -Directory
$dump_ver_dir = $version_list[-1]
$output_dir   = Get-Item -Path $CONFIG.OUTPUT_DIR

$lobby_path_exh     = "$dump_ver_dir/exd/Lobby.exh"
$lobby_path_strings = Get-Item -Path "./strings/exd/Lobby/ru.xlf"
$lobby_path_output  = "$output_dir/exd"

$lobby_table = Import-Strings -Path $lobby_path_strings
$lobby_table[12].String = $lobby_table[12].String -creplace '{{ version }}', $new_version
$error_code = Export-Strings -Table $lobby_table `
    -TargetLanguage 'ru' `
    -Destination $lobby_path_strings.Directory

$error_code = ./ConvertTo-GameData.ps1 `
    -ExhPath $lobby_path_exh `
    -StringsPath $lobby_path_strings `
    -FileType XLIFFMonolingual `
    -Overwrite `
    -Destination $lobby_path_output

Set-Location -Path $CONFIG.STRINGS_DIR
Invoke-Expression "git checkout ."
Set-Location -Path ".."

if ($error_code) {
    Write-Error "Error during EXD conversion"
    return
}

$meta_json | ConvertTo-Json | Out-File $meta_json_path

# Pack it up
$null = New-Item -Path './modpacks' -ItemType Directory -ErrorAction SilentlyContinue
$file_path_list = @(
    $include_exds_dir,
    $include_raw_dir,
    $default_mod_json_path,
    $meta_json_path
) + $include_textures_dir
Compress-Archive -Path $file_path_list -DestinationPath ('.\modpacks\XIVRus-{0}-{1:yyyy-MM-dd}.pmp' -f $meta_json.Version, $(Get-Date)) -CompressionLevel Optimal
