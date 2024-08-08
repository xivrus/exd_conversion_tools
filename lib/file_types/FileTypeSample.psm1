# NOT ACTUAL FILE TYPE
# This is a template for creating other file types.
# It contains all functions that this module must contain.
#
# To create and use a new file type:
#   1. Copy this file and name it after your desired file type
#   2. Write code for functions below
#   3. For conversion scripts use file name as a -FileType argument

# This module contains global variables - we'll need STRING_STATE ones
Import-Module -Name "./lib/Engine.psm1" -ErrorAction Stop

# Must assemble and return expected path for the strings file
# of a specified language
function Get-TargetPath {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.IO.DirectoryInfo]
        $Path,
        [Parameter(Mandatory)]
        [string]
        $Language
    )
    return "{0}/{1}" -f $Path.FullName, "$Language.xlf"
}

# Must return file extension of the strings file
function Get-StringsFileExtension {
    return ""    
}

# Must return 0 on success and 1 on error
function Export-Strings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Collections.Generic.SortedDictionary[int,pscustomobject]]
        $Table,
        [Parameter()]
        [string]
        $SourceLanguage = 'en',
        [Parameter(Mandatory)]
        [string]
        $TargetLanguage,
        [Parameter(Mandatory)]
        [System.IO.DirectoryInfo]
        $Destination,
        [Parameter()]
        [switch]
        $Compress = $false
    )

    try {
        # Save attempt
    }
    catch {
        return 1
    }
    return 0
}

# Must return table of type:
#    [System.Collections.Generic.SortedDictionary[int,pscustomobject]]
# where [int] is index and each [pscustomobject] is:
#    @{
#        String = <string>
#        State  = <one_of_STRING_STATE_constants>
#    }
# You can check STRING_STATE constants in Engine.psm1
function Import-Strings {
    param (
        [Parameter()]
        [System.IO.FileInfo]
        $Path
    )

    $result = [System.Collections.Generic.SortedDictionary[int,pscustomobject]]::new()

    # Function body

    return $result
}
