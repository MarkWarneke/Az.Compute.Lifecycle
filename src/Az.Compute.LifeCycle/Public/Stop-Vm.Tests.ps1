BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    $testDate = Get-Date -Hour 12
}
Describe "Stop-AzVM" {
    BeforeAll {
        Mock Get-Date { $testDate }  -ParameterFilter { $date -eq $null }
    }

    Context "given VMS that should start"  -Foreach @(
        @{
            testcase = @( 
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
                }
            ) 
        }

    ) {
        BeforeEach {
            Mock Stop-AzVM -Verifiable { $true }
          
            Mock Get-AzVM { 
                return $testcase
            }
            $result = Stop-Vm
        }

        It "should stop vm" {
            Assert-MockCalled Stop-AzVM  -Exactly 2
        }
    }


    Context "given VMs that should not stop"   -Foreach @(
        @{
            testcase = @( 
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
        },
        @{
            testcase = @(
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
    ) {

        BeforeEach {
            Mock Stop-AzVM -Verifiable { $true }

            Mock Get-AzVM { 
                return $testcase
            }
            $result = Stop-Vm
        }

        It "should not stop vm" {
            Assert-MockCalled Stop-AzVM  -Exactly 0
        }
    }

}