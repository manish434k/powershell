param (
    [string]$ipAddress = "127.0.0.1",
    [int]$port = 10101
)
try {
    $listener = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Parse($ipAddress), $port)
    $listener.Start()
    Write-Host "TCP Server started on $ipAddress $port"

    $running = $true

    Register-EngineEvent PowerShell.Exiting -Action {
        $running = $false
        $listener.Stop()
        Write-Host "TCP Server stopped"
    }

    while ($running) {
        try {
            $client = $listener.AcceptTcpClient()
            $stream = $client.GetStream()
            while ($client.Connected) {
                $buffer = new-object System.Byte[] 1024
                try {
                    $bytesRead = $stream.Read($buffer, 0, $buffer.Length)
                } catch [System.ObjectDisposedException] {
                    break
                }
                $data = [System.Text.Encoding]::ASCII.GetString($buffer, 0, $bytesRead)
                Write-Host "ReceivedClient Message: " $data
                Write-Host "Message received"
                $input = Read-Host "Type message to send to client: "
                $stream.Write([System.Text.Encoding]::ASCII.GetBytes($input), 0, $input.Length)
                $stream.Flush()
            }
        } catch {
            Write-Host "Error accepting client connection: $($_.Exception.Message)"
        }
    }
    $stream.Close()
    $client.Close()
} catch {
    Write-Host "Error starting TCP server: $($_.Exception.Message)"
}
