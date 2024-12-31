# Ensure Outlook is running
if (-not (Get-Process -Name OUTLOOK -ErrorAction SilentlyContinue)) {
    Start-Process "outlook.exe"
    Start-Sleep -Seconds 5
}

# Create Outlook COM objects
$Outlook = New-Object -ComObject Outlook.Application
$Namespace = $Outlook.GetNamespace("MAPI")
$Calendar = $Namespace.GetDefaultFolder([Microsoft.Office.Interop.Outlook.OlDefaultFolders]::olFolderCalendar).Items

# Filter calendar events for today
$Today = (Get-Date).Date
$Tomorrow = $Today.AddDays(1)
$Calendar.IncludeRecurrences = $true
$Events = $Calendar | Where-Object {
    $_.Start -ge $Today -and $_.Start -lt $Tomorrow
}

# Build the email body
$EmailBody = "<html><body><h1>Today's Calendar Events</h1><ul>"

if ($Events.Count -gt 0) {
    foreach ($Event in $Events) {
        $EmailBody += "<li><strong>Subject:</strong> $($Event.Subject)<br>
                       <strong>Start:</strong> $($Event.Start.ToString('g'))<br>
                       <strong>End:</strong> $($Event.End.ToString('g'))<br>
                       <strong>Location:</strong> $($Event.Location)</li>"
    }
} else {
    $EmailBody += "<li>No events scheduled for today.</li>"
}

$EmailBody += "</ul></body></html>"

# Send the email
$MailItem = $Outlook.CreateItem(0) # 0 = MailItem
$MailItem.Subject = "Today's Calendar Events"
$MailItem.HTMLBody = $EmailBody
$MailItem.To = "mgdawkins2019@gmail.com"
$MailItem.Send()

Write-Host "Email sent successfully to mgdawkins2019@gmail.com"
