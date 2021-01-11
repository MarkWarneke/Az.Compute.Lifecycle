function Get-TimeFromTags {
    [CmdletBinding()]
    param (
        $Tags
    )

    begin {

    }

    process {
        $Datetime = Get-Date
        $UTCTimeActual = $Datetime.ToUniversalTime()
        Write-Verbose "[$(Get-Date)] Actual Time (UTC) is $UTCTimeActual"

        $UTCOffset = [INT]$Tags[$script:CONFIG.TAGS.POWER_OFF_OFFSET] * -1
        Write-Verbose "[$(Get-Date)] UTC Offset of $($VM.Name) is $UTCOffset"

        # Determine Shut Down Time
        $LocalStopString = $Tags[$script:CONFIG.TAGS.POWER_OFF]
        $LocalStopTime = Get-Date $LocalStopString
        $UTCStopTime = $LocalStopTime.AddHours($UTCOffset)
        Write-Verbose "[$(Get-Date)] Stop Time (UTC) of $($VM.Name) is $UTCStopTime"

        # Determine Start Time
        $LocalStartString = $Tags[$script:CONFIG.TAGS.POWER_ON]
        $LocalStartTime = Get-Date $LocalStartString
        $UTCStartTime = $LocalStartTime.AddHours($UTCOffset)
        Write-Verbose "[$(Get-Date)] Start Time (UTC) of $($VM.Name) is $UTCStartTime"

        return [PSCustomObject]@{
            UTCTimeActual = $UTCTimeActual
            UTCStartTime  = $UTCStartTime
            UTCStopTime   = $UTCStopTime
        }
    }

    end {

    }
}