# Since the middle of Endwalker, SE started to seemingly regenerate CompleteJournal
# from scratch every semi-major patch. It causes all of the translated strings to be
# lost after running Update-GameData. This script restores CompleteJournal's translations.

# This script requires:
#   - Old EN strings file
#   - Old RU strings file
#   - New EN strings file
#   - New RU strings file

# This script was designed specifically for Russian language with XLIFF file format.

[CmdletBinding()]
param (
	[Parameter(Mandatory)]
	[string]
	$OldEnStringsPath,
	[Parameter(Mandatory)]
	[string]
	$OldRuStringsPath,
	[Parameter(Mandatory)]
	[string]
	$NewEnStringsPath,
	[Parameter(Mandatory)]
	[string]
	$NewRuStringsPath,
	[Parameter(Mandatory)]
	[string]
	$Destination
)

Import-Module -Name "./lib/file_types/XLIFFMonolingual.psm1" -ErrorAction Stop

$en_old_table = Import-Strings -Path $OldEnStringsPath
$ru_old_table = Import-Strings -Path $OldRuStringsPath
$en_new_table = Import-Strings -Path $NewEnStringsPath
$ru_new_table = Import-Strings -Path $NewRuStringsPath

$translated_strings_list = [System.Collections.Generic.Dictionary[string,string]]::new()
foreach ($ru_old_row in $ru_old_table.GetEnumerator()) {
	$index = $ru_old_row.Key
	$old_source = $en_old_table.$index.String
	$old_translation = $ru_old_table.$index.String

	if ($ru_old_row.Value.String -match '[А-Яа-яЁё]' -and -not $translated_strings_list.ContainsKey($old_source)) {
		$translated_strings_list.Add($old_source, $old_translation)
	}
}

foreach ($en_new_row in $en_new_table.GetEnumerator()) {
	$index = $en_new_row.Key
	$en_string = $en_new_row.Value.String

	if ($translated_strings_list.ContainsKey($en_string)) {
		$ru_string = $translated_strings_list.$en_string

		$null = $ru_new_table.Remove($index)
		$ru_new_table.Add(
			$index,
			[pscustomobject]@{
				String = $ru_string
				State  = $STRING_STATE_TRANSLATED
			}
		)
	}
}

$error_code = Export-Strings -Table $ru_new_table -TargetLanguage 'ru' -Destination $Destination
if ($error_code) {
	Write-Error 'Error while exporting the strings'
	return 1
}

Write-Information "Exported to $Destination/ru.xlf" -InformationAction Continue
return 0
