# Script to fix coverage file paths for SonarQube compatibility
$coverageFile = "coverage/lcov.info"
if (Test-Path $coverageFile) {
    $content = Get-Content $coverageFile -Raw
    # Convert Windows paths to Unix-style paths
    $content = $content -replace '\\', '/'
    Set-Content $coverageFile -Value $content -NoNewline
    Write-Host "Coverage file paths converted to forward slashes"
} else {
    Write-Host "Coverage file not found. Run 'flutter test --coverage' first."
}

