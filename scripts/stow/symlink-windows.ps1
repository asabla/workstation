# symlink-windows.ps1 - Create symlinks on Windows for dotfile management
# PowerShell script (requires Administrator privileges for symlinks)

param(
    [Parameter(Mandatory=$false)]
    [string]$Command = "link",
    
    [Parameter(Mandatory=$false)]
    [string[]]$Packages = @()
)

$ErrorActionPreference = "Stop"

# Get script directory and workstation root
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$WorkstationRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)
$ApplicationsDir = Join-Path $WorkstationRoot "applications"

# Colors for output
function Write-Info { Write-Host "[INFO] $args" -ForegroundColor Blue }
function Write-Success { Write-Host "[OK] $args" -ForegroundColor Green }
function Write-Warning { Write-Host "[WARN] $args" -ForegroundColor Yellow }
function Write-Error { Write-Host "[ERROR] $args" -ForegroundColor Red }
function Write-Step { Write-Host "[STEP] $args" -ForegroundColor Magenta }

# Check if running as Administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Create a symlink (directory or file)
function New-SafeSymlink {
    param(
        [string]$Source,
        [string]$Destination
    )
    
    # Check if source exists
    if (-not (Test-Path $Source)) {
        Write-Error "Source does not exist: $Source"
        return $false
    }
    
    # Create parent directory if needed
    $parentDir = Split-Path -Parent $Destination
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
        Write-Info "Created directory: $parentDir"
    }
    
    # Handle existing destination
    if (Test-Path $Destination) {
        $item = Get-Item $Destination -Force
        if ($item.LinkType -eq "SymbolicLink") {
            # Remove existing symlink
            Remove-Item $Destination -Force
        } else {
            # Backup existing file/directory
            $backup = "$Destination.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
            Move-Item $Destination $backup
            Write-Info "Backed up $Destination to $backup"
        }
    }
    
    # Create symlink
    $isDirectory = (Get-Item $Source).PSIsContainer
    if ($isDirectory) {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
    } else {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
    }
    
    Write-Success "Linked $Destination -> $Source"
    return $true
}

# Remove a symlink
function Remove-Symlink {
    param(
        [string]$Path
    )
    
    if (Test-Path $Path) {
        $item = Get-Item $Path -Force
        if ($item.LinkType -eq "SymbolicLink") {
            Remove-Item $Path -Force
            Write-Success "Removed symlink: $Path"
            return $true
        } else {
            Write-Warning "$Path is not a symlink, skipping"
            return $false
        }
    }
    
    Write-Info "$Path does not exist"
    return $true
}

# Link configuration for nvim
function Link-Nvim {
    $source = Join-Path $ApplicationsDir "nvim\.config\nvim"
    $dest = Join-Path $env:LOCALAPPDATA "nvim"
    New-SafeSymlink -Source $source -Destination $dest
}

# Unlink configuration for nvim
function Unlink-Nvim {
    $dest = Join-Path $env:LOCALAPPDATA "nvim"
    Remove-Symlink -Path $dest
}

# Link configuration for vscode
function Link-Vscode {
    $sourceDir = Join-Path $ApplicationsDir "vscode"
    $destDir = Join-Path $env:APPDATA "Code\User"
    
    # Link settings.json
    $settingsSource = Join-Path $sourceDir "settings.json"
    $settingsDest = Join-Path $destDir "settings.json"
    if (Test-Path $settingsSource) {
        New-SafeSymlink -Source $settingsSource -Destination $settingsDest
    }
    
    # Link keybindings.json
    $keybindingsSource = Join-Path $sourceDir "keybindings.json"
    $keybindingsDest = Join-Path $destDir "keybindings.json"
    if (Test-Path $keybindingsSource) {
        New-SafeSymlink -Source $keybindingsSource -Destination $keybindingsDest
    }
}

# Unlink configuration for vscode
function Unlink-Vscode {
    $destDir = Join-Path $env:APPDATA "Code\User"
    Remove-Symlink -Path (Join-Path $destDir "settings.json")
    Remove-Symlink -Path (Join-Path $destDir "keybindings.json")
}

# Link all packages
function Link-Packages {
    param([string[]]$PackageList)
    
    foreach ($pkg in $PackageList) {
        Write-Step "Linking $pkg..."
        switch ($pkg) {
            "nvim" { Link-Nvim }
            "vscode" { Link-Vscode }
            "tmux" { Write-Warning "tmux is not supported on Windows. Use WSL." }
            "zsh" { Write-Warning "zsh is not supported on Windows. Use WSL." }
            default { Write-Warning "Unknown package: $pkg" }
        }
    }
}

# Unlink all packages
function Unlink-Packages {
    param([string[]]$PackageList)
    
    foreach ($pkg in $PackageList) {
        Write-Step "Unlinking $pkg..."
        switch ($pkg) {
            "nvim" { Unlink-Nvim }
            "vscode" { Unlink-Vscode }
            default { Write-Warning "Unknown package: $pkg" }
        }
    }
}

# List available packages
function List-Packages {
    Write-Info "Available packages in $ApplicationsDir`:"
    Get-ChildItem -Path $ApplicationsDir -Directory | ForEach-Object {
        Write-Host "  - $($_.Name)"
    }
}

# Print usage
function Show-Usage {
    Write-Host @"
Usage: .\symlink-windows.ps1 [-Command <command>] [-Packages <packages>]

Commands:
  link <packages>    Create symlinks for the specified packages
  unlink <packages>  Remove symlinks for the specified packages
  list               List available packages

Examples:
  .\symlink-windows.ps1 -Command link -Packages nvim,vscode
  .\symlink-windows.ps1 -Command unlink -Packages nvim
  .\symlink-windows.ps1 -Command list

Note: Creating symlinks on Windows requires Administrator privileges.
"@
}

# Main
if (-not (Test-Administrator)) {
    Write-Warning "This script may require Administrator privileges to create symlinks."
    Write-Info "If you encounter errors, run PowerShell as Administrator."
}

switch ($Command) {
    "link" {
        if ($Packages.Count -eq 0) {
            Write-Error "No packages specified"
            Show-Usage
            exit 1
        }
        Link-Packages -PackageList $Packages
    }
    "unlink" {
        if ($Packages.Count -eq 0) {
            Write-Error "No packages specified"
            Show-Usage
            exit 1
        }
        Unlink-Packages -PackageList $Packages
    }
    "list" {
        List-Packages
    }
    default {
        Show-Usage
    }
}
