function Stop-Vm {
    <#
    .SYNOPSIS
    Stops all VMs found in  a given session based on the tags provided.

    .DESCRIPTION
    Stops all VMs found in  a given session based on the tags provided.
    Checks for each VM if they are Running, but have a tag `ManuallyStopped`.
    For each VM check the `PowerOnTime` and `PowerOffTime` and convert the values into a date.
    Compares the current date with the Power Times and if the current date is outside the `PowerOnTime` window, stop the VM

    .EXAMPLE
    Stop-VM

    .NOTES
    This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.

    **THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED AS IS**
    **WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED**
    **TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.**

    We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and
    to reproduce and distribute the object code form of the Sample Code,
    provided that You agree:
    1.  To not use Our name, logo, or trademarks to market Your software
            product in which the Sample Code is embedded;
    2. Include a valid copyright notice on Your software product in which
            the Sample Code is embedded; and
    3. To indemnify, hold harmless, and defend Us and Our suppliers from and
            against any claims or lawsuits, including attorneys' fees, that arise
            or result from the use or distribution of the Sample Code.

    Please note: None of the conditions outlined in the disclaimer above will supersede terms and conditions contained within the Premier Customer Services Description.

    **ALL CODE MUST BE TESTED BY ANY RECIPIENTS AND SHOULD NOT BE RUN IN A PRODUCTION ENVIRONMENT WITHOUT MODIFICATION BY THE RECIPIENT.**

    Author: Mark Warneke [mark.warneke@microsoft.com](mailto:mark.warneke@microsoft.com)
    Created: 18-12-2020

    Microsoft provides programming examples for illustration only, without warranty either expressed or implied, including, but not limited to, the implied warranties of merchantability or fitness for a particular purpose.
    This respository assumes that you are familiar with the programming language that is being demonstrated and the tools that are used to create and debug procedures.

    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

    )

    begin {
        Write-Verbose "[$(Get-Date)] Begin Stop-VM"
        $TAGS = [PSCustomObject] $script:CONFIG.Tags
        $F = 'False*'
    }

    process {
        #Get all VMs that are eligable for Shut Down
        $VMs = Get-AzVM -Status | Where-Object {
            $PSITEM.Tags.Keys -eq $TAGS.POWER_OFF_DISABLED -and
            $PSITEM.Tags[$TAGS.POWER_OFF_DISABLED] -like $F -and
            $PSITEM.PowerState -eq $script:CONFIG.VM_RUNNING
        }
        ForEach ($VM in $VMs) {

            $Time = Get-TimeFromTags -Tags $VM.Tags

            # Get Tags
            $VMTags = $VM.Tags
            $UTCOffset = [INT]$VMTags['PowerOnOffUTCOffset'] * -1
            $LocalStopString = $VMTags['PowerOffTime']
            Write-Verbose "[$(Get-Date)] UTC Offset of $($VM.Name) is $UTCOffset"
            # Determine UTC Shut Down Time
            $LocalStopTime = Get-Date $LocalStopString
            $UTCStopTime = $LocalStopTime.AddHours($UTCOffset)
            # Remove 24h and 5 Minutes to avoid 00:00 / midnight when UTC Offset is set to -5h or more (USA)
            $ActualCheckDate = Get-Date
            if ($UTCOffset -ge 5 -and $ActualCheckDate -ge (Get-Date "00:00:01") -and $ActualCheckDate -le (Get-Date "10:00")) {
                $UTCStopTime = $UTCStopTime.AddMinutes(-1445)
            }
            Write-Verbose "[$(Get-Date)] Stop Time (UTC) of $($VM.Name) is $UTCStopTime"

            $UTCTimeActual = $Time.UTCTimeActual
            Write-Verbose "[$(Get-Date)] Actual Time (UTC) is $UTCTimeActual"
            # Get Date for Date exclusions
            $UTCOffsetDate = [INT]$VMTags['PowerOnOffUTCOffset']
            [STRING]$ShutDownExclusion = $VMTags['PowerOffExcludeDates']
            if (!$ShutDownExclusion) {
                [DateTime]$ShutDownExclusionFormated = "01/01/1990"
            }
            else {
                [DateTime]$ShutDownExclusionFormated = $ShutDownExclusion
            }
            $ActualOffsetDate = (Get-Date).AddHours($UTCOffsetDate)
            $ActualOffsetDateFormated = Get-Date -Date $ActualOffsetDate -Format "MM/dd/yyyy"
            $ShutDownDateExclusionFormated = Get-Date -Date $ShutDownExclusionFormated -Format "MM/dd/yyyy"
            $ShutDownDate = (Get-Date -Date $ShutDownExclusionFormated).AddHours(25)
            $ShutDownDateFormated = Get-Date -Date $ShutDownDate -Format "MM/dd/yyyy"
            if ($ActualOffsetDateFormated -gt $ShutDownDateFormated -or $ActualOffsetDateFormated -lt $ShutDownDateExclusionFormated) {
                if ($UTCTimeActual -ge $UTCStopTime) {
                    Write-Verbose "[$(Get-Date)] Shutting down VM: $($VM.Name)"
                    if ($pscmdlet.ShouldProcess("Stop [${VM.Name}]", $VM.ResourceGroupName)) {
                        Stop-AzVM -Name $VM.Name -ResourceGroupName $VM.ResourceGroupName -Force
                    }
                }
                else {
                    Write-Verbose "[$(Get-Date)] $($VM.Name) is not planned for Shut Down yet"
                }
            }
            else {
                Write-Verbose "[$(Get-Date)] $($VM.Name) is not planned for Shut Down as exclusion is set for $ShutDownExclusionFormated"
            }
        }
    }

    end {
        Write-Verbose "[$(Get-Date)] End Stop-VM"
    }
}