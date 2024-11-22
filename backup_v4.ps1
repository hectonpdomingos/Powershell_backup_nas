# Configurações
$sourcePath = "C:\cliente\backup"    # Pasta onde estão os backups
$networkPath = "\\192.168.1.10\backups"  # Caminho do compartilhamento sem autenticação

try {
    # Obtém o último arquivo criado na pasta de origem
    $latestFile = Get-ChildItem -Path $sourcePath -File | Sort-Object CreationTime -Descending | Select-Object -First 1

    if ($latestFile) {
        Write-Host "Último arquivo encontrado: $($latestFile.Name)"
        $destinationPath = Join-Path -Path $networkPath -ChildPath $latestFile.Name

        # Usa Robocopy para copiar o arquivo
        $robocopyCommand = "robocopy.exe `"$sourcePath`" `"$networkPath`" $($latestFile.Name) /R:3 /W:5"
        Invoke-Expression $robocopyCommand

        Write-Host "Arquivo copiado com sucesso para: $destinationPath"

        # Registra sucesso no log de eventos
        if (-not (Get-EventLog -LogName Application -Source "BackupScript" -ErrorAction SilentlyContinue)) {
            New-EventLog -LogName Application -Source "BackupScript"
        }
        Write-EventLog -LogName Application -Source "BackupScript" -EntryType Information -EventId 1001 -Message "Backup realizado com sucesso para $destinationPath em $(Get-Date)."
    } else {
        throw "Nenhum arquivo encontrado na pasta de origem."
    }
} catch {
    # Registra falha no log de eventos
    if (-not (Get-EventLog -LogName Application -Source "BackupScript" -ErrorAction SilentlyContinue)) {
        New-EventLog -LogName Application -Source "BackupScript"
    }
    Write-EventLog -LogName Application -Source "BackupScript" -EntryType Error -EventId 1002 -Message "Falha no backup: $($_.Exception.Message)"
    Write-Host "Erro: $($_.Exception.Message)"
}
