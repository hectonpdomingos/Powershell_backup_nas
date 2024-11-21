# Configurações
$sourcePath = "C:\cliente\backup"
$networkPath = "\\192.168.1.10\backups" # Substitua pelo caminho do compartilhamento no NAS
$credentialUser = "teste" # Substitua pelo usuário para autenticação
$credentialPassword = "jfhsdkjhfr743y7fr89" # Substitua pela senha para autenticação
$localDrive = "Z:" # Unidade temporária para montar o compartilhamento

# Monta o compartilhamento de rede
$securePassword = ConvertTo-SecureString $credentialPassword -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($credentialUser, $securePassword)
New-PSDrive -Name $localDrive.TrimEnd(':') -PSProvider FileSystem -Root $networkPath -Credential $credential -Persist

if (Test-Path $localDrive) {
    Write-Host "Compartilhamento montado com sucesso."

    # Obtém o último arquivo criado na pasta de origem
    $latestFile = Get-ChildItem -Path $sourcePath -File | Sort-Object CreationTime -Descending | Select-Object -First 1

    if ($latestFile) {
        Write-Host "Último arquivo encontrado: $($latestFile.Name)"
        $destinationPath = Join-Path -Path $localDrive -ChildPath $latestFile.Name

        # Usa Robocopy para copiar o arquivo
        $robocopyCommand = "robocopy.exe `"$sourcePath`" `"$localDrive`" $($latestFile.Name) /R:3 /W:5"
        Write-Host "Executando: $robocopyCommand"
        Invoke-Expression $robocopyCommand

        Write-Host "Arquivo copiado com sucesso para: $destinationPath"
    } else {
        Write-Host "Nenhum arquivo encontrado na pasta de origem."
    }

    # Desmonta o compartilhamento
    Remove-PSDrive -Name $localDrive.TrimEnd(':')
    Write-Host "Compartilhamento desmontado com sucesso."
} else {
    Write-Host "Falha ao montar o compartilhamento de rede."
}
