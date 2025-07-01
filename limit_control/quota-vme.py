#!/usr/bin/env python3
import os, time, requests, subprocess
from pathlib import Path

def send_log(user, total2, total):
    chat_id = Path("/etc/lunatic/bot/notif/id").read_text().strip()
    key = Path("/etc/lunatic/bot/notif/key").read_text().strip()
    text = f"""
<code>────────────────────</code>
<b>⚠️NOTIF QUOTA HABIS XRAY VMESS⚠️</b>
<code>────────────────────</code>
<code>Username  : </code><code>{user}</code>
<code>limit Quota: </code><code>{total2}</code>
<code>Usage     : </code><code>{total}</code>
<code>────────────────────</code>
"""
    requests.post(
        f"https://api.telegram.org/bot{key}/sendMessage",
        data={
            "chat_id": chat_id,
            "text": text,
            "parse_mode": "html",
            "disable_web_page_preview": "1"
        }
    )

def convert(bytes):
    bytes = int(bytes)
    if bytes < 1024:
        return f"{bytes}B"
    elif bytes < 1024**2:
        return f"{(bytes + 1023) // 1024}KB"
    elif bytes < 1024**3:
        return f"{(bytes + 1024**2 - 1) // 1024**2}MB"
    else:
        return f"{(bytes + 1024**3 - 1) // 1024**3}GB"

def get_users():
    with open("/etc/xray/config.json") as f:
        return sorted(set(
            line.split()[1] for line in f if line.startswith("###")
        ))

def get_downlink(user):
    try:
        out = subprocess.check_output([
            "xray", "api", "stats", "--server=127.0.0.1:10000",
            f"-name=user>>>{user}>>>traffic>>>downlink"
        ]).decode()
        for line in out.splitlines():
            if '"value"' in line:
                return int(line.split('"')[3])
    except: return None

def main():
    Path("/etc/limit/vmess").mkdir(parents=True, exist_ok=True)
    while True:
        time.sleep(5)
        users = get_users()
        for user in users:
            downlink = get_downlink(user)
            if downlink is None: continue

            limit_file = Path(f"/etc/limit/vmess/{user}")
            if limit_file.exists():
                plus = int(limit_file.read_text() or 0)
                limit_file.write_text(str(downlink + plus))
            else:
                limit_file.write_text(str(downlink))

            subprocess.run([
                "xray", "api", "stats", "--server=127.0.0.1:10000",
                f"-name=user>>>{user}>>>traffic>>>downlink", "-reset"
            ], stdout=subprocess.DEVNULL)

        for user in users:
            usage_path = Path(f"/etc/lunatic/vmess/usage/{user}")
            if not usage_path.exists(): continue
            try:
                limit = int(usage_path.read_text())
                used = int(Path(f"/etc/limit/vmess/{user}").read_text())
                if used > limit:
                    total = convert(used)
                    total2 = convert(limit)
                    exp = subprocess.getoutput(f"grep -w '^### {user}' /etc/xray/config.json").split()[2]
                    subprocess.run(["sed", "-i", f"/^### {user} {exp}/,/^},{/d", "/etc/xray/config.json"])
                    subprocess.run(["sed", "-i", f"/^### {user} {exp}/d", "/etc/lunatic/vmess/.vmess.db"])
                    send_log(user, total2, total)
                    for path in [
                        f"/etc/limit/vmess/{user}",
                        f"/etc/lunatic/vmess/ip/{user}",
                        f"/etc/lunatic/vmess/usage/{user}",
                        f"/etc/lunatic/vmess/detail/{user}.txt",
                        f"/etc/vmess/{user}",
                        f"/var/www/html/vmess-{user}.txt"
                    ]:
                        try: os.remove(path)
                        except: pass
                    subprocess.run(["systemctl", "restart", "xray"])
            except: continue

if __name__ == "__main__":
    main()
