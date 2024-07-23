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

    $target_path = Get-TargetPath -Path $Destination -Language $TargetLanguage
    $file_name = $Destination.BaseName

    $xml_settings = [System.Xml.XmlWriterSettings]::new()
    $xml_settings.Indent = $true

    $xliff = [System.Xml.XmlWriter]::Create($target_path, $xml_settings)

    # Normal WriteStartDocument() makes lower-case 'utf-8'. Apparently,
    # Weblate doesn't like and it corrects it to an uppercase one, generating
    # a shit ton of commits, so we're putting in uppercase 'UTF-8' manually.
    $xliff.WriteProcessingInstruction('xml', 'version="1.0" encoding="UTF-8"');
    $xliff.WriteStartElement('xliff')
    $xliff.WriteAttributeString('version', '1.2')

    $xliff.WriteStartElement('file')
    $xliff.WriteAttributeString('original', $file_name)
    $xliff.WriteAttributeString('datatype', 'plaintext')
    $xliff.WriteAttributeString('source-language', 'en')
    $xliff.WriteAttributeString('target-language', $TargetLanguage)

    $xliff.WriteStartElement('body')

    foreach ($row in $Table.GetEnumerator()) {
        $index = $row.Key
        $string = $row.Value.String
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

        $xliff.WriteStartElement('trans-unit')
        $xliff.WriteAttributeString('id', $index)
        if ($approved) {
            $xliff.WriteAttributeString('approved', $approved)
        }

        $xliff.WriteStartElement('source')
        $xliff.WriteString($index)
        $xliff.WriteEndElement() # source

        $xliff.WriteStartElement('target')
        if ($state) {
            $xliff.WriteAttributeString('state', $state)
        }
        $xliff.WriteAttributeString('xml', 'space', $null, 'preserve')
        $xliff.WriteString($string)
        $xliff.WriteEndElement() # target

        $xliff.WriteEndElement() # trans-unit
    }

    $xliff.WriteEndDocument()
    $xliff.Close()

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
        $state = $STRING_STATE_NOT_TRANSLATED

        if ($unit.HasAttribute('approved') -and $unit.approved -eq 'yes') {
            $state = $STRING_STATE_APPROVED
        } elseif ($unit.target.state -eq 'translated') {
            $state = $STRING_STATE_TRANSLATED
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
