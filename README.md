O PS2EXE é um módulo do PowerShell que converte scripts .ps1 em executáveis .exe
Install-Module -Name ps2exe -Scope CurrentUser
Invoke-ps2exe -InputFile "C:\caminho\seu_script.ps1" -OutputFile "C:\caminho\seu_script.exe"




Notas sobre as versões

backup_v1.ps1 # Script sem o robocopy   
backup_v2.ps1 # script usando o robocopy
backup_v3.ps1 # No sucesso ou falha do script um evento é lançado nos logs do windows
backup_v4.ps1 # Sem autenticação para compartilhamento de rede
