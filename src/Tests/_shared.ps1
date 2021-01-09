# Dot source this script in any Pester test script that requires the module to be imported.

$ModuleName = 'Az.Compute.LifeCycle'
$ModuleBase = Join-Path (Split-Path $PSScriptRoot -Parent) $ModuleName

# For tests in .\Tests subdirectory
if ((Split-Path $ModuleBase -Leaf) -eq 'Test') {
    $ModuleBase = Split-Path $ModuleBase -Parent
}

# Removes all versions of the module from the session before importing
Get-Module $ModuleName | Remove-Module

# Because ModuleBase includes version number, this imports the required version
# of the module
$ModuleManifestPath = Join-Path $ModuleBase "$ModuleName.psd1"

Import-Module $ModuleManifestPath -ErrorAction 'Stop' | Out-Null

if (!$SuppressImportModule) {
    # -Scope Global is needed when running tests from inside of psake, otherwise
    # the module's functions cannot be found in the modules namespace
    Import-Module $ModuleManifestPath -Scope 'Global' | Out-Null
}
