[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string]
    $ChangelogPathSource,
    [Parameter(Mandatory)]
    [string]
    $ChangelogPathTarget
)

$changelog_source = Import-Csv -Path $ChangelogPathSource -Encoding utf8NoBOM
$changelog_source_lang = Split-Path -Path $ChangelogPathSource -LeafBase

$changelog_target = Import-Csv -Path $ChangelogPathTarget -Encoding utf8NoBOM
$changelog_target_lang = Split-Path -Path $ChangelogPathTarget -LeafBase

$changelog_dir = Split-Path -Path $ChangelogPathSource -Parent
$changelog_combined_path = "{0}/{1}_{2}.csv" -f $changelog_dir, $changelog_source_lang, $changelog_target_lang

$progress_activity = "Combining {0} and {1}..." -f $changelog_source_lang.ToUpper(), $changelog_target_lang.ToUpper()

$changelog_combined = [System.Collections.Generic.List[pscustomobject]]::new()
$i = 0
foreach ($target_row in $changelog_target) {
    while (
        ($changelog_source[$i].File -ne $target_row.File) -or
        ($changelog_source[$i].Index -ne $target_row.Index)
    ) {
        $i++
    }

    $changelog_combined.Add([pscustomobject]@{
        File = $target_row.File
        Index = $target_row.Index
        'Old Source' = $changelog_source[$i].Old
        'New Source' = $changelog_source[$i].New
        'Old Translation' = $target_row.Old
        # 'New Translation' = $target_row.New   # It's probably empty anyway
    })

    [int] $percent = ($i / $changelog_source.Count) * 100
    Write-Progress -Activity $progress_activity `
        -Status "$percent% Complete" `
        -PercentComplete $percent
}

Write-Progress -Activity $progress_activity -Completed

$changelog_combined | Export-Csv -Path $changelog_combined_path -Encoding utf8NoBOM
