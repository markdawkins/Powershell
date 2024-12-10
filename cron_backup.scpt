
ip route get 10.219.64.17 | head -n1 | awk '{print $3 " - " $5}'


curl -o /shared/backup.py https://librenms.sys.comerica.com/f5/backup.py


chmod +x /shared/backup.py


crontab -l | tee /shared/crontab.backup

### Schedule cron job (1:30a every M,W,F)
(crontab -l | sed -e '/backup\.[sh|py]/ s/^#*/#/' 2>/dev/null; 
echo "30 1 * * Mon,Thu,Sat /shared/backup.py >/dev/null 2>&1") | crontab -

crontab -l
