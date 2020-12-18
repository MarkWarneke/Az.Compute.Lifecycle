BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    $testDate = Get-Date -Hour 9

    $test_VMS_to_start = @( 
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
            PowerState        = "VM deallocated"

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
            PowerState        = "VM deallocated"
        })
    $test_vms_to_NOT_start = @(
        @{
            Name              = "Test VM that starts earlier"
            ResourceGroupName = "test_vm"
            Tags              = @{
                'ManuallyStopped'     = 'False'
                'PowerOffDisabled'    = 'False'
                'PowerOnOffUTCOffset' = 1
                'PowerOffTime'        = '08:00'
                'PowerOnTime'         = '06:00'
            }
            PowerState        = "VM deallocated"

        },
        @{
            Name              = "Test VM that starts later"
            ResourceGroupName = "test_vm"
            Tags              = @{
                'ManuallyStopped'     = 'False'
                'PowerOffDisabled'    = 'False'
                'PowerOnOffUTCOffset' = 1
                'PowerOffTime'        = '13:00'
                'PowerOnTime'         = '12:00'
            }
            PowerState        = "VM deallocated"
        }
    )

    $test_vms_unaffected = @(
        @{
            Name              = "Test VM that is manually stopped"
            ResourceGroupName = "test_vm"
            Tags              = @{
                'ManuallyStopped'     = 'True'
                'PowerOffDisabled'    = 'False'
                'PowerOnOffUTCOffset' = 1
                'PowerOffTime'        = '10:00'
                'PowerOnTime'         = '08:00'
            }
            PowerState        = "VM deallocated"
        },
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
            PowerState        = "VM running"
        },
        @{
            Name              = "Test VM that is deallocated and has no tags"
            ResourceGroupName = "test_vm"
            Tags              = @{}
            PowerState        = "VM deallocated"
        },
        @{
            Name              = "Test VM that is running and has no tags"
            ResourceGroupName = "test_vm"
            Tags              = @{}
            PowerState        = "VM running"
        }
    )
}
Describe "Start-Vm" {

    BeforeAll {
      
        Mock Get-Date { $testDate }  -ParameterFilter { $date -eq $null }
    }

    Context "VMs that should start" {

        BeforeEach {
            Mock Start-AzVM  -Verifiable { $true }
            Mock Get-AzVM { 
                return $test_VMS_to_start
            }
            $result = Start-Vm
        }

        It "should start vm" {
            Assert-MockCalled Start-AzVM  -Exactly 2
        }
    }


    Context "VMs that should not start" {

        BeforeEach {
            Mock Start-AzVM  -Verifiable { $true }
            Mock Get-AzVM { 
                return $test_vms_unaffected + $test_vms_to_NOT_start
            }
            $result = Start-Vm
        }

        It "should not start vm" {
            Assert-MockCalled Start-AzVM  -Exactly 0
        }

        It "should check time" {
            # Run the get-date (whithin the loop for all VMS that pass the Where-Object filter)
            $times = ($test_VMS_to_start.Length + $test_vms_to_NOT_start.Length) * 3 + $test_vms_unaffected.Length * 0
            Assert-MockCalled Get-Date -Exactly 14 # $times
        }
    }

}