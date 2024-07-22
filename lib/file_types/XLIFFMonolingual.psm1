Import-Module -Name "./lib/Engine.psm1" -ErrorAction Stop

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

function Get-StringsFileExtension {
    return "xlf"    
}

function Export-Strings {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [System.Collections.Generic.SortedDictionary[int,pscustomobject]]
        $Table,
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
    # Templates and variables to fill:
    # - template.xlf - header and footer
    #   {{ target_lang }}
    #   {{ file_name }}
    #   {{ body }}
    # - template_trans-unit.xlf - units for body
    #   {{ index }}
    #   {{ approved }} - yes / no
    #   {{ state }} - needs-translation / translated / final
    #   {{ string }} - need to encode to HTML
    #   Notes for Weblate:
    #     * "Approved" is set only via
    #         approved="yes"
    #     * "Needs edititng" is set only via
    #         state="needs-translation"
    #     * Having neither of those while <target> exists means "Waiting for review"

    $xliff = [xml]::new()
    if ($Compress) {
        $xliff.PreserveWhitespace = $true
    }
    $template = Get-Content -Path './lib/file_types/XLIFFMonolingual/template.xlf' `
        -Raw -ReadCount 0 -ErrorAction Stop
    $xliff.LoadXml($template)

    $xliff.xliff.file.original = $Destination.BaseName
    $xliff.xliff.file.'target-language' = $TargetLanguage

    foreach ( $row in $Table.GetEnumerator() ) {
        switch ($row.Value.State) {
            $STRING_STATE_NOT_TRANSLATED {
                if ($row.Value.String -eq '') {
                    $approved = ''
                    $state    = ''
                } else {
                    $approved = 'no'
                    $state    = 'needs-translation'
                }
                break
            }
            $STRING_STATE_TRANSLATED {
                $approved = 'no'
                $state    = 'translated'
                break
            }
            $STRING_STATE_APPROVED {
                $approved = 'yes'
                $state    = 'final'
                break
            }
            default {
                $approved = ''
                $state    = ''
                break
            }
        }

        $trans_unit = $xliff.CreateElement('trans-unit')

        $trans_unit_id = $xliff.CreateAttribute('id')
        $trans_unit_id.InnerText = $row.Key

        if ($approved) {
            $trans_unit_approved = $xliff.CreateAttribute('approved')
            $trans_unit_approved.InnerText = $approved
        }

        $trans_unit_source = $xliff.CreateElement('source')
        $trans_unit_source_text = $xliff.CreateTextNode( $row.Key )
        $null = $trans_unit_source.AppendChild( $trans_unit_source_text )

        $trans_unit_target = $xliff.CreateElement('target')
        if ($state) {
            $trans_unit_target_state = $xliff.CreateAttribute('state')
            $trans_unit_target_state.InnerText = $state

            $null = $trans_unit_target.Attributes.Append($trans_unit_target_state)
        }
        $trans_unit_target_text = $xliff.CreateTextNode( $row.Value.String )
        $null = $trans_unit_target.AppendChild( $trans_unit_target_text )

        $null = $trans_unit.Attributes.Append($trans_unit_id)
        if ($approved) {
            $null = $trans_unit.Attributes.Append($trans_unit_approved)
        }
        $null = $trans_unit.AppendChild( $trans_unit_source )
        $null = $trans_unit.AppendChild( $trans_unit_target )

        $null = $xliff.xliff.file.body.AppendChild( $trans_unit )
    }

    $element_to_remove = $xliff.SelectSingleNode('xliff/file/body/remove')
    $null = $xliff.xliff.file.body.RemoveChild($element_to_remove)

    $target_path = Get-TargetPath -Path $Destination -Language $TargetLanguage
    try {
        $xliff.Save($target_path)
    }
    catch {
        return 1
    }
    return 0
}

function Import-Strings {
    param (
        [Parameter()]
        [System.IO.FileInfo]
        $Path
    )

    [xml] $input_file = Get-Content -Path $Path -Encoding utf8NoBOM

    $result = [System.Collections.Generic.SortedDictionary[int,pscustomobject]]::new()
    foreach ($unit in $input_file.xliff.file.body.'trans-unit') {
        $string = $unit.target.GetType() -eq [string] ? $unit.target : $unit.target.'#text'
        if ($unit.approved -eq 'yes') {
            $state = $STRING_STATE_APPROVED
        } elseif ($unit.target.state -eq 'translated') {
            $state = $STRING_STATE_TRANSLATED
        } else {
            $state = $STRING_STATE_NOT_TRANSLATED
        }

        $result.Add(
            [int] $unit.id,
            [PSCustomObject]@{
                String = $string
                State  = $state
            }
        )
    }

    return $result
}
