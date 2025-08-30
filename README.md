# 📦 MySQL Backup Script

A simple bash script to automate MySQL database backups with options for compression and upload.

## ℹ️ About

I created this script with ChatGPT because I quickly needed a database backup script for [my weather station](https://github.com/bartekl1/meteo). \
I do not plan to maintain it, but if you find it useful, feel free to use it.

## ✨ Features

- 💾 Local MySQL database backups using `mysqldump`
- 📦 Optional compression using `gzip`
- ☁️ Optional remote upload via [rclone](https://rclone.org/)
- 🧹 Optional cleanup of old local backups

## 🔧 Installation and usage

1. Install dependencies:

- `mysqldump` (part of MySQL client tools)
- `gzip` (optional for compression, usually pre-installed on most Linux distributions)
- `rclone` (optional for remote uploads, see [rclone installation guide](https://rclone.org/install/))

2. Clone the repository.

```bash
git clone https://github.com/bartekl1/mysql-backup.git
cd mysql-backup
cp backup.example.conf backup.conf
```

Instead of cloning the repository, you can also download the `backup.sh` script directly.

```bash
wget https://raw.githubusercontent.com/bartekl1/mysql-backup/refs/heads/main/backup.sh
wget https://raw.githubusercontent.com/bartekl1/mysql-backup/refs/heads/main/backup.example.conf -O backup.conf
```

3. Edit `backup.conf` configuration file. See the [Configuration](#configuration) section for more details.

4. Make the script executable.

```bash
chmod +x backup.sh
```

5. Manually run the script to test it.

```bash
./backup.sh
```

6. (Optional) Set up a cron job to automatically run the script at the desired time.

```bash
crontab -e
```

Example (backup every day at 2 AM):

```text
0 2 * * * bash /path/to/backup.sh
```

## ⚙️ Configuration

The script can be configured via the `backup.conf` file. \
Example configuration file is available in [`backup.example.conf`](backup.example.conf). \
See comments in the file for explanation of each option.

## 📜 License

This project is licensed under [Zero-Clause BSD License](LICENSE). \
This means you can freely use, modify, and redistribute the code for commercial and non-commercial purposes without attribution.
