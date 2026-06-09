# Verify FAQ and comparison pages exist on vslingarchery.com.
# Pages must be created in Shopify Admin (see steps below) — they cannot be created from theme files alone.
#
# Usage: .\scripts\create-vsling-pages.ps1

$pages = @(
    @{ Name = "FAQ"; Url = "https://vslingarchery.com/pages/faq" },
    @{ Name = "Comparison"; Url = "https://vslingarchery.com/pages/vsling-vs-traditional-bow-sling" }
)

Write-Host "Checking Vsling pages...`n"
$allOk = $true
foreach ($p in $pages) {
    try {
        $resp = Invoke-WebRequest -Uri $p.Url -Method Head -UseBasicParsing -MaximumRedirection 0 -ErrorAction Stop
        $status = $resp.StatusCode
    } catch {
        if ($_.Exception.Response) {
            $status = [int]$_.Exception.Response.StatusCode
        } else {
            $status = "error"
        }
    }
    $ok = $status -eq 200
    if (-not $ok) { $allOk = $false }
    Write-Host ("{0}: {1} -> HTTP {2}" -f $p.Name, $p.Url, $status)
}

if ($allOk) {
    Write-Host "`nBoth pages are live."
    exit 0
}

Write-Host @"

Pages not found. Create them in Shopify Admin:

1. Online Store -> Pages -> Add page

   PAGE 1 — FAQ
   - Title: Vsling FAQ for Bowhunters
   - Handle: faq
   - Template: faq
   - Body: leave empty (theme supplies content)
   - Visibility: Visible
   - Save

   PAGE 2 — Comparison
   - Title: Vsling vs Traditional Bow Sling
   - Handle: vsling-vs-traditional-bow-sling
   - Template: comparison
   - Body: leave empty (theme supplies content)
   - Visibility: Visible
   - Save

2. Publish the updated theme (must include templates/page.faq.json and templates/page.comparison.json)

3. Re-run: .\scripts\create-vsling-pages.ps1

"@

exit 1
