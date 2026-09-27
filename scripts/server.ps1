param(
 [string]$World = '',
 [int]$Port = 30000,
 [string]$BindAddress = '0.0.0.0',
 [switch]$Announce
)
$ErrorActionPreference = 'Stop'
$project = Split-Path $PSScriptRoot -Parent
$engine = Join-Path $project 'runtime\luanti-5.17.0-win64'
$exe = Join-Path $engine 'bin\luanti.exe'
$worldRoot = [IO.Path]::GetFullPath((Join-Path $engine 'worlds'))
$evidence = Join-Path $project 'evidence'
$config = Join-Path $engine 'server.conf'
$log = Join-Path $evidence 'server.log'
$utf8 = New-Object System.Text.UTF8Encoding($false)

& (Join-Path $PSScriptRoot 'setup.ps1')
if (-not (Test-Path -LiteralPath $exe -PathType Leaf)) { throw 'Bundled Luanti executable is missing.' }
if ($Port -lt 1 -or $Port -gt 65535) { throw 'Port must be between 1 and 65535.' }
$parsedAddress = $null
if (-not [Net.IPAddress]::TryParse($BindAddress, [ref]$parsedAddress)) { throw 'BindAddress must be a local IPv4 or IPv6 address.' }

if ([string]::IsNullOrWhiteSpace($World)) {
 $candidate = Get-ChildItem -LiteralPath $worldRoot -Directory | Sort-Object Name | Select-Object -First 1
 if (-not $candidate) { throw 'No world exists. Create a world first.' }
 $World = $candidate.Name
}
$worldPath = if ([IO.Path]::IsPathRooted($World)) {
 [IO.Path]::GetFullPath($World)
} else {
 [IO.Path]::GetFullPath((Join-Path $worldRoot $World))
}
if (-not $worldPath.StartsWith($worldRoot + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'World must be inside the bundled worlds directory.' }
if (-not (Test-Path -LiteralPath (Join-Path $worldPath 'world.mt') -PathType Leaf)) { throw "World not found or incomplete: $worldPath" }

New-Item -ItemType Directory -Force -Path $evidence | Out-Null
$announceText = if ($Announce) { 'true' } else { 'false' }
$configLines = @(
 'language = zh_CN',
 'enable_server = true',
 ('server_announce = ' + $announceText),
 ('bind_address = ' + $BindAddress),
 ('port = ' + $Port),
 'server_name = Block World Multiplayer Server',
 'motd = Block World server; follow host rules',
 'disallow_empty_password = true',
 'default_privs = interact, shout',
 'map_save_interval = 5',
 'sqlite_synchronous = 2',
 'enable_rollback_recording = false'
)
[IO.File]::WriteAllLines($config, $configLines, $utf8)

function Quote-Argument([string]$Value) {
 return '"' + $Value.Replace('"','\"') + '"'
}
$psi = [Diagnostics.ProcessStartInfo]::new()
$psi.FileName = $exe
$psi.WorkingDirectory = $engine
$psi.UseShellExecute = $false
$psi.Arguments = '--server --world ' + (Quote-Argument $worldPath) +
 ' --gameid mineclonia --config ' + (Quote-Argument $config) +
 ' --logfile ' + (Quote-Argument $log)
Write-Output ('Starting Luanti server for world: ' + $World)
Write-Output ('Bind address: ' + $BindAddress + '; UDP port: ' + $Port)
Write-Output ('Server log: ' + $log)
$proc = [Diagnostics.Process]::Start($psi)
$proc.WaitForExit()
if ($proc.ExitCode -ne 0) { throw ('Server exited with code ' + $proc.ExitCode + '. See evidence\server.log.') }
