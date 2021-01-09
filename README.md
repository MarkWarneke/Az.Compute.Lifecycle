# PWSH

using [mcr.microsoft.com/azure-powershell:latest](https://hub.docker.com/_/microsoft-azure-powershell)

# Description

Use the run command to execute the functionality.
To start the VMs run:

```bash
./run.ps1
```

to stop the vms run:


```bash
./run.ps1 -stop
```

You can alos use the provided `Makefile`

```bash
make run
```

# Life cycle methods

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

Import-Module (Join-Path $PSScriptRoot 'src' 'Az.Compute.LifeCycle') -Force

Get-Help Set-Tags
Get-Help Start-Vm
Get-Help Stop-Vm
```