using module ./lib/EXHF.psm1
using module ./lib/EXDF.psm1

[CmdletBinding()]
param (
    # Input path to a single EXH (Required)
    [Parameter(Mandatory)]
    [System.IO.FileInfo]
    $ExhPath,
    # Output file type (Required)
    # This option imports a module from ./lib/file_types folder.
    # You can create your own file type module. It must have the following functions:
    #  * Get-TargetPath -Path (directory) -Language (lang)
    #      Returns string - a full path of an expected export file.
    #  * Export-Strings -Table (SortedDictionary[int,string]) -Language (lang) -Destination (directory)
    #      Returns 0 on success and 1 on failure.
    # Check out existing modules to get an idea of how to create a new one.
    # 
    # Tip: You can use 'Memory' to return the in-memory table instead of exporting
    #      it to the file. This is used by update script. Note that in this case
    #      only one language would be converted, so you should specify desired
    #      language via -Languages.
    [Parameter(Mandatory)]
    [string]
    $FileType,
    # Languages
    # You have to specify language codes that exist in game files!
    # E.g. Chinese-Simplified would be 'chs', not 'zh'
    # By default the script is gonna grab all available languages from EXH.
    # Note: Global FFXIV EXHs for some reason declare that they have 'chs' and 'ko'.
    #       Seeing warnings about these languages is expected behavior.
    [Parameter()]
    [string[]]
    $Languages,
    # Add string IDs at the start? (Default: No)
    # Note: This ID is decimal.
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
    $Destination,
    # Compress strings files (Default: No)
    # Some file formats like XLIFF may allow compressing
    # by dropping all whitespace except the one in strings.
    # This switch has no effect on file types without
    # compression support.
    [Parameter()]
    [switch]
    $Compress = $false,
    # Ignore split config (Default: No)
    [Parameter()]
    [switch]
    $IgnoreSplits = $false
)


# Start importing stuff
$ErrorActionPreference_before = $ErrorActionPreference
$ErrorActionPreference = 'Stop'

Import-Module -Name "./lib/Engine.psm1"
if ($FileType -ne 'Memory') {
    Import-Module -Name "./lib/file_types/$FileType.psm1"
}
$CONVERSION_LISTS = Import-PowerShellDataFile -Path "./config/conversion_lists.psd1"

$ErrorActionPreference = $ErrorActionPreference_before
# End of importing stuff


# MAIN START


$exh = [EXHF]::new($ExhPath)
if ( $exh.IsLanguageDeclared('none') ) {
    Write-Warning "Non-language file, skipping - $ExhPath"
    return 1
}
$file_name = $ExhPath.BaseName
$do_we_split_file = $IgnoreSplits ? $false : $CONVERSION_LISTS.SPLIT_FILES.ContainsKey($file_name)
if ($do_we_split_file) {
    # Make it a simple array for performance
    $new_split_files = foreach ($split in $CONVERSION_LISTS.SPLIT_FILES.$($file_name).Keys.GetEnumerator()) {
        $split
    }

    # Give user some info about what's going to happen
    $warning_text = "File '$file_name' will be split to the following files:"
    foreach ($new_split_file in $new_split_files) {
        $warning_text += "`n  * {0} ({1}/{2})" -f $new_split_file, $Destination, $new_split_file
    }
    Write-Warning $warning_text
}

if ( -not $PSBoundParameters.ContainsKey('Languages') ) {
    $Languages = foreach ($lang in [LanguageCodes].GetEnumNames()) {
        if ( $exh.IsLanguageDeclared($lang) ) {
            $lang
        }
    }
}

foreach ($lang in $Languages) {
    if ($do_we_split_file) {
        $target_path = @{}
        $do_we_skip_lang = $true

        foreach ($new_split_file in $new_split_files) {
            $destination_split = "{0}/{1}" -f $Destination, $new_split_file
            $target_path.$new_split_file = Get-TargetPath -Path $destination_split -Language $lang

            if (-not $Overwrite -and (Test-Path -Path $target_path.$new_split_file)) {
                Write-Warning "Already exists - $($target_path.$new_split_file)"
            } else {
                $do_we_skip_lang = $false
            }
        }

        if ($do_we_skip_lang) {
            continue
        }
    } else {
        $target_path = Get-TargetPath -Path $Destination -Language $lang
        if (-not $Overwrite -and $(Test-Path -Path $target_path)) {
            Write-Warning "Already exists - $target_path"
            continue
        }
    }

    $do_we_export = $false
    # Key - Index; Value - String, State
    # State can be:
    #   * 0 - not translated
    #   * 1 - translated
    #   * 2 - approved
    # The table is saved under its name as a key for compatibility with
    # split files feature. In case of an actual file split, the tables
    # for each new file are under new files' names.
    $result_tables = @{}
    if ($do_we_split_file) {
        foreach ($new_split_file in $new_split_files) {
            $result_tables.$new_split_file = [System.Collections.Generic.SortedDictionary[int,pscustomobject]]::new()
        }
    } else {
        $result_tables.$file_name = [System.Collections.Generic.SortedDictionary[int,pscustomobject]]::new()
    }
    foreach ($page_num in [int[]] $exh.PageTable.Keys) {
        $exd_source_path = $exh.GetEXDPath($page_num, $lang)

        # Export checks: don't export language if all of the pages error out.
        if ( -not $(Test-Path -Path $exd_source_path) ) {
            Write-Warning "Not found - $exd_source_path"
            continue
        }
        $exd = [EXDF]::new($exh, $exd_source_path)
        if ($exd.DataRowTable.Count -lt 1) {
            Write-Warning "Empty EXD - $exd_source_path"
            continue
        }

        foreach ( $row in $exd.DataRowTable.GetEnumerator() ) {
            [System.Collections.Generic.List[byte]] $string_bytes = $row.Value.GetStringBytesFiltered()
            if ($string_bytes.Count -eq 0) {
                continue
            }

            # Remove the last 0x00 byte
            $string_bytes.RemoveAt($string_bytes.Count - 1)

            # Skip empty strings
            $_has_non_zero_bytes = $false
            foreach ( $_byte in $string_bytes ) {
                if ( $_byte -ne [byte] 0x00 ) {
                    $_has_non_zero_bytes = $true
                    break
                }
            }
            if (-not $_has_non_zero_bytes) {
                continue
            }

            # Convert strings to tags only when necessary
            if ($string_bytes.Contains($VAR_START_BYTE) -or $string_bytes.Contains($UNIX_NL_BYTE)) {
                $string_bytes = Convert-VariablesToTags $string_bytes
            }

            # Convert 0x00 to tabs separately
            $_col_sep_counter = $exh.GetStringDatasetOffsets().Count - 1
            while ($_col_sep_counter) {
                $_col_sep_index = $string_bytes.IndexOf( [byte]0x00 )
                $string_bytes.RemoveAt($_col_sep_index)
                $string_bytes.InsertRange($_col_sep_index, $COLUMN_SEPARATOR_BYTE)
                $_col_sep_counter--
            }

            $result = [System.Text.Encoding]::UTF8.GetString($string_bytes)

            # Skip empty strings for quest, cutscene, etc. files
            if ($result -cmatch '^TEXT_[A-Z0-9_]+?<tab>$') {
                continue
            }

            # If any of the strings in pages passes export checks, we're exporting this language.
            $do_we_export = $true

            # Add string IDs if requested
            if ($AddStringIDs -and -not $result.StartsWith("{0}_" -f $row.Key)) {
                $result = "{0}_{1}" -f $row.Key, $result
            }

            if ($do_we_split_file) {
                $result_split = $result -split $COLUMN_SEPARATOR

                foreach ($new_split_file in $new_split_files) {
                    $splits_to_join = foreach ($column_number in $CONVERSION_LISTS.SPLIT_FILES.$file_name.$new_split_file.Columns) {
                        $result_split[$column_number]
                    }

                    $new_result = $splits_to_join -join $COLUMN_SEPARATOR
                    $result_tables.$new_split_file.Add( $row.Key, [pscustomobject]@{
                        String = $new_result
                        State  = $STRING_STATE_APPROVED
                    })
                }
            } else {
                $result_tables.$file_name.Add( $row.Key, [pscustomobject]@{
                    String = $result
                    State  = $STRING_STATE_APPROVED
                })
            }
        }

        if ($result_tables.ContainsKey($file_name) -and
            $result_tables.$file_name.Count -eq 0 -and
            -not ($FileType -eq 'Memory')) {
            Write-Warning "Only empty strings, skipping - $exd_source_path"
        }
    }

    # The calling script must be aware of whether it gets
    # the split tables or the normal ones!
    # Also returning even emtpy tables because
    # the calling script will expect them.
    if ($FileType -eq 'Memory') {
        return $result_tables
    }

    if ($do_we_export) {
        if ($do_we_split_file) {
            foreach ($new_split_file in $new_split_files) {
                $destination_split = "{0}/{1}" -f $Destination, $new_split_file

                $null = New-Item -Path $destination_split -ItemType Directory -Force -ErrorAction Stop
                $export_result = Export-Strings -Table $result_tables.$new_split_file `
                    -TargetLanguage $lang `
                    -Destination $destination_split `
                    -Compress:$Compress
                if ($export_result) {
                    Write-Error "Error while exporting to $($target_path.$new_split_file)"
                    return 2
                }
                Write-Information "Converted - $($target_path.$new_split_file)" -InformationAction Continue
            }
        } else {
            $null = New-Item -Path $Destination -ItemType Directory -Force -ErrorAction Stop
            $export_result = Export-Strings -Table $result_tables.$file_name `
                -TargetLanguage $lang `
                -Destination $Destination `
                -Compress:$Compress
            if ($export_result) {
                Write-Error "Error while exporting to $target_path"
                return 2
            }
            Write-Information "Converted - $target_path" -InformationAction Continue
        }
    }
}

return 0
