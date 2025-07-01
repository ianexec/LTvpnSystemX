#!/usr/bin/env python3
# save as monitor_quota.py
import os
import time
import requests
import subprocess
from pathlib import Path

def send_log(user, total2, total):
    chat_id = Path("/etc/lunatic/bot/notif/id").read_text().strip()
    key = Path("/etc/lunatic/bot/notif/key").read_text().strip()
    url = f"https://api.telegram.org/bot{key}/sendMessage"
    text = f"""
<code>────────────────────</code>
<b>⚠️NOTIF QUOTA HABIS XRAY VLESS⚠️</b>
<code>────────────────────</code>
<code>Username  : </code><code>{user}</code>
<code>limit Quota: </code><code>{total2}</code>
<code>Usage     : </code><code>{total}</code>
<code>────────────────────</code>
"""
    requests.post(url, data={
        "chat_id": chat_id,
        "text": text,
        "parse_mode": "html",
        "disable_web_page_preview": "1"
    })

def convert_bytes(byte_val):
    byte_val = int(byte_val)
    if byte_val < 1024:
        return f"{byte_val}B"
    elif byte_val < 1048576:
        return f"{(byte_val + 1023)//1024}KB"
    elif byte_val < 1073741824:
        return f"{(byte_val + 1048575)//1048576}MB"
    else:
        return f"{(byte_val + 1073741823)//1073741824}GB"

def get_downlink(user):
    try:
        result = subprocess.check_output([
            "xray", "api", "stats", "--server=127.0.0.1:10000",
            f"-name=user>>>{user}>>>traffic>>>downlink"
        ]).decode()
        for line in result.splitlines():
            if '"value"' in line:
                return int(line.split('"')[3])
    except:
        return None

def main():
    while True:
        time.sleep(5)
        try:
            with open("/etc/xray/config.json") as f:
                users = sorted(set(
                    line.split()[1]
                    for line in f if line.startswith("#&")
                ))
        except:
            users = []

        Path("/etc/limit/vless").mkdir(parents=True, exist_ok=True)

        for user in users:
            downlink = get_downlink(user)
            if downlink is None: continue
            usage_file = Path(f"/etc/limit/vless/{user}")
            if usage_file.exists():
                current = int(usage_file.read_text().strip() or 0)
                usage_file.write_text(str(downlink + current))
            else:
                usage_file.write_text(str(downlink))
            subprocess.run([
                "xray", "api", "stats", "--server=127.0.0.1:10000",
                f"-name=user>>>{user}>>>traffic>>>downlink", "-reset"
            ], stdout=subprocess.DEVNULL)

        for user in users:
            usage_path = Path(f"/etc/lunatic/vless/usage/{user}")
            if not usage_path.exists(): continue
            limit = int(usage_path.read_text().strip())
            used = int(Path(f"/etc/limit/vless/{user}").read_text().strip())
            if used > limit:
                send_log(user, convert_bytes(limit), convert_bytes(used))
                for f in [
                    f"/etc/xray/config.json",
                    f"/etc/lunatic/vless/.vless.db"
                ]:
                    subprocess.run(["sed", "-i", f"/^#& {user} /d", f])
                for path in [
                    f"/etc/vless/{user}",
                    f"/etc/limit/vless/{user}",
                    f"/etc/limit/vless/quota/{user}",
                    f"/etc/lunatic/vless/usage/{user}",
                    f"/etc/lunatic/vless/detail/{user}.txt",
                    f"/var/www/html/vless-{user}.txt"
                ]:
                    try: os.remove(path)
                    except: pass
                subprocess.run(["systemctl", "restart", "xray"])

if __name__ == "__main__":
    main()
