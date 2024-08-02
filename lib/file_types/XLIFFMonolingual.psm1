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

    if (-not (Test-Path -Path $Destination)) {
        Write-Error "Destination does not exist - $Destination"
        return 1
    }

    $target_path = Get-TargetPath -Path $Destination -Language $TargetLanguage
    $file_name = $Destination.BaseName

    $xml_writer_settings = [System.Xml.XmlWriterSettings]::new()
    $xml_writer_settings.Indent = $true

    $xliff_writer = [System.Xml.XmlWriter]::Create($target_path, $xml_writer_settings)

    # Normal WriteStartDocument() makes lower-case 'utf-8'. Apparently,
    # Weblate doesn't like and it corrects it to an uppercase one, generating
    # a shit ton of commits, so we're putting in uppercase 'UTF-8' manually.
    $xliff_writer.WriteProcessingInstruction('xml', 'version="1.0" encoding="UTF-8"');
    $xliff_writer.WriteStartElement('xliff')
    $xliff_writer.WriteAttributeString('version', '1.2')

    $xliff_writer.WriteStartElement('file')
    $xliff_writer.WriteAttributeString('original', $file_name)
    $xliff_writer.WriteAttributeString('datatype', 'plaintext')
    $xliff_writer.WriteAttributeString('source-language', 'en')
    $xliff_writer.WriteAttributeString('target-language', $TargetLanguage)

    $xliff_writer.WriteStartElement('body')

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

        $xliff_writer.WriteStartElement('trans-unit')
        $xliff_writer.WriteAttributeString('id', $index)
        if ($approved) {
            $xliff_writer.WriteAttributeString('approved', $approved)
        }

        $xliff_writer.WriteStartElement('source')
        $xliff_writer.WriteString($index)
        $xliff_writer.WriteEndElement() # source

        $xliff_writer.WriteStartElement('target')
        if ($state) {
            $xliff_writer.WriteAttributeString('state', $state)
        }
        $xliff_writer.WriteAttributeString('xml', 'space', $null, 'preserve')
        $xliff_writer.WriteString($string)
        $xliff_writer.WriteEndElement() # target

        $xliff_writer.WriteEndElement() # trans-unit
    }

    $xliff_writer.WriteEndDocument()
    $xliff_writer.Close()

    return 0
}

function Import-Strings {
    param (
        [Parameter()]
        [System.IO.FileInfo]
        $Path
    )

    $xliff_reader = [System.Xml.XmlReader]::Create($Path)

    $table = [System.Collections.Generic.SortedDictionary[int,pscustomobject]]::new()
    while ($xliff_reader.ReadToFollowing('trans-unit')) {
        $id = [int] $xliff_reader.GetAttribute('id')
        $state = $STRING_STATE_NOT_TRANSLATED

        if ($xliff_reader.GetAttribute('approved') -eq 'yes') {
            $state = $STRING_STATE_APPROVED
        }

        $null = $xliff_reader.ReadToFollowing('target')
        if ($xliff_reader.GetAttribute('state') -eq 'translated') {
            $state = $STRING_STATE_TRANSLATED
        }
        $string = $xliff_reader.ReadElementContentAsString()

        $table.Add(
            $id,
            [PSCustomObject]@{
                String = $string
                State  = $state
            }
        )
    }

    $xliff_reader.Close()
    return $table
}
