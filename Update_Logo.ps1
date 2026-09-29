# Configuration
$clientId = "123a4567-b123-4567-890c-1def23456789"
$SiteCollectionUrl = "https://mytenant.sharepoint.com/sites/company1"
$LogoUrl = "https://mytenant.sharepoint.com/sites/BrandGuide/company1/company1_Logo.png"

# Connect to root once (to enumerate subsites)
Connect-PnPOnline -Url $SiteCollectionUrl -Interactive -ClientId $clientId

# Get root + all subsites (recursive)
$webs = Get-PnPSubWeb -Recurse -IncludeRootWeb

# ---- Count of all sites (webs) ----
$totalSites = $webs.Count
Write-Host "Total sites (root + all subsites) found: $totalSites" -ForegroundColor Cyan

# Detect if your Connect-PnPOnline supports -ReturnConnection
$hasReturnConnection = (Get-Command Connect-PnPOnline).Parameters.ContainsKey("ReturnConnection")

$success = 0
$failed  = 0

foreach ($w in $webs) {
    try {
        Write-Host "[$success/$totalSites] Updating logo for: $($w.Title) -> $($w.Url)" -ForegroundColor White

        if ($hasReturnConnection) {
            $conn = Connect-PnPOnline -Url $w.Url -ClientId $clientId -ReturnConnection

            Set-PnPWeb -Connection $conn -SiteLogoUrl $LogoUrl   # Set-PnPWeb works on current web / via -Connection 
        }
        else {
            Connect-PnPOnline -Url $w.Url -ClientId $clientId -Interactive
            Set-PnPWeb -SiteLogoUrl $LogoUrl                    # 
        }

        $success++
        Write-Host "SUCCESS: $($w.Url)" -ForegroundColor Green
    }
    catch {
        $failed++
        Write-Host "FAILED: $($w.Url) | $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "Logo update process complete." -ForegroundColor Cyan
Write-Host "Summary: Total=$totalSites | Success=$success | Failed=$failed" -ForegroundColor Yellow
