# Get the gateway IP address and interface for the route to 10.219.64.17
# Outputs in the format: "<gateway IP> - <interface>"
ip route get 10.219.64.17 | head -n1 | awk '{print $3 " - " $5}'

# Download the backup script from the specified URL to the /shared directory
curl -o /shared/backup.py https://librenms.sys.comerica.com/f5/backup.py

# Make the downloaded script executable
chmod +x /shared/backup.py

# Backup the current crontab configuration to a file in the /shared directory
crontab -l | tee /shared/crontab.backup

# Schedule a cron job to run the backup script at 1:30 AM every Monday, Thursday, and Saturday
# First, comment out any existing lines containing "backup.sh" or "backup.py"
# Then, append the new cron job and apply the updated crontab
(crontab -l | sed -e '/backup\.[sh|py]/ s/^#*/#/' 2>/dev/null; 
echo "30 1 * * Mon,Thu,Sat /shared/backup.py >/dev/null 2>&1") | crontab -

# Verify the updated crontab configuration
crontab -l
