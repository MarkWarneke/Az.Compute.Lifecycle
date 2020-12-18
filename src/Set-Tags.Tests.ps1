BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')
}

Describe "New-AzTag" {
    Context "Valid Tags"  -ForEach  @(
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '08:00'
            PowerOffTime     = '20:00'
            UTCOffset        = 0
            ManuallyStopped  = 'False'
            PowerOffDisabled = 'False'
        },
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '00:00'
            PowerOffTime     = '23:59'
            UTCOffset        = -12
            ManuallyStopped  = 'False'
            PowerOffDisabled = 'False'
        },
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '00:00'
            PowerOffTime     = '23:59'
            UTCOffset        = 14
            ManuallyStopped  = 'True'
            PowerOffDisabled = 'True'
        }
    ) {
        BeforeEach {
            Mock New-AzTag { 
                return $true
            }
        }

        It "should tag a vm" {
            Set-Tags -ResourceId $ResourceId -PowerOnTime $PowerOnTime -PowerOffTime $PowerOffTime -UTCOffset $UTCOffset -ManuallyStopped $ManuallyStopped -PowerOffDisabled $PowerOffDisabled
            Assert-MockCalled New-AzTag  -Exactly 1
        }
    }

    Context "InValid Tags"  -ForEach  @(
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '08:00'
            PowerOffTime     = '20:00'
            UTCOffset        = 0
            ManuallyStopped  = 'No'
            PowerOffDisabled = 'False'
        },
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '00:00'
            PowerOffTime     = '23:59'
            UTCOffset        = -12
            ManuallyStopped  = 'False'
            PowerOffDisabled = 'No'
        },
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '00:00'
            PowerOffTime     = '24:00'
            UTCOffset        = 14
            ManuallyStopped  = 'Yes'
            PowerOffDisabled = 'True'
        },
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '-00:00'
            PowerOffTime     = '23:59'
            UTCOffset        = 14
            ManuallyStopped  = 'True'
            PowerOffDisabled = 'True'
        }, 
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '00:60'
            PowerOffTime     = '23:59'
            UTCOffset        = 14
            ManuallyStopped  = 'True'
            PowerOffDisabled = 'True'
        }
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '00:00'
            PowerOffTime     = '24:00'
            UTCOffset        = 14
            ManuallyStopped  = 'True'
            PowerOffDisabled = 'True'
        },
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '00:00'
            PowerOffTime     = '23:60'
            UTCOffset        = 14
            ManuallyStopped  = 'True'
            PowerOffDisabled = 'True'
        },
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '00:00'
            PowerOffTime     = '23:59'
            UTCOffset        = 15
            ManuallyStopped  = 'True'
            PowerOffDisabled = 'True'
        },
        @{
            ResourceId       = '/subscriptions/$Subscription/resourceGroups/$resourceGroup/providers/Microsoft.Compute/virtualMachines/$vitualMachineName'
            PowerOnTime      = '00:00'
            PowerOffTime     = '23:59'
            UTCOffset        = -13
            ManuallyStopped  = 'False'
            PowerOffDisabled = 'False'
        }
    ) {
        BeforeEach {
            Mock New-AzTag { 
                return $true
            }
        }

        It "should not create a tag" {
            { Set-Tags -ResourceId $ResourceId -PowerOnTime $PowerOnTime -PowerOffTime $PowerOffTime -UTCOffset $UTCOffset -ManuallyStopped $ManuallyStopped -PowerOffDisabled $PowerOffDisabled } | Should -Throw
            Assert-MockCalled New-AzTag -Exactly 0
        }
    }
    

}