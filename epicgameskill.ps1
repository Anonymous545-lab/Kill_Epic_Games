# Function to delete a directory and its contents
function Delete-Directory($path) {
    if (Test-Path $path) {
        Write-Output "Deleting: $path"
        Remove-Item -Recurse -Force -LiteralPath $path
    } else {
        Write-Output "Path does not exist: $path"
    }
}

# Remove Epic Games Launcher and Fortnite from "Program Files"
$programFiles = @(
    "C:\Program Files\Epic Games",
    "C:\Program Files (x86)\Epic Games"
)
foreach ($path in $programFiles) {
    Delete-Directory $path
}

# Remove Fortnite and Epic Games settings from all user profiles
$usersPath = "C:\Users"
$users = Get-ChildItem $usersPath | Where-Object { $_.PSIsContainer -and $_.Name -notmatch "Default|Public" }

foreach ($user in $users) {
    # Define paths for Fortnite and Epic Games-related files
    $localAppData = "$usersPath\$($user.Name)\AppData\Local"
    $pathsToDelete = @(
        "$localAppData\EpicGamesLauncher",
        "$localAppData\FortniteGame",
        "$localAppData\UnrealEngine",
        "$localAppData\EOS"
    )

    foreach ($path in $pathsToDelete) {
        Delete-Directory $path
    }
}

# Search the entire system for Epic Games and Fortnite files (excluding System32)
$searchPaths = @(
    "C:\",
    "D:\", # Add other drives if necessary
    "E:\"
)
foreach ($drive in $searchPaths) {
    Get-ChildItem -Path $drive -Recurse -Force -Directory -ErrorAction SilentlyContinue |
        Where-Object { $_.Name -match "Epic Games|Fortnite" } |
        ForEach-Object { 
            Write-Output "Deleting: $($_.FullName)"
            Remove-Item -Recurse -Force -LiteralPath $_.FullName
        }
}

# Remove Epic Games Launcher shortcuts (if any)
$desktopPath = "C:\Users\$($env:USERNAME)\Desktop"
$shortcutPaths = Get-ChildItem $desktopPath -Filter "*Epic Games*" -Recurse -ErrorAction SilentlyContinue
foreach ($shortcut in $shortcutPaths) {
    Write-Output "Deleting shortcut: $($shortcut.FullName)"
    Remove-Item -Force $shortcut.FullName
}

# Remove Epic Games-related registry entries (if necessary)
# WARNING: Be careful with registry edits!
Write-Output "Cleaning Epic Games-related registry entries (if any)..."
Remove-Item -Path "HKCU:\Software\Epic Games" -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\Software\Epic Games" -ErrorAction SilentlyContinue
Remove-Item -Path "HKLM:\Software\Wow6432Node\Epic Games" -ErrorAction SilentlyContinue

Write-Output "Comprehensive clean-up completed."
