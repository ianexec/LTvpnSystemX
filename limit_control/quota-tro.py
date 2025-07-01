#!/usr/bin/env python3
# trojan_quota_checker.py
import os
import time
import requests
import subprocess
from pathlib import Path

def send_log(user, total):
    try:
        chat_id = Path("/etc/lunatic/bot/notif/id").read_text().strip()
        key = Path("/etc/lunatic/bot/notif/key").read_text().strip()
        text = f"""
<code>────────────────────</code>
<b>⚠️NOTIF QUOTA HABIS⚠️</b>
<code>────────────────────</code>
<code>Username  : </code><code>{user}</code>
<code>Usage     : </code><code>{total}</code>
<code>────────────────────</code>
"""
        requests.post(
            f"https://api.telegram.org/bot{key}/sendMessage",
            data={"chat_id": chat_id, "text": text, "parse_mode": "html", "disable_web_page_preview": "1"},
            timeout=10
        )
    except Exception as e:
        print(f"[ERROR] Failed to send Telegram log: {e}")

def convert_bytes(bytes_val):
    bytes_val = int(bytes_val)
    if bytes_val < 1024:
        return f"{bytes_val}B"
    elif bytes_val < 1048576:
        return f"{(bytes_val + 1023)//1024}KB"
    elif bytes_val < 1073741824:
        return f"{(bytes_val + 1048575)//1048576}MB"
    return f"{(bytes_val + 1073741823)//1073741824}GB"

def get_users():
    users = []
    try:
        with open("/etc/xray/config.json") as f:
            for line in f:
                if line.startswith("#!"):
                    parts = line.split()
                    if len(parts) >= 2:
                        users.append(parts[1])
        return sorted(set(users))
    except Exception as e:
        print("Failed to get users:", e)
        return []

def get_downlink(user):
    try:
        result = subprocess.check_output(
            ["xray", "api", "stats", "--server=127.0.0.1:10000", f"-name=user>>>{user}>>>traffic>>>downlink"],
            stderr=subprocess.DEVNULL
        ).decode()
        for line in result.splitlines():
            if '"value"' in line:
                return int(line.split('"')[3])
    except:
        return None

def main():
    Path("/etc/limit/trojan").mkdir(parents=True, exist_ok=True)

    while True:
        time.sleep(30)
        users = get_users()
        for user in users:
            downlink = get_downlink(user)
            if downlink is None:
                continue

            user_file = Path(f"/etc/limit/trojan/{user}")
            existing = int(user_file.read_text().strip()) if user_file.exists() else 0
            user_file.write_text(str(existing + downlink))

            subprocess.run([
                "xray", "api", "stats", "--server=127.0.0.1:10000",
                f"-name=user>>>{user}>>>traffic>>>downlink", "-reset"
            ], stdout=subprocess.DEVNULL)

        # Check usage
        for user in users:
            try:
                if not Path(f"/etc/trojan/{user}").exists():
                    continue
                usage_path = Path(f"/etc/lunatic/trojan/usage/{user}")
                if not usage_path.exists():
                    continue
                limit = int(usage_path.read_text().strip())
                used = int(Path(f"/etc/limit/trojan/{user}").read_text().strip())

                if used > limit:
                    total = convert_bytes(used)
                    exp = subprocess.getoutput(f"grep -w '^#! {user}' /etc/xray/config.json").split()[2]
                    subprocess.run(["sed", "-i", f"/^#! {user} {exp}/,/^}},{{/d", "/etc/xray/config.json"])
                    subprocess.run(["sed", "-i", f"/^#! {user} {exp}/d", "/etc/lunatic/trojan/.trojan.db"])
                    send_log(user, total)

                    for path in [
                        f"/etc/lunatic/trojan/ip/{user}",
                        f"/etc/lunatic/trojan/detail/{user}.txt",
                        f"/etc/lunatic/trojan/usage/{user}",
                        f"/etc/limit/trojan/{user}",
                        f"/etc/limit/trojan/quota/{user}",
                        f"/etc/trojan/{user}",
                        f"/var/www/html/trojan-{user}.txt"
                    ]:
                        try: os.remove(path)
                        except: pass

                    subprocess.run(["systemctl", "restart", "xray"])
            except Exception as err:
                print(f"[ERROR] While checking user {user}: {err}")

if __name__ == "__main__":
    main()
