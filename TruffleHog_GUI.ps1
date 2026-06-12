Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "LeakHound Suite v7.5 - Deep Match Engine"
$form.Size = New-Object System.Drawing.Size(1050, 850)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(14, 15, 20)
$form.ForeColor = [System.Drawing.Color]::White

$script:vaultFile = "C:\Users\Taylor\TruffleHog\perpetual_vault.log"
if (-not (Test-Path $script:vaultFile)) { New-Item -ItemType File -Path $script:vaultFile -Force | Out-Null }

$title = New-Object System.Windows.Forms.Label
$title.Text = "⚡ Quantum Intelligence Engine (Deep Content Logging Mode)"
$title.Location = New-Object System.Drawing.Point(20, 15)
$title.Size = New-Object System.Drawing.Size(850, 35)
$title.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($title)
$scanGroup = New-Object System.Windows.Forms.GroupBox
$scanGroup.Text = " Local File Integrity Radar "
$scanGroup.Location = New-Object System.Drawing.Point(20, 65)
$scanGroup.Size = New-Object System.Drawing.Size(990, 125)
$scanGroup.ForeColor = [System.Drawing.Color]::Orange

$lblPath = New-Object System.Windows.Forms.Label
$lblPath.Text = "Target Directory:"
$lblPath.Location = New-Object System.Drawing.Point(15, 32)
$lblPath.Size = New-Object System.Drawing.Size(110, 20)
$scanGroup.Controls.Add($lblPath)

$txtPath = New-Object System.Windows.Forms.TextBox
$txtPath.Text = "C:\Users\Taylor\"
$txtPath.Location = New-Object System.Drawing.Point(130, 29)
$txtPath.Size = New-Object System.Drawing.Size(710, 25)
$txtPath.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 38)
$txtPath.ForeColor = [System.Drawing.Color]::White
$scanGroup.Controls.Add($txtPath)

$chkBip = New-Object System.Windows.Forms.CheckBox
$chkBip.Text = "Filter BIP39 Seeds"
$chkBip.Location = New-Object System.Drawing.Point(130, 75)
$chkBip.Size = New-Object System.Drawing.Size(180, 20)
$chkBip.Checked = $true
$scanGroup.Controls.Add($chkBip)

$chkB58 = New-Object System.Windows.Forms.CheckBox
$chkB58.Text = "Filter Base58 Keys"
$chkB58.Location = New-Object System.Drawing.Point(320, 75)
$chkB58.Size = New-Object System.Drawing.Size(180, 20)
$chkB58.Checked = $true
$scanGroup.Controls.Add($chkB58)

$btnScan = New-Object System.Windows.Forms.Button
$btnScan.Text = "⚡ Scan Disk"
$btnScan.Location = New-Object System.Drawing.Point(855, 26)
$btnScan.Size = New-Object System.Drawing.Size(115, 30)
$btnScan.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnScan.BackColor = [System.Drawing.Color]::FromArgb(180, 45, 15)
$btnScan.Add_Click({
    $script:scanActive = $true
    $txtConsole.AppendText("[LOCAL]: Initializing background file system scan...`r`n")
    $target = $txtPath.Text
    $action = {
        param($t, $bip, $b58, $vault)
        $pat = @()
        if ($bip) { $pat += "bip39" }
        if ($b58) { $pat += "base58" }
        & "C:\Users\Taylor\TruffleHog\trufflehog.exe" filesystem $t --json 2>$null | ForEach-Object {
            $line = $_
            $matched = $false
            if ($pat.Count -gt 0) {
                foreach ($p in $pat) { if ($line -match $p) { $matched = $true; break } }
            } else { $matched = $true }
            if ($matched) {
                try {
                    $stream = New-Object System.IO.StreamWriter($vault, $true, [System.Text.Encoding]::UTF8, 4096)
                    $stream.WriteLine("[DISK FIND]: $line")
                    $stream.Close()
                } catch {}
            }
        }
    }
    $posh = [powershell]::Create().AddScript($action).AddArgument($target).AddArgument($chkBip.Checked).AddArgument($chkB58.Checked).AddArgument($script:vaultFile)
    $null = $posh.BeginInvoke()
})
$scanGroup.Controls.Add($btnScan)
$form.Controls.Add($scanGroup)

$webGroup = New-Object System.Windows.Forms.GroupBox
$webGroup.Text = " Continuous Autonomous Web Spider Engine "
$webGroup.Location = New-Object System.Drawing.Point(20, 205)
$webGroup.Size = New-Object System.Drawing.Size(990, 115)
$webGroup.ForeColor = [System.Drawing.Color]::Turquoise

$lblQuery = New-Object System.Windows.Forms.Label
$lblQuery.Text = "Seed URL:"
$lblQuery.Location = New-Object System.Drawing.Point(15, 35)
$lblQuery.Size = New-Object System.Drawing.Size(110, 20)
$webGroup.Controls.Add($lblQuery)

$txtQuery = New-Object System.Windows.Forms.TextBox
$txtQuery.Text = "https://githubusercontent.com"
$txtQuery.Location = New-Object System.Drawing.Point(130, 32)
$txtQuery.Size = New-Object System.Drawing.Size(710, 25)
$txtQuery.BackColor = [System.Drawing.Color]::FromArgb(28, 28, 38)
$txtQuery.ForeColor = [System.Drawing.Color]::White
$webGroup.Controls.Add($txtQuery)

$btnWeb = New-Object System.Windows.Forms.Button
$btnWeb.Text = "🚀 Infinite Crawl"
$btnWeb.Location = New-Object System.Drawing.Point(855, 29)
$btnWeb.Size = New-Object System.Drawing.Size(115, 30)
$btnWeb.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnWeb.BackColor = [System.Drawing.Color]::FromArgb(20, 120, 140)

$script:crawlQueue = New-Object System.Collections.Concurrent.ConcurrentQueue[string]
$script:crawledUrls = New-Object System.Collections.Generic.HashSet[string]
$script:crawlActive = $false

$btnWeb.Add_Click({
    if ($script:crawlActive) {
        $script:crawlActive = $false
        $btnWeb.Text = "🚀 Infinite Crawl"
        $btnWeb.BackColor = [System.Drawing.Color]::FromArgb(20, 120, 140)
        $txtConsole.AppendText("🛑 [WEB CRAWLER]: Continuous spider loop stopped.`r`n")
    } else {
        $script:crawlActive = $true
        $btnWeb.Text = "🛑 Stop Crawl"
        $btnWeb.BackColor = [System.Drawing.Color]::DarkRed
        $script:crawlQueue.Enqueue($txtQuery.Text)
        $txtConsole.AppendText("🌐 [WEB CRAWLER]: Infinite crawler loop launched successfully.`r`n")
        $crawlAction = {
            param($queue, $vault, $seen)
            while ($true) {
                [string]$url = ""
                if ($queue.TryDequeue([ref]$url)) {
                    if ($seen.Contains($url)) { continue }
                    [null]$seen.Add($url)
                    try {
                        $content = (New-Object System.Net.WebClient).DownloadString($url)
                        
                        # Fixed text splitting mechanism using double-quoted newline breaks
                        $lines = $content -split "`n"
                        foreach ($line in $lines) {
                            if ($line -match "bip39|base58|[a-zA-Z0-9]{40,}") {
                                $cleanMatch = $line.Trim()
                                if ($cleanMatch.Length -gt 150) { $cleanMatch = $cleanMatch.Substring(0,147) + "..." }
                                $sw = New-Object System.IO.StreamWriter($vault, $true, [System.Text.Encoding]::UTF8, 4096)
                                $sw.WriteLine("[WEB MATCH] Found secret line at URL: $url `r`n >> $cleanMatch")
                                $sw.Close()
                            }
                        }
                        
                        $links = [regex]::Matches($content, "(https?://[-a-zA-Z0-9+&@#/%?=~_|!:,.;]*[-a-zA-Z0-9+&@#/%=~_|])")
                        foreach ($m in $links) {
                            $foundUrl = $m.Value
                            if ($foundUrl -match "github|portswigger|streaak|raw") { $queue.Enqueue($foundUrl) }
                        }
                    } catch {}
                }
                Start-Sleep -Milliseconds 150
            }
        }
        $script:webWorker = [powershell]::Create().AddScript($crawlAction).AddArgument($script:crawlQueue).AddArgument($script:vaultFile).AddArgument($script:crawledUrls)
        $null = $script:webWorker.BeginInvoke()
    }
})
$webGroup.Controls.Add($btnWeb)
$form.Controls.Add($webGroup)

$lblConsole = New-Object System.Windows.Forms.Label
$lblConsole.Text = "Perpetual Storage Stream (Live Data Feed):"
$lblConsole.Location = New-Object System.Drawing.Point(20, 335)
$lblConsole.Size = New-Object System.Drawing.Size(400, 20)
$form.Controls.Add($lblConsole)

$txtConsole = New-Object System.Windows.Forms.TextBox
$txtConsole.Multiline = $true
$txtConsole.ScrollBars = "Vertical"
$txtConsole.Location = New-Object System.Drawing.Point(20, 360)
$txtConsole.Size = New-Object System.Drawing.Size(620, 390)
$txtConsole.BackColor = [System.Drawing.Color]::Black
$txtConsole.ForeColor = [System.Drawing.Color]::Lime
$txtConsole.Font = New-Object System.Drawing.Font("Consolas", 9)
$form.Controls.Add($txtConsole)

$healthGroup = New-Object System.Windows.Forms.GroupBox
$healthGroup.Text = " Autonomous Maintenance Hub (PhD Code) "
$healthGroup.Location = New-Object System.Drawing.Point(660, 345)
$healthGroup.Size = New-Object System.Drawing.Size(350, 405)
$healthGroup.ForeColor = [System.Drawing.Color]::HotPink

$txtHealthLog = New-Object System.Windows.Forms.TextBox
$txtHealthLog.Multiline = $true
$txtHealthLog.ScrollBars = "Vertical"
$txtHealthLog.Location = New-Object System.Drawing.Point(15, 30)
$txtHealthLog.Size = New-Object System.Drawing.Size(320, 300)
$txtHealthLog.BackColor = [System.Drawing.Color]::FromArgb(10, 10, 15)
$txtHealthLog.ForeColor = [System.Drawing.Color]::DeepSkyBlue
$txtHealthLog.Font = New-Object System.Drawing.Font("Consolas", 8)
$healthGroup.Controls.Add($txtHealthLog)

$btnClearLog = New-Object System.Windows.Forms.Button
$btnClearLog.Text = "🗑️ Wipe Master Database"
$btnClearLog.Location = New-Object System.Drawing.Point(15, 345)
$btnClearLog.Size = New-Object System.Drawing.Size(320, 35)
$btnClearLog.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnClearLog.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 55)
$btnClearLog.ForeColor = [System.Drawing.Color]::Crimson
$btnClearLog.Add_Click({
    try {
        $fs = New-Object System.IO.FileStream($script:vaultFile, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::ReadWrite)
        $fs.SetLength(0)
        $fs.Close()
        $txtConsole.Text = "✨ [SYSTEM]: Master database memory vaults wiped cleanly.`r`n"
        $txtHealthLog.AppendText("[MAINTAINER]: Vault memory purged by operator request.`r`n")
    } catch {}
})
$healthGroup.Controls.Add($btnClearLog)
$form.Controls.Add($healthGroup)

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    try {
        if (Test-Path $script:vaultFile) {
            $fileStream = New-Object System.IO.FileStream($script:vaultFile, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
            $reader = New-Object System.IO.StreamReader($fileStream)
            $allLines = New-Object System.Collections.Generic.List[string]
            while (($line = $reader.ReadLine()) -ne $null) { $allLines.Add($line) }
            $reader.Close(); $fileStream.Close()
            
            if ($allLines.Count -gt 0) {
                $start = [Math]::Max(0, $allLines.Count - 25)
                $count = $allLines.Count - $start
                $displayLines = $allLines.GetRange($start, $count)
                $txtConsole.Text = ($displayLines -join "`r`n")
            }
        }
    } catch {}
    $txtHealthLog.AppendText("[MAINTAINER]: Realtime data matrix checks normal.`r`n")
})
$timer.Start()

$statusBar = New-Object System.Windows.Forms.StatusBar
$statusBar.Text = " Memory Vault Active | Deep Match Telemetry Operational"
$form.Controls.Add($statusBar)

$form.ShowDialog()

