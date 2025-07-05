#!/bin/bash
clear

echo -e "[INFO] Mengatur semua jadwal cron..."

# --- Auto Delete Account Expired Harian (jam 00:02)
cat >/etc/cron.d/xp_all <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root /usr/bin/xp
END

# --- Clean Log Tiap 59 Menit
cat >/etc/cron.d/logclean <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/59 * * * * root /usr/bin/logclean
END

# --- Reboot Otomatis Harian Jam 05:00
cat >/etc/cron.d/daily_reboot <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 5 * * * /sbin/reboot
END

# --- Backup Otomatis Jam 00:02
cat >/etc/cron.d/autobackup <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root /usr/local/sbin/autobackup
END

# --- Kill Akun Per 1 Menit (Xray & SSH)
cat >/etc/cron.d/kill_account <<-END
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
*/1 * * * * root /usr/local/sbin/kill_exp exp_kill
*/1 * * * * root /usr/local/sbin/kill_exp vme_kill
*/1 * * * * root /usr/local/sbin/kill_exp vle_kill
*/1 * * * * root /usr/local/sbin/kill_exp tro_kill
*/1 * * * * root /usr/local/sbin/kill_exp ssh_kill
*/1 * * * * root /usr/local/sbin/killVM.py
*/1 * * * * root /usr/local/sbin/killVL.py
*/1 * * * * root /usr/local/sbin/killTR.py
*/1 * * * * root /usr/local/sbin/killSSH.py
END

# --- Tambahan Cron untuk Backup Cek Expired Trial setiap 5 menit
cat >/etc/cron.d/check_trial_expired <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/5 * * * * root /usr/local/sbin/check_trial_expired.py
END

echo -e "[INFO] Semua cron telah berhasil dibuat dan diatur."
