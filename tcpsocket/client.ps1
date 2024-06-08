try {
    $ipendpoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Parse("127.0.0.1"), 10101)
    $tcpclient = New-Object System.Net.Sockets.TcpClient
    $tcpclient.Connect($ipendpoint)
    $stream = $tcpclient.GetStream()

    $data = "Hello Server!"
    $stream.Write([System.Text.Encoding]::ASCII.GetBytes($data), 0, $data.Length)
    while ($true) {
        $bytes = new-object System.Byte[] 1024
        $bytesRead = $stream.Read($bytes, 0, $bytes.Length)
        $data = [System.Text.Encoding]::ASCII.GetString($bytes, 0, $bytesRead)

        if ($bytesRead -gt 0) {
            Write-Host "Server Response: " $data
        }

        $input = Read-Host "Type message to send to server: "
        $stream.Write([System.Text.Encoding]::ASCII.GetBytes($input), 0, $input.Length)
        $stream.Flush()
    }
} catch {
    Write-Host "Error connecting to server: " $_.Exception.Message
}

$stream.Close()
$tcpclient.Close()

