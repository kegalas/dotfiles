# if running powershell script is forbidden, use:
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

$scriptDir = Get-Location

New-Item -ItemType SymbolicLink -Path "~\.emacs.d" -Target "$scriptDir\..\emacs"
New-Item -ItemType SymbolicLink -Path "~\vimfiles" -Target "$scriptDir\..\vim"

