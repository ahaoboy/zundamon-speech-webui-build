Get-ChildItem -Recurse | Where-Object { !$_.PSIsContainer } | Select-Object @{
    Name = "FullName";
    Expression = { $_.FullName }
}, @{
    Name = "Size";
    Expression = {
        $size = $_.Length
        switch ($size) {
            { $_ -ge 1GB } { "{0:N2} GB" -f ($size / 1GB); break }
            { $_ -ge 1MB } { "{0:N2} MB" -f ($size / 1MB); break }
            { $_ -ge 1KB } { "{0:N2} KB" -f ($size / 1KB); break }
            default { "$size B" }
        }
    }
} | Export-Csv -Path "tree.csv" -Encoding UTF8 -NoTypeInformation