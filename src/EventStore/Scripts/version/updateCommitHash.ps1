param([string]$assemblyInfoFilePath)

echo $assemblyInfoFilePath

if ($assemblyInfoFilePath -eq $null) {
	throw "No file passed. Usage: ./updateCommitHash.ps1 <filename>"
}

$branch = & { git rev-parse --abbrev-ref HEAD }
$commitHashAndTimestamp = & { git log --max-count=1 --pretty=format:%H@%aD HEAD }

$newAssemblyVersionInformational = 'AssemblyInformationalVersion("0.0.0.0.' + $branch + '@' + $commitHashAndTimestamp + '")'
$assemblyVersionInformationalPattern = 'AssemblyInformationalVersion\(\"0\.0\.0\.0\..*"\)'

$edited = (Get-Content $assemblyInfoFilePath) | ForEach-Object {
    % {$_ -replace "\/\*+.*\*+\/", "" } |
    % {$_ -replace "\/\/+.*$", "" } |
    % {$_ -replace "\/\*+.*$", "" } |
    % {$_ -replace "^.*\*+\/\b*$", "" } |
    % {$_ -replace $assemblyVersionInformationalPattern, $newAssemblyVersionInformational }
}

if (!(($edited -match $assemblyVersionInformationalPattern) -ne "")) {
    $edited += "[assembly: $newAssemblyVersionInformational]"
}

Set-Content -Path $assemblyInfoFilePath -Value $edited