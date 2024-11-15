# PowerShell Script to wake up computer and prevent screen saver
# Runs indefinitely with 12-minute intervals

while ($true) {
    # Simulate mouse move (slight X, Y axis movement)
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class MouseMover {
        [DllImport("user32.dll")]
        public static extern void mouse_event(int dwFlags, int dx, int dy, int dwData, int dwExtraInfo);
        public const int MOUSEEVENTF_MOVE = 0x0001;
        public static void MoveMouse() {
            mouse_event(MOUSEEVENTF_MOVE, 1, 0, 0, 0);
            mouse_event(MOUSEEVENTF_MOVE, -1, 0, 0, 0);
        }
    }
"@

    # Invoke the mouse move
    [MouseMover]::MoveMouse()

    # Output a message indicating action
    Write-Host "Moved mouse to prevent screen saver and wake the computer."

    # Wait for 12 minutes (720 seconds)
    Start-Sleep -Seconds 720
}
