[CmdletBinding()]
param (
    # Output file type (Required)
    # Check out help message in ConvertTo-GameData.ps1
    [Parameter(Mandatory)]
    [string]
    $FileType,
    # Source language (Required)
    # What language to convert?
    [Parameter(Mandatory)]
    [string]
    $SourceLanguage,
    # Target language
    # Check out help message in ConvertTo-GameData.ps1
    [Parameter()]
    [string]
    $TargetLanguage = 'en',
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
    # Ignore quest include list from ConversionLists.psm1? (Default: No)
    [Parameter()]
    [switch]
    $IgnoreQuestIncludeList = $false
)


# Start importing stuff
$ErrorActionPreference_before = $ErrorActionPreference
$ErrorActionPreference = 'Stop'

Import-Module -Name "./lib/ConversionLists.psm1"
Import-Module -Name "./lib/Engine.psm1"
Import-Module -Name "./lib/file_types/$FileType.psm1"
$CONFIG = Get-Content -Path "./config.cfg" | ConvertFrom-StringData

$ErrorActionPreference = $ErrorActionPreference_before
# End of importing stuff

if ($Version -eq 'latest') {
    $version_list = Get-ChildItem -Path $CONFIG.DUMP_DIR -Directory
    $dump_ver_dir = $version_list[-1]
} else {
    $dump_ver_path = "{0}/{1}" -f $CONFIG.DUMP_DIR, $Version
    if (-not $(Test-Path -Path $dump_ver_path)) {
        throw "Version $Version was not found in dump folder."
    }
    $dump_ver_dir = Get-Item -Path $dump_ver_path
}
Write-Information "Using version: $dump_ver_dir" -InformationAction Continue

$search_query = "{0}/*{1}.{2}" -f $CONFIG.STRINGS_DIR, $SourceLanguage, (Get-StringsFileExtension)
"Getting all {0} strings files at {1}" -f $SourceLanguage.ToUpper(), $CONFIG.STRINGS_DIR
Write-Verbose "Search query: $search_query"
$input_strings_file_list = Get-ChildItem -Path $search_query -Recurse -File
"Done."

# Make a normal array of all files that need to be combined
$files_to_combine = foreach ($split_file in $SPLIT_FILE_LIST.GetEnumerator()) {
    foreach ($file_name in [string[]] $split_file.Value.Keys) {
        $file_name
    }
}
# Collection of flags that indicate whether the parent file was combined.
# This prevents the parent file to be combined multiple times.
$files_combined = @{}

foreach ($input_strings_file in $input_strings_file_list) {
    # Set up paths
    $file_name = $input_strings_file.Directory.BaseName
    $game_path = $input_strings_file.DirectoryName `
        -creplace "$($CONFIG.STRINGS_DIR)/", '' `
        -creplace "/$file_name`$", ''
    $exh_path = "{0}/{1}/{2}.exh" -f $dump_ver_dir, $game_path, $file_name
    $destination_path = "{0}/{1}" -f $CONFIG.OUTPUT_DIR, $game_path

    if (-not $IgnoreQuestIncludeList -and
        ($game_path -cmatch '^exd/(?:cut_scene|opening|quest)/') -and
        ($file_name -notin $QUEST_INCLUDE_LIST)) {
        Write-Warning "Quest file is not in include list, skipping - $input_strings_file"
        continue
    }

    # Compare last write time with cached one. Skip if it's the same.
    # Time is in UTC for consistency sake
    $last_write_time = $input_strings_file.LastWriteTime.ToUniversalTime().ToString()
    $cache_file_path = "{0}/{1}/{2}/{3}.{4}.time" -f `
        $CONFIG.CACHE_DIR, $game_path, $file_name, $SourceLanguage, (Get-StringsFileExtension)
    if (Test-Path -Path $cache_file_path) {
        $last_write_time_cached = Get-Content -Path $cache_file_path
        if ($last_write_time -eq $last_write_time_cached) {
            Write-Warning "File didn't change, skipping - $input_strings_file"
            continue
        }
    }

    # If current file is one of the split ones, combine them back into
    # a single one and then treat it like a normal strings file.
    # Split files are expected to be in their nested folders. Combined
    # strings file will be saved in their parent folder, like it would
    # be if it wasn't split in the first place.
    # After all conversions these combined files would be deleted.
    if ($file_name -in $files_to_combine) {
        # Set up paths again, but differently
        $file_name = $input_strings_file.Directory.Parent.Name
        $game_path = $input_strings_file.Directory.Parent `
            -creplace "$($CONFIG.STRINGS_DIR)/", '' `
            -creplace "/$file_name`$", ''
        $exh_path = "{0}/{1}/{2}.exh" -f $dump_ver_dir, $game_path, $file_name
        $destination_path = "{0}/{1}" -f $CONFIG.OUTPUT_DIR, $game_path

        $destination_strings_path = "{0}/{1}/{2}"  -f $CONFIG.STRINGS_DIR, $game_path, $file_name

        if ($files_combined.ContainsKey($file_name)) {
            Write-Verbose "File was already combined into $file_name - $input_strings_file"
            continue
        }

        # Put all split tables into a hashtable
        $tables_split = @{}
        # Also determine all existing rows to go through them later
        $index_list = [System.Collections.Generic.List[int]]::new()
        foreach ($split_file in $SPLIT_FILE_LIST.$file_name.GetEnumerator()) {
            $split_file_name = $split_file.Key
            $split_file_lang = $split_file.Value.ContainsKey('Language') ? $split_file.Value.Language : $SourceLanguage

            $split_file_path = "{0}/{1}/{2}.{3}" -f `
                $input_strings_file.Directory.Parent,
                $split_file_name,
                $split_file_lang,
                (Get-StringsFileExtension)
            Write-Verbose "Getting table from $split_file_path..."
            $tables_split.$split_file_name = Import-Strings -Path $split_file_path

            # Fill empty target strings with source
            if ($split_file_lang -ne $CONFIG.MAIN_SOURCE_LANGUAGE) {
                $split_file_source_path = "{0}/{1}/{2}.{3}" -f `
                    $input_strings_file.Directory.Parent,
                    $split_file_name,
                    $CONFIG.MAIN_SOURCE_LANGUAGE,
                    (Get-StringsFileExtension)
                $table_source = Import-Strings -Path $split_file_source_path

                foreach ($row in $tables_split.$split_file_name.GetEnumerator()) {
                    if ($row.Value.String.Length -eq 0) {
                        $id = $row.Key
                        $row.Value.String = $table_source[$id].String
                    }
                }
            }

            $index_list.AddRange( [int[]] $tables_split.$split_file_name.Keys )
        }
        $index_list = $index_list | Sort-Object -Unique

        # Make a sorted reverse split table that dictates an order of split columns
        $reverse_split_table = [System.Collections.Generic.SortedDictionary[int,string]]::new()
        foreach ($split_file in $SPLIT_FILE_LIST.$file_name.GetEnumerator()) {
            foreach ($column in $split_file.Value.Columns) {
                $reverse_split_table.$column = $split_file.Key
            }
        }

        # Create a new combined table with all columns
        $table_combined = [System.Collections.Generic.SortedDictionary[int,pscustomobject]]::new()
        Write-Verbose "Combining tables..."
        foreach ($index in $index_list) {
            $split_sets = @{}
            $i = @{}
            foreach ($split_file_name in [string[]] $SPLIT_FILE_LIST.$file_name.Keys) {
                $split_sets.$split_file_name = $tables_split.$split_file_name[$index].String -split $COLUMN_SEPARATOR
                $i.$split_file_name = 0
            }

            $splits_ordered = [System.Collections.Generic.List[string]]::new()
            foreach ($reverse_split in [string[]] $reverse_split_table.Values) {
                $splits_ordered.Add(
                    $split_sets.$reverse_split[$i.$reverse_split]
                )
                $i.$reverse_split += 1
            }
            $string = $splits_ordered -join $COLUMN_SEPARATOR

            $table_combined.Add($index, [PSCustomObject]@{
                String = $string
                State = $STRING_STATE_TRANSLATED
            })
        }

        # Export this table to a combined file that would be then processed normally
        Write-Verbose "Exporting combined table..."
        $error_code = Export-Strings `
            -Table $table_combined `
            -TargetLanguage $SourceLanguage `
            -Destination $destination_strings_path
        if ($error_code) {
            throw "Error during conversion to a combined file - $destination_strings_path"
        }

        $files_combined.$file_name = $true
        $input_strings_file = Get-Item -Path (
            Get-TargetPath -Path $destination_strings_path -Language $SourceLanguage
        )

        # ConvertTo-GameData script will expect to have a main source language strings file,
        # which wouldn't be there after combining just target language files.
        # Since combined file simply mirrors the original file, we'll just convert
        # the original one.
        $error_code = ./ConvertFrom-GameData.ps1 `
            -ExhPath $exh_path `
            -FileType XLIFFMonolingual `
            -Languages 'en' `
            -Destination $destination_strings_path `
            -Overwrite `
            -IgnoreSplits
        if ($error_code) {
            Write-Error "Error while converting original combined game file to $destination_strings_path"
            continue
        }
    }

    $result = ./ConvertTo-GameData.ps1 `
        -ExhPath $exh_path `
        -StringsPath $input_strings_file `
        -FileType XLIFFMonolingual `
        -Overwrite `
        -Destination $destination_path

    if ($result -eq 0) {
        $null = New-Item -Path (Split-Path -Path $cache_file_path -Parent) -ItemType Directory -ErrorAction Ignore
        $null = New-Item -Path $cache_file_path -ItemType File -ErrorAction Ignore
        Set-Content -Value $last_write_time -Path $cache_file_path
    }

    if ($files_combined.$file_name -and (Test-Path -Path $input_strings_file)) {
        $source_strings_file = "{0}/{1}.{2}" -f `
            $destination_strings_path,
            $CONFIG.MAIN_SOURCE_LANGUAGE,
            (Get-StringsFileExtension)

        Remove-Item -Path $input_strings_file
        Remove-Item -Path $source_strings_file
    }
}
