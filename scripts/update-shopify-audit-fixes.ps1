# Updates Shopify Admin content that cannot be changed from theme files alone.
# Requires Shopify CLI auth: shopify auth login --store vslingarchery.myshopify.com
#
# Usage: .\scripts\update-shopify-audit-fixes.ps1

$ErrorActionPreference = 'Stop'
$store = 'vslingarchery.myshopify.com'
$oldCrossbowPath = '/products/untitled-mar22_12-23'
$newCrossbowPath = '/products/vsling-crossbow-gun-sling'

Write-Host "Vsling audit — Shopify Admin updates`n"

# --- Navigation: update crossbow product links in all menus ---
$menuQuery = @'
{
  menus(first: 20) {
    edges {
      node {
        id
        handle
        title
        items {
          id
          title
          url
          items {
            id
            title
            url
            items {
              id
              title
              url
            }
          }
        }
      }
    }
  }
}
'@

Write-Host "1. Fetching navigation menus..."
try {
  $menuResult = shopify graphql --store $store --query $menuQuery 2>&1
  if ($LASTEXITCODE -ne 0) { throw $menuResult }
  $menuJson = $menuResult | ConvertFrom-Json
  $updatedMenus = 0

  foreach ($edge in $menuJson.data.menus.edges) {
    $menu = $edge.node
    $itemsToUpdate = @()

    function Collect-OldLinks($items) {
      foreach ($item in $items) {
        if ($item.url -like "*untitled-mar22_12-23*") {
          $script:itemsToUpdate += [PSCustomObject]@{ Menu = $menu.title; Id = $item.id; Title = $item.title; Url = $item.url }
        }
        if ($item.items) { Collect-OldLinks $item.items }
      }
    }

    Collect-OldLinks $menu.items

    foreach ($hit in $itemsToUpdate) {
      Write-Host "   Updating [$($hit.Menu)] $($hit.Title) -> $newCrossbowPath"
      $mutation = @"
mutation {
  menuItemUpdate(id: "$($hit.Id)", item: { url: "$newCrossbowPath" }) {
    menuItem { id title url }
    userErrors { field message }
  }
}
"@
      shopify graphql --store $store --query $mutation | Out-Null
      $updatedMenus++
    }
  }

  if ($updatedMenus -eq 0) {
    Write-Host "   No menu links to $oldCrossbowPath found (or already updated)."
  } else {
    Write-Host "   Updated $updatedMenus menu link(s)."
  }
} catch {
  Write-Host "   SKIP navigation update — run manually in Shopify Admin > Navigation:"
  Write-Host "   Change every link from $oldCrossbowPath to $newCrossbowPath"
  Write-Host "   Error: $_"
}

# --- Verify URLs ---
Write-Host "`n2. Verifying product URLs..."
foreach ($url in @(
  "https://vslingarchery.com$newCrossbowPath",
  "https://vslingarchery.com$oldCrossbowPath"
)) {
  try {
    $resp = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -MaximumRedirection 5
    Write-Host "   $url -> $($resp.StatusCode) (final: $($resp.BaseResponse.ResponseUri.AbsolutePath))"
  } catch {
    Write-Host "   $url -> ERROR"
  }
}

Write-Host "`n3. Manual Admin steps still required if CLI is not authenticated:"
Write-Host "   - Products > Vsling Bow Sling > Description: remove any Merchandising tips copy"
Write-Host "   - Products > Vsling Bow Sling > Media: update alt text (theme overrides most on publish)"
Write-Host "   - Online Store > Navigation: confirm crossbow photo link uses $newCrossbowPath"
Write-Host "   - Ensure product handle vsling-crossbow-gun-sling exists (404 means product not created yet)"
