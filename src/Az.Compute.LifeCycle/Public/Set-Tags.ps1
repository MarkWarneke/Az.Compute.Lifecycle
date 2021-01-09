function Set-Tags {
    <#
    .SYNOPSIS
    Set a list of tags for lifcycle activites on a given resource.
    In order to take effect of Start-Vm and Stop-Vm the resource must be of type compute (VM, VMSS, Container).

    .DESCRIPTION
    Set a list of tags for lifcycle activites on a given resource.
    The tag values can be overwritten by matching Parameter.

    By default the following tags are applied:
    ```
    Name                 Value
             ===================  =====
             PowerOffDisabled     False
             PowerOffTime         20:00
             ManuallyStopped      False
             PowerOnTime          08:00
             PowerOnOffUTCOffset  0
    ```

    In order to take effect of Start-Vm and Stop-Vm the resource must be of type compute (VM, VMSS, Container).

    .PARAMETER ResourceId
    The resource identifier for the entity being tagged. A resource, a resource group or a subscription may be tagged.

    .PARAMETER PowerOnTime
    The tag to put on the resource, indicating at what time to turn on the VM. Must be between 00:00 and 23:59.
    See Regex https://regex101.com/r/aT2vU2/93

    .PARAMETER PowerOffTime
    The tag to put on the resource, indicating at what time to turn off the VM. Must be between 00:00 and 23:59.
    See Regex https://regex101.com/r/aT2vU2/93

    .PARAMETER UTCOffset
    The tag to put on the resource, indicating what TimeZone offset to take to calculate based on the execution environment.

    .PARAMETER ManuallyStopped
    The tag to put on the resource, indicating that the VM is should not be started.

    .PARAMETER PowerOffDisabled
    The tag to put on the resource, indicating that the VM should NOT be stopped.

    .EXAMPLE
    PS > Set-Tags -Id "/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName"

    Set the default tags to the given virtual machine by ResourceId

    ```
    Id         : /subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName/providers/Microsoft.Resources/tags/default
    Name       : default
    Type       : Microsoft.Resources/tags
    Properties :
                Name                 Value
                ===================  =====
                PowerOffDisabled     False
                PowerOffTime         20:00
                ManuallyStopped      False
                PowerOnTime          08:00
                PowerOnOffUTCOffset  0
    ```

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
        # Parameter help description
        [Parameter(
            Mandatory = $true,
            HelpMessage = "The resource identifier for the entity being tagged. A resource, a resource group or a subscription may be tagged."
        )]
        [string[]]
        [Alias('Id')]
        $ResourceId,

        [Parameter(HelpMessage = "The tag to put on the resource, indicating at what time to turn on the VM. Must be between 00:00 and 23:59")]
        [ValidatePattern("^(?:(?:2[0-3]|[01][0-9]):[0-5][0-9])$")] #https://regex101.com/r/aT2vU2/93
        [string]
        $PowerOnTime = '08:00',

        [Parameter(HelpMessage = "The tag to put on the resource, indicating at what time to turn off the VM. Must be between 00:00 and 23:59")]
        [ValidatePattern("^(?:(?:2[0-3]|[01][0-9]):[0-5][0-9])$")] # https://regex101.com/r/aT2vU2/93
        [string]
        $PowerOffTime = '20:00',

        [Parameter(HelpMessage = "The tag to put on the resource, indicating what TimeZone offset to take to calculate based on the execution environment.")]
        [ValidateRange(-12, 14)]
        [string]
        $UTCOffset = '0',

        [Parameter(HelpMessage = "The tag to put on the resource, indicating that the VM is should not be started.")]
        [ValidateSet("False", "True")]
        [string]
        $ManuallyStopped = 'False',

        [Parameter(HelpMessage = "The tag to put on the resource, indicating that the VM should NOT be stopped.")]
        [ValidateSet("False", "True")]
        [string]
        $PowerOffDisabled = 'False'
    )

    begin {
        $TAGS = [PSCustomObject] @{
            MANUAL_STOP        = 'ManuallyStopped'
            POWER_OFF_DISABLED = 'PowerOffDisabled'
            POWER_OFF_OFFSET   = 'PowerOnOffUTCOffset'
            POWER_ON           = 'PowerOnTime'
            POWER_OFF          = 'PowerOffTime'
            POWER_OFF_EXCLUDE  = 'PowerOffExcludeDates'
        }
    }

    process {
        foreach ($_id in $ResourceId) {
            try {
                $Tags = @{
                    $TAGS.MANUAL_STOP        = $ManuallyStopped
                    $TAGS.POWER_OFF_DISABLED = $PowerOffDisabled
                    $TAGS.POWER_OFF_OFFSET   = $UTCOffset
                    $TAGS.POWER_ON           = $PowerOnTime
                    $TAGS.POWER_OFF          = $PowerOffTime
                }
                if ($pscmdlet.ShouldProcess("AzTag [$_id]", $Tags)) {
                    New-AzTag -ResourceId $_id -Tag $Tags
                }
            }
            catch {
                Write-Error "setting tag on $ResourceId"
                Write-Verbose $_
            }
        }
    }

    end {

    }
}