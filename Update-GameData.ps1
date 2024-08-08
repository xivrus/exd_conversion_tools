# We're grabbing official language list from an enum here
using module ./lib/EXHF.psm1

[CmdletBinding()]
param (
    # Output file type (Required)
    # Check out help message in ConvertFrom-GameData.ps1
    [Parameter(Mandatory)]
    [string]
    $FileType,
    # Game version to update from
    # Notes:
    #   * 'Game version' is just a name of the folder
    #     with the necessary game files.
    #   * It can't be 'latest'
    [Parameter(Mandatory)]
    [string]
    $CurrentVersion,
    # Game version to update to (Default: latest)
    # Default 'latest' takes the last folder in dump directory.
    # Otherwise specify the _name of the folder_ that you want
    # to dump from.
    [Parameter()]
    [string]
    $NewVersion = 'latest',
    # Do not perform actual update (Default: No)
    # Enabling this ensures that no strings files are touched.
    # The script will only output what is about to be done.
    # Verbose will be enabled in this case.
    # Note: Changelogs will still be exported at the end.
    [Parameter()]
    [switch]
    $DryRun = $false,
    # Compress strings files (Default: No)
    # Some file formats like XLIFF may allow compressing
    # by dropping all whitespace except the one in strings.
    # This switch has no effect on file types without
    # compression support.
    [Parameter()]
    [switch]
    $Compress = $false
)

function Compare-Files {
    param (
        # First file path
        [Parameter(Mandatory)]
        [string]
        $File1,
        # Second file path
        [Parameter(Mandatory)]
        [string]
        $File2
    )

    if ((Test-Path -Path $File1) -and -not (Test-Path -Path $File2)) {
        return $COMPARISON_ONLY_FILE1_EXISTS
    }

    if (-not (Test-Path -Path $File1) -and (Test-Path -Path $File2)) {
        return $COMPARISON_ONLY_FILE2_EXISTS
    }

    if ( -not ((Test-Path $File1) -and (Test-Path $File2)) ) {
        return $COMPARISON_FILES_DONT_EXIST
    }

    $hash1 = $(Get-FileHash $File1).hash
    $hash2 = $(Get-FileHash $File2).hash
    if ($hash1 -eq $hash2) {
        return $COMPARISON_FILES_SAME
    } else {
        return $COMPARISON_FILES_DIFFERENT
    }
}

function Update-StringsOfficial {
    param (
        [Parameter(Mandatory)]
        [System.Collections.Generic.SortedDictionary[int,pscustomobject]]
        $TableCurrent,
        [Parameter(Mandatory)]
        [System.Collections.Generic.SortedDictionary[int,pscustomobject]]
        $TableNew,
        [Parameter(Mandatory)]
        [string]
        $FileName,
        [Parameter()]
        [switch]
        $AddStringIDs = $false
    )

    $changelog = [System.Collections.Generic.List[pscustomobject]]::new()

    # Step 1. Uniquely collect all indexes from both tables
    $indexes_current = [int[]] $TableCurrent.Keys
    $indexes_new = [int[]] $TableNew.Keys
    $indexes_all = $indexes_current + $indexes_new | Sort-Object -Unique

    # Step 2. Main thing
    foreach ($index in $indexes_all) {
        # Removed string
        if (-not $TableNew.ContainsKey($index)) {
            $changelog.Add([pscustomobject]@{
                File  = $FileName
                Index = $index
                Old   = $TableCurrent[$index].String
                New   = '[Removed]'
            })

            $result_ok = $TableCurrent.Remove($index)
            if (-not $result_ok) {
                throw "Error removing a row from the table."
            }
            continue
        }

        if ($AddStringIDs) {
            $new_string = "{0}_{1}" -f $index, $TableNew[$index].String
        } else {
            $new_string = $TableNew[$index].String
        }

        # New string
        if (-not $TableCurrent.ContainsKey($index)) {
            $TableCurrent.Add($index, [pscustomobject]@{
                String = $new_string
                State  = $STRING_STATE_APPROVED
            })

            $changelog.Add([pscustomobject]@{
                File  = $FileName
                Index = $index
                Old   = '[N/A]'
                New   = $new_string
            })

            continue
        }

        # Same string
        if ($TableNew[$index].String -ceq $TableCurrent[$index].String) {
            continue
        }

        # Changed string
        $changelog.Add([pscustomobject]@{
            File  = $FileName
            Index = $index
            Old   = $TableCurrent[$index].String
            New   = $new_string
        })

        $TableCurrent[$index].String = $new_string
        continue
    }

    return ,$changelog
}

function Update-StringsUnofficial {
    param (
        [Parameter(Mandatory)]
        [System.Collections.Generic.SortedDictionary[int,pscustomobject]]
        $TableCurrent,
        [Parameter(Mandatory)]
        [System.Collections.Generic.List[pscustomobject]]
        $ChangesOfficial,
        [Parameter(Mandatory)]
        [string]
        $FileName,
        [Parameter()]
        [switch]
        $AddStringIDs = $false
    )

    $changelog = [System.Collections.Generic.List[pscustomobject]]::new()

    foreach ($change in $ChangesOfficial) {
        $index = $change.Index
        if ($AddStringIDs) {
            $new_string = "{0}_{1}" -f $index, $change.New
        } else {
            $new_string = ''
        }

        # New string
        if ($change.Old -eq '[N/A]') {
            $changelog.Add([pscustomobject]@{
                File  = $FileName
                Index = $index
                Old   = '[N/A]'
                New   = ''
            })

            # Uncomment if your translation tool requires the target string to exist
            # $TableCurrent.Add($index, [pscustomobject]@{
            #     String = $change.New
            #     State  = $STRING_STATE_NOT_TRANSLATED
            # })

            continue
        }

        # Removed string
        if ($change.New -eq '[Removed]') {
            $changelog.Add([pscustomobject]@{
                File  = $FileName
                Index = $index
                Old   = $TableCurrent[$index].String
                New   = '[Removed]'
            })

            $null = $TableCurrent.Remove($index)
            continue
        }

        # Changed translated string
        if ($TableCurrent.ContainsKey($index) -and $TableCurrent[$index].String) {
            $changelog.Add([pscustomobject]@{
                File  = $FileName
                Index = $index
                Old   = $TableCurrent[$index].String
                New   = $new_string
            })

            $TableCurrent[$index].String = $new_string
            $TableCurrent[$index].State  = $STRING_STATE_NOT_TRANSLATED
            continue
        }
    }

    return ,$changelog
}

$LANGUAGES_OFFICIAL = [LanguageCodes].GetEnumNames()


# Start importing stuff
$ErrorActionPreference_before = $ErrorActionPreference
$ErrorActionPreference = 'Stop'

try {
    Import-Module -Name "./lib/file_types/$FileType.psm1"
    $CONFIG           = Import-PowerShellDataFile -Path "./config/config.psd1"
    $CONVERSION_LISTS = Import-PowerShellDataFile -Path "./config/conversion_lists.psd1"
}
catch {
    $ErrorActionPreference = $ErrorActionPreference_before
    $_
    return 2
}

$ErrorActionPreference = $ErrorActionPreference_before
# End of importing stuff

$InformationPreference = 'Continue'
if ($CONFIG.VERBOSE) {
    $VerbosePreference = 'Continue'
} else {
    $VerbosePreference = 'SilentlyContinue'
}



if ($CurrentVersion -eq 'latest') {
    Write-Error "Current version can't be 'latest'"
    return 2
} else {
    $dump_dir_current = "{0}/{1}" -f $CONFIG.DUMP_DIR, $CurrentVersion
    if (-not $(Test-Path -Path $dump_dir_current)) {
        throw "Version $CurrentVersion was not found in dump folder."
    }
}
Write-Information "Current version path: $dump_dir_current"

if ($NewVersion -eq 'latest') {
    $version_list = Get-ChildItem -Path $CONFIG.DUMP_DIR -Directory
    $dump_dir_new = $version_list[-1]

    $version_regex = '\d{4}\.\d{2}\.\d{2}\.\d{4}\.\d{4}'
    $found = $dump_dir_new.FullName -match $version_regex
    if ($found) {
        if ($Matches.Count -ne 1) {
            Write-Error "Parsed more than one version numbers from the following path:"
            Write-Error "  $dump_dir_new"
            Write-Error "Please specify the new version explicitly."
            throw
        }
        $NewVersion = $Matches[0]
    } else {
        throw "Couldn't parse latest version number"
    }
} else {
    $dump_dir_new = "{0}/{1}" -f $CONFIG.DUMP_DIR, $NewVersion
    if (-not $(Test-Path -Path $dump_dir_new)) {
        throw "Version $NewVersion was not found in dump folder."
    }
}
Write-Information "New version path:     $dump_dir_new"

# Make a normal array of all split files
$split_files = foreach ($split_file in $CONVERSION_LISTS.SPLIT_FILES.GetEnumerator()) {
    foreach ($file_name in [string[]] $split_file.Value.Keys) {
        $file_name
    }
}


Write-Information "Getting all new version EXHs..."
$new_exh_list = Get-ChildItem -Path "$dump_dir_new/*.exh" -Recurse -File
Write-Information "Done."

if ($DryRun) {
    Write-Information "This is a dry run - no actual changes to the strings files will be made."
}


# This table contains lists that document all of the encountered changes.
# Each of these lists will be exported as a CSV table if they are not
# empty.
# Note that these tables are monolingual. If you want to have a bilingual one
# (probably for unofficial langauges so that you could see what changed
# in the source strings), you'd have to combine them separately. It can
# be done via Combine-Changelogs.ps1 in the `tools` folder.
# [PSCustomObject] structure:
#   * File
#   * Index
#   * Old
#   * New
$changelog_tables = @{}
foreach ($lang in $LANGUAGES_OFFICIAL) {
    $changelog_tables.$lang = [System.Collections.Generic.List[pscustomobject]]::new()
}

foreach ($new_exh_file in $new_exh_list) {
    # Set up readable paths
    $file_name = $new_exh_file.BaseName
    $sub_path  = $new_exh_file.Directory.FullName.Replace("$dump_dir_new/", '') -creplace '/$',''

    $current_exh_path = $new_exh_file.FullName.Replace($NewVersion, $CurrentVersion)
    $new_exh_path     = $new_exh_file.FullName
    $game_path        = "{0}/{1}" -f $sub_path, $file_name
    $strings_dir_path = "{0}/{1}/{2}" -f $CONFIG.STRINGS_DIR, $sub_path, $file_name

    $log_prefix = "{0}:" -f $game_path

    # Skip non-language EXHs right away
    $new_exh = [EXHF]::new($new_exh_path)
    if ($new_exh.IsLanguageDeclared('none')) {
        Write-Verbose "$log_prefix Non-language file, skipping - $new_exh_path"
        continue
    }


    $lang_needs_to_be_updated = @{}
    foreach ($lang in $LANGUAGES_OFFICIAL) {
        $lang_needs_to_be_updated.$lang = $false
    }
    $next_file_flag = $false

    # Step 1: EXH comparison
    switch (Compare-Files -File1 $current_exh_path -File2 $new_exh_path) {
        $COMPARISON_FILES_SAME {
            # Proceed to EXD checks by doing nothing

            Write-Verbose "$log_prefix EXH didn't change - $new_exh_path"
            break
        }
        $COMPARISON_FILES_DIFFERENT {
            # Skip EXD checks by flagging all languages for conversion

            Write-Information "$log_prefix EXH changed - $new_exh_path"
            foreach ($lang in $LANGUAGES_OFFICIAL) {
                $lang_needs_to_be_updated.$lang = $true
            }
            break
        }
        $global:COMPARISON_ONLY_FILE1_EXISTS {
            # Remove associated strings files and proceed to the next EXH

            Write-Information "$log_prefix EXH removed - $current_exh_path"
            $search_string = "{0}/*.{1}" -f $strings_dir_path, (Get-StringsFileExtension)
            $files_to_delete = Get-ChildItem -Path $search_string -File

            Write-Verbose "The following strings files will be deleted:"
            foreach ($file in $files_to_delete) {
                $lang = $file.BaseName
                $changelog.$lang.Add([pscustomobject]@{
                    File = $game_path
                    Index = ''
                    Old = ''
                    New = '[Removed]'
                })

                Write-Verbose "  * $file"
            }

            if (-not $DryRun) {
                $files_to_delete | Remove-Item
            }
            $next_file_flag = $true
            break
        }
        $COMPARISON_ONLY_FILE2_EXISTS {
            # Convert all new files and proceed to the next EXH

            Write-Information "$log_prefix New EXH - $new_exh_path"

            if (-not $DryRun) {
                $result = ./ConvertFrom-GameData.ps1 -ExhPath $new_exh_path `
                -FileType $FileType `
                -Destination $strings_dir_path
            
                if ($result -eq 2) {
                    throw "$log_prefix Critical error during conversion"
                }            
            }

            foreach ($lang in $LANGUAGES_OFFICIAL) {
                $strings_file_path = "{0}/{1}.{2}" -f $strings_dir_path, $lang, (Get-StringsFileExtension)
                if (Test-Path -Path $strings_file_path) {
                    $changelog_tables.$lang.Add([pscustomobject]@{
                        File = $game_path
                        Index = ''
                        Old = ''
                        New = '[Added]'
                    })
                }
            }

            $next_file_flag = $true
            break
        }
        $COMPARISON_FILES_DONT_EXIST {
            Write-Error "$log_prefix Both EXHs don't exist. This shouldn't happen. Debug info:"
            Write-Error "Current EXH path: $current_exh_path"
            Write-Error "New EXH path:     $new_exh_path"
            throw
        }      
    }
    if ($next_file_flag) {
        continue
    }

    # Step 2. EXD comparison

    # $new_exh was already created before
    $current_exh = [EXHF]::new($current_exh_path)

    foreach ($lang in $LANGUAGES_OFFICIAL) {
        if (-not $new_exh.IsLanguageDeclared($lang)) {
            continue
        }
        $log_prefix_lang = "{0}: ({1})" -f $game_path, $lang.ToUpper()

        # Go through EXDs if a language wasn't marked for update earlier
        if (-not $lang_needs_to_be_updated.$lang) {
            foreach ($page in $new_exh.PageTable.GetEnumerator()) {
                $current_exd_path = $current_exh.GetEXDPath($page.Key, $lang)
                $new_exd_path = $new_exh.GetEXDPath($page.Key, $lang)

                $log_prefix_exd = "{0}: ({1} #{2})" -f $game_path, $lang.ToUpper(), $page.Key

                switch (Compare-Files -File1 $current_exd_path -File2 $new_exd_path) {
                    $COMPARISON_FILES_SAME {
                        Write-Verbose "$log_prefix_exd EXD page didn't change - $new_exd_path"
                        break
                    }
                    $COMPARISON_FILES_DIFFERENT {
                        Write-Information "$log_prefix_exd EXD page changed - $new_exd_path"
                        $lang_needs_to_be_updated.$lang = $true
                        break
                    }
                    $global:COMPARISON_ONLY_FILE1_EXISTS {
                        Write-Information "$log_prefix_exd EXD page removed - $current_exd_path"
                        $lang_needs_to_be_updated.$lang = $true
                        break
                    }
                    $COMPARISON_ONLY_FILE2_EXISTS {
                        Write-Information "$log_prefix_exd EXD page added - $new_exd_path"
                        $lang_needs_to_be_updated.$lang = $true
                        break
                    }
                    $COMPARISON_FILES_DONT_EXIST {
                        Write-Warning "$log_prefix_exd Both EXD pages don't exist"
                        break
                    }
                }

                # Whenever there's a change in any of EXDs, quit this loop
                # and start updating.
                if ($lang_needs_to_be_updated.$lang) {
                    break
                }
            }
        }

        # But if the language is not marked for update even after the loop,
        # proceed to the next language.
        if (-not $lang_needs_to_be_updated.$lang) {
            Write-Information "$log_prefix_lang No changes"
            continue
        }

        # Step 3. Strings file(s) update

        # First we deal with the current official language.
        # For 'Memory' output type -Destination is not used, but since it's
        # required, we're passing some string.
        # TODO: Make sense of ParameterSets so that this minor workaround
        #       wouldn't be required.
        # We're also disabling verbosity for these commands,
        # otherwise logs would be full of 'Loading module', etc.

        # In regards to split file feature:
        #   * ConvertFrom-GameData with -FileType Memory returns table(s)
        #     in a hashtable
        #   * Each key in this hashtable is a file name
        #   * For split files a key is a split file name
        #   * For normal files hashtable would have a single entry
        #     with the normal file name
        #   * This way the Update script will treat each split file
        #     as a separate file

        $table_current = ./ConvertFrom-GameData.ps1 `
            -ExhPath $current_exh_path `
            -FileType Memory `
            -Languages $lang `
            -Destination '.' `
            -Verbose:$false
        $table_new = ./ConvertFrom-GameData.ps1 `
            -ExhPath $new_exh_path `
            -FileType Memory `
            -Languages $lang `
            -Destination '.' `
            -Verbose:$false

        # Btw we're assuming that both tables will have the same keys
        foreach ($table_name in [string[]] $table_current.Keys) {
            # Set up some paths again if the file is actually split
            if ($table_name -in $split_files) {
                $game_path        = "{0}/{1}/{2}" -f $sub_path, $file_name, $table_name
                $log_prefix_lang  = "{0}: ({1})" -f $game_path, $lang.ToUpper()
                $strings_dir_path = "{0}/{1}/{2}/{3}" -f $CONFIG.STRINGS_DIR, $sub_path, $file_name, $table_name
            }

            if (-not ($table_current.$table_name.Count -or $table_new.$table_name.Count)) {
                Write-Warning "$log_prefix_lang Empty tables, skipping"
                continue
            }

            $changes = Update-StringsOfficial `
                -TableCurrent $table_current.$table_name `
                -TableNew $table_new.$table_name `
                -FileName $table_name
            $changelog_tables.$lang.AddRange( $changes )
            Write-Information "$log_prefix_lang $($changes.Count) strings changed"

            if (-not $DryRun) {
                $null = New-Item -Path $strings_dir_path -ItemType Directory -Force -ErrorAction Ignore
                $error_code = Export-Strings -Table $table_new.$table_name `
                    -TargetLanguage $lang `
                    -Destination $strings_dir_path `
                    -Compress:$Compress
                if ($error_code) {
                    Write-Error ("$log_prefix Failed to export {0} strings to {1}" -f $lang.ToUpper(), $strings_dir_path)
                    continue
                }
            }

            # If current language is the main source languaes,
            # we also need to update unofficial languages.
            # Since we already have a list of changes, we can
            # just go through it and apply the same changes
            # to unofficial languages.
            if ($lang -eq $CONFIG.MAIN_SOURCE_LANGUAGE -and $changes) {
                $search_string = "{0}/*.{1}" -f $strings_dir_path, (Get-StringsFileExtension)
                if ($DryRun -and -not (Test-Path -Path $search_string)) {
                    Write-Verbose "$log_prefix_lang Unofficial language scan skipped - strings folder doesn't exist yet"
                    continue
                }
                $strings_file_list = Get-ChildItem -Path $search_string -File

                foreach ($strings_file in $strings_file_list) {
                    if ($strings_file.BaseName -in $LANGUAGES_OFFICIAL) {
                        continue
                    }

                    $lang_un = $strings_file.BaseName
                    Write-Verbose ("$log_prefix Found {0} file at {1}" -f $lang_un.ToUpper(), $strings_file)
                    if (-not $changelog_tables.$lang_un) {
                        $changelog_tables.$lang_un = [System.Collections.Generic.List[pscustomobject]]::new()
                    }
                    $log_prefix_lang_un = "{0}: ({1})" -f $game_path, $lang_un.ToUpper()

                    # Remove cache file to force file conversion
                    $cache_file_path = "{0}/{1}/{2}/{3}.{4}.time" -f `
                        $CONFIG.CACHE_DIR, $game_path, $file_name, $lang_un, (Get-StringsFileExtension)
                    if (Test-Path -Path $cache_file_path) {
                        Write-Verbose "$log_prefix_lang_un Removing cache at $cache_file_path"
                        Remove-Item -Path $cache_file_path -ErrorAction Ignore
                    }

                    $table_current_un = Import-Strings -Path $strings_file
                    $add_string_ids = $file_name -in $CONVERSION_LISTS.ADD_IDS_ON_UPDATE

                    $changes_un = Update-StringsUnofficial `
                        -TableCurrent $table_current_un `
                        -ChangesOfficial $changes `
                        -FileName $table_name `
                        -AddStringIDs:$add_string_ids
                    $changelog_tables.$lang_un.AddRange( $changes_un )
                    Write-Information "$log_prefix_lang_un $($changes_un.Count) strings changed"

                    if (-not $DryRun) {
                        $null = New-Item -Path $strings_dir_path -ItemType Directory -Force -ErrorAction Ignore
                        $error_code = Export-Strings -Table $table_current_un `
                            -TargetLanguage $lang_un `
                            -Destination $strings_dir_path `
                            -Compress:$Compress
                        if ($error_code) {
                            Write-Error "$log_prefix_lang_un Failed to export strings to $strings_dir_path"
                            continue
                        }
                    }
                }
            }
        }
    }
}

$GAME_VERSIONS = Get-Content -Path "./versions_list.txt" | ConvertFrom-StringData
foreach ($changelog_table in $changelog_tables.GetEnumerator()) {
    if ($changelog_table.Value.Count -gt 0) {
        $changelog_dir  = "./changelogs/{0}->{1}" -f $GAME_VERSIONS.$CurrentVersion, $GAME_VERSIONS.$NewVersion
        $changelog_path = "$changelog_dir/{0}.csv" -f $changelog_table.Key

        $null = New-Item -Path $changelog_dir -ItemType Directory -ErrorAction Ignore
        $changelog_table.Value | Export-Csv -Path $changelog_path -Encoding utf8NoBOM
        Write-Information ("{0} changelog exported to {1}" -f $changelog_table.Key.ToUpper(), $changelog_path)
    }
}
