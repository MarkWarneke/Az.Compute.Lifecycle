# Az.Compute.Lifecycle ![CI](https://github.com/MarkWarneke/Az.Compute.Lifecycle/workflows/CI/badge.svg)

Create a solution to save costs for dev environments e.g.

- automatic shutdown of VMSS during evenings & weekends for dev/tests
- automatic scaling of VMSS to reduce to smaller footprint and save costs

Create an executable that to certain times deallocate compute resources and start them again.

Use the run command to execute the functionality.
To start the VMs run:

```bash
./run.ps1
```

to stop the vms run:


```bash
./run.ps1 -stop
```

You can also use the provided `Makefile`

```bash
make run
```

## Automation

You can use an Azure logic app to start the Dockerfile as a Azure Container Instance.
The Azure Container Instance can be associated with a User Assigned Managed Identity to take care of the authentication & authorization.
Make sure the Managed Identity Principal has proper Role Based Access Controle on the Azure resources to be managed.

## life cycle methods

Uses a couple of tags to start or stop vms.
Use `Set-Tags` to create the tags on a given vm.

```
Name                 Value
            ===================  =====
            PowerOffDisabled     False
            PowerOffTime         20:00
            ManuallyStopped      False
            PowerOnTime          08:00
            PowerOnOffUTCOffset  0
```

After that the life cycle activities will `Start-Vm` or `Stop-Vm` based on the tags.

## Help

```powershell
$ModuleName = 'Az.Compute.LifeCycle'
Import-Module (Join-Path 'src' $ModuleName -Resolve) -Force

Get-Command -Module $ModuleName

Get-Help Set-Tags
Get-Help Start-Vm
Get-Help Stop-Vm
```

## Docker

Using [mcr.microsoft.com/azure-powershell:latest](https://hub.docker.com/_/microsoft-azure-powershell)
