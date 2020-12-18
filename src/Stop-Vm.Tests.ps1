BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    $testDate = Get-Date -Hour 12

    $test_VMS_to_stop = @( 
        @{
            Name              = "Test VM"
            ResourceGroupName = "test_vm"
            Tags              = @{
                'ManuallyStopped'     = 'False'
                'PowerOffDisabled'    = 'False'
                'PowerOnOffUTCOffset' = 1
                'PowerOffTime'        = '10:00'
                'PowerOnTime'         = '08:00'
            }
            PowerState        = "VM running"

        },
        @{
            Name              = "Test VM 2"
            ResourceGroupName = "test_vm"
            Tags              = @{
                'ManuallyStopped'     = 'False'
                'PowerOffDisabled'    = 'False'
                'PowerOnOffUTCOffset' = 1
                'PowerOffTime'        = '10:00'
                'PowerOnTime'         = '08:00'
            }
            PowerState        = "VM running"
        })

    $test_vms_to_NOT_stop = @(
        @{
            Name              = "Test VM that stop later"
            ResourceGroupName = "test_vm"
            Tags              = @{
                'ManuallyStopped'     = 'False'
                'PowerOffDisabled'    = 'False'
                'PowerOnOffUTCOffset' = 0
                'PowerOffTime'        = '14:00'
                'PowerOnTime'         = '06:00'
            }
            PowerState        = "VM running"

        },
        @{
            Name              = "Test VM that poweroff disabled"
            ResourceGroupName = "test_vm"
            Tags              = @{
                'ManuallyStopped'     = 'False'
                'PowerOffDisabled'    = 'True'
                'PowerOnOffUTCOffset' = 1
                'PowerOffTime'        = '12:00'
                'PowerOnTime'         = '06:00'
            }
            PowerState        = "VM running"
        }
    )

    $test_vms_unaffected = @(
        @{
            Name              = "Test VM that is running"
            ResourceGroupName = "test_vm"
            Tags              = @{
                'ManuallyStopped'     = 'False'
                'PowerOffDisabled'    = 'False'
                'PowerOnOffUTCOffset' = 1
                'PowerOffTime'        = '10:00'
                'PowerOnTime'         = '08:00'
            }
            PowerState        = "VM deallocated"
        },
        @{
            Name              = "Test VM that is deallocated and has no tags"
            ResourceGroupName = "test_vm"
            Tags              = @{}
            PowerState        = "VM running"
        },
        @{
            Name              = "Test VM that is running and has no tags"
            ResourceGroupName = "test_vm"
            Tags              = @{}
            PowerState        = "VM deallocated"
        }
    )
}
Describe "Stop-AzVM" {
    BeforeAll {
        Mock Get-Date { $testDate }  -ParameterFilter { $date -eq $null }
    }

    Context "VMs that should start" {
        BeforeEach {
            Mock Stop-AzVM -Verifiable { $true }
          
            Mock Get-AzVM { 
                return $test_VMS_to_stop
            }
            $result = Stop-Vm
        }

        It "should stop vm" {
            Assert-MockCalled Stop-AzVM  -Exactly 2
        }
    }


    Context "VMs that should not stop" {

        BeforeEach {
            Mock Stop-AzVM -Verifiable { $true }

            Mock Get-AzVM { 
                return $test_vms_unaffected + $test_vms_to_NOT_stop
            }
            $result = Stop-Vm
        }

        It "should not stop vm" {
            Assert-MockCalled Stop-AzVM  -Exactly 0
        }
    }

}