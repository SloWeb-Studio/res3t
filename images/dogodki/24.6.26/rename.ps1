$images = Get-ChildItem -File | Where-Object {
    $_.Extension -match "^\.(jpg|jpeg|png|webp)$" -and
    $_.BaseName -notmatch "^cover$"
} | Sort-Object Name

Write-Host "Najdenih slik za preimenovanje: $($images.Count)"
Write-Host "Datoteka cover.jpg / cover.jpeg / cover.png / cover.webp bo ostala nespremenjena."
$confirm = Read-Host "Za nadaljevanje napiši YES"

if ($confirm -ne "YES") {
    Write-Host "Preklicano."
    exit
}

if ($images.Count -eq 0) {
    Write-Host "Ni slik za preimenovanje."
    exit
}

$tempImages = @()

foreach ($img in $images) {
    $tempName = "__temp_rename__$([guid]::NewGuid())$($img.Extension)"
    Rename-Item $img.FullName -NewName $tempName

    $tempImages += Get-Item (Join-Path $img.DirectoryName $tempName)
}

$lastImage = $tempImages[-1]
Rename-Item $lastImage.FullName -NewName ("0$($lastImage.Extension)")

$number = 2

for ($i = 0; $i -lt $tempImages.Count - 1; $i++) {
    $img = $tempImages[$i]
    Rename-Item $img.FullName -NewName ("$number$($img.Extension)")
    $number++
}

Write-Host "Končano."