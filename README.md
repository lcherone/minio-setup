# minio docker

the crontab entry

```
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin

@reboot cd /var/www/html && bash ./start.sh -s >> ./console.log 2>&1
```