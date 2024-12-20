# Returns:
# 0 - Success
# 1 - Error during Get REST method (wrong token?)
# 2 - Error during Patch REST method

function Get-ApiString ([hashtable] $Var, [int] $Row, [switch] $Plain, [switch] $Target) {
    $array_row = $Var[$Row]
    $string = $Target ? $array_row.target[0] : $array_row.source[0]

    return $string
}



# Start importing stuff
$ErrorActionPreference_before = $ErrorActionPreference
$ErrorActionPreference = 'Stop'

$WEBLATE = Import-PowerShellDataFile -Path "config/weblate.psd1"
$token = ConvertTo-SecureString -String $WEBLATE.TOKEN -AsPlainText -Force

$ErrorActionPreference = $ErrorActionPreference_before
# Finish importing stuff
$InformationPreference_before = $InformationPreference
$InformationPreference = 'Continue'

# 1. Get files ContentFinderCondition and ContentFinderConditionTransient
# 2. Go through ContentFinderConditionTransient
# 3. If target string start with '[Если', continue
# 4. Get source string from ContentFinderCondition with the same ID
# 5. Add this: 
# @"
# [Если вы захотите для прохождения этого подземелья заручиться поддержкой других игроков, его оригинальное название — $(source string)]
# 
# 
# "@
# 6. Send the change

$STRING_W_SOURCE_DUTY_NAME = @"
[Если вы захотите для прохождения этого подземелья заручиться поддержкой других игроков, его оригинальное название — `{0`}]


"@


'Getting components through REST API:'
$ImportApi = @(
    'ContentFinderCondition',
    'ContentFinderConditionTransient'
)

$API_RESULTS = @{}
try {
    foreach ($file_name in $ImportApi) {
        $API_RESULTS.$file_name = @{}
        Write-Information "- $file_name..."

        $url = "https://{0}/api/translations/{1}/{2}/ru/units/" `
            -f $WEBLATE.URI, $WEBLATE.PROJECT_SLUG, $file_name.ToLower()		
        do {
            $reply = Invoke-RestMethod `
                -Method Get `
                -Uri $url `
                -Authentication Bearer `
                -Token $token
            foreach ($result in $reply.results) {
                [int] $id = $result.context -creplace '^.+///', ''
                $API_RESULTS.$file_name.$id = $result
            }
            $url = $reply.next
        } while ( $url )
        Write-Information '  Done.'
    }
}
catch {
    Write-Error 'Error during GET:'
    $Error[1]
    $InformationPreference = $InformationPreference_before
    return 1
}


foreach ($row in $API_RESULTS.ContentFinderConditionTransient.GetEnumerator()) {
    $context        = $row.Key
    [int] $id       = $context -creplace '^.*///', ''
    $transient_unit = $row.Value

    if ($API_RESULTS.ContentFinderCondition.$id.target[0] -cnotmatch '[А-Яа-яËё]') {
        Write-Information "$context - Duty name is not translated."
        continue
    }

    if ($transient_unit.target[0].StartsWith('[Если'))  {
        Write-Information "$context - Already done."
        continue
    }

    Write-Information "$context - Needs change."

    $duty_name         = $API_RESULTS.ContentFinderCondition.$id.source[0] -creplace '<tab>.*',''
    $string            = $STRING_W_SOURCE_DUTY_NAME -f $duty_name
    $new_target_string = $string + $transient_unit.target[0]

    Write-Information "$context - Duty name: $duty_name"

    $url = "https://{0}/api/units/{1}/" -f $WEBLATE.URI, $transient_unit.id
    $body = @{
        state  = $transient_unit.state ? $transient_unit.state : 10
        target = @( $new_target_string )
    } | ConvertTo-Json

    try {
        $reply = Invoke-RestMethod `
            -Method Patch `
            -Uri $url `
            -Authentication Bearer `
            -Token $token `
            -ContentType 'application/json' `
            -Body $body

        Write-Information "$context - Done."
    }
    catch {
        Write-Error 'Error during PATCH:'
        $Error[1]
        $InformationPreference = $InformationPreference_before
        return 2
    }
}

$InformationPreference = $InformationPreference_before
return 0