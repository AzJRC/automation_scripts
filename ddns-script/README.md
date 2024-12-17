Dynamic DDNS Script

- This script automatically updates DNS records in DigitalOcean.
- A file `.env` must be created in the same directory as the `ddns.sh` script
    - `API_TOKEN`: Your DigitalOcean API token.
    - `DOMAIN`: Your domain name.
    - `RECORD_ID`: Your record ID. You would need to use DigitalOcean's API manually to get this value.
    - `LOG_FILE`: A file to save the logs of the script. Recommended to store this file in `/var/log/ddns-script/ddns-script.log`.
- Copy the systemd files in the `/etc/systemd/system/` folder and enable them. Run `systemctl daemon-reload` before enabling and starting the services.
