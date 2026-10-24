$ErrorActionPreference = "Stop"

$ServiceName = "Velociraptor"
$Installer = "C:\VelociraptorLab\velociraptor-client.msi"

Write-Output "=== Velociraptor Windows installation ==="

# Check if Velociraptor is already installed
$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if ($null -eq $service) {
    Write-Output "Agent not found."

    if (-not (Test-Path $Installer)) {
        throw "Installer not found: $Installer"
    }

    Write-Output "Installing Velociraptor client..."

    $arguments = "/i `"$Installer`" /qn /norestart"
    $process = Start-Process -FilePath "msiexec.exe" `
        -ArgumentList $arguments `
        -Wait -PassThru

    if ($process.ExitCode -notin @(0, 3010)) {
        throw "MSI installation failed: $($process.ExitCode)"
    }

    Write-Output "Installation completed."
} else {
    Write-Output "Agent already installed. Skipping installation."
}

# Check service after installation
$service = Get-Service -Name $ServiceName -ErrorAction Stop

if ($service.Status -ne "Running") {
    Start-Service -Name $ServiceName
    Write-Output "Agent service started."
} else {
    Write-Output "Agent service already running."
}

# Final verification
$service = Get-Service -Name $ServiceName

Write-Output "Service: $($service.Name)"
Write-Output "Status: $($service.Status)"
Write-Output "=== Completed successfully ==="