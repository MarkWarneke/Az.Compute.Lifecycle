BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1', '.ps1')

    $testDate = Get-Date -Hour 9    
}

Describe "Start-Vm" {

    BeforeAll {
      
        Mock Get-Date { $testDate }  -ParameterFilter { $date -eq $null }
    }

    Context "given VMs that should start" -Foreach @(
        @{
            testcase = @( 
                @{
                    Name              = "Test VM"
                    ResourceGroupName = "test_vm"
                    Tags              = @{
                        'ManuallyStopped'     = 'False'
                        'PowerOffDisabled'    = 'False'
                        'PowerOnOffUTCOffset' = 0
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
                        'PowerOnOffUTCOffset' = 0
                        'PowerOffTime'        = '10:00'
                        'PowerOnTime'         = '08:00'
                    }
                    PowerState        = "VM deallocated"
                }
            ) 
        }

    ) {

        BeforeEach {
            Mock Start-AzVM  -Verifiable { $true }
            Mock Get-AzVM { 
                return $testcase
            }
            $result = Start-Vm
        }

        It "should start vm" {
            Assert-MockCalled Start-AzVM  -Exactly 2
        }
    }


    Context "given VMs that should not start"  -Foreach @(
        @{
            testcase = @(
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
        },
        @{
            testcase = @(
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
    ) {
        BeforeEach {
            Mock Start-AzVM  -Verifiable { $true }
            Mock Get-AzVM { 
                return $testcase
            }
            $result = Start-Vm
        }
        It "should not start vm" {
            Assert-MockCalled Start-AzVM  -Exactly 0
        }

    }      
}
