# Configurações
$sourcePath = "C:\cliente\backup"
$networkPath = "\\192.168.1.10\backups"
$credentialUser = "teste"
$credentialPassword = "jfkdslf43oy78349hfgi reihu"
$localDrive = "F:"

try {
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
            Invoke-Expression $robocopyCommand

            Write-Host "Arquivo copiado com sucesso para: $destinationPath"

            # Registra sucesso no log de eventos
            Write-EventLog -LogName Application -Source "BackupScript" -EntryType Information -EventId 1001 -Message "Backup realizado com sucesso para $destinationPath em $(Get-Date)."
        } else {
            throw "Nenhum arquivo encontrado na pasta de origem."
        }

        # Desmonta o compartilhamento
        Remove-PSDrive -Name $localDrive.TrimEnd(':')
        Write-Host "Compartilhamento desmontado com sucesso."
    } else {
        throw "Falha ao montar o compartilhamento de rede."
    }
} catch {
    # Registra falha no log de eventos
    Write-EventLog -LogName Application -Source "BackupScript" -EntryType Error -EventId 1002 -Message "Falha no backup: $($_.Exception.Message)"
    Write-Host "Erro: $($_.Exception.Message)"
}
