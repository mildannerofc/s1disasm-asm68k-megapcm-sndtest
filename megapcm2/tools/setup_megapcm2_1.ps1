# Wrapper kept for the organized megapcm2/tools layout.
# The real installer lives at the project root so it can also be run directly.
& (Join-Path (Split-Path -Parent $PSScriptRoot) '..\setup_megapcm2_1.ps1') @args
exit $LASTEXITCODE
