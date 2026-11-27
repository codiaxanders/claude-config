---
name: codiax-tate-rig
description: Codiax office test rig — TATE hosts (power/reset/serial per target), login, tatectl, tate-web HTTP API + console, claims, board mapping, USB-serial recovery
metadata:
  type: reference
---

Office test rig at Codiax, reachable from home over VPN (rig net 192.168.75.0/24; VPN clients appear as 192.168.70.x). A **TATE** is a BeagleBone (Yocto, armv7) that switches power/reset for several **targets** and exposes their serial consoles. Hosts: tate4.codiax, tate5, tate6, tate7.codiax, tate8, tate11. tate101 is a different, older home setup ([[tate101-imx8mp-var-dart-target]] in the atlas-demo project memory) — not part of the office rig.

**Overview page:** http://gallery.codiax/ lists every tate, target id, name and last update. Each tate also has its own page http://tateN.codiax/ (target list, web terminal, API manual at /api).

**Login:** `tateusr` / `tatepw` (user OK'd storing it; nothing secret on the rig). Password only, no pubkey; host keys not in known_hosts. `tateusr` is in the sudo group, same password (`echo tatepw | sudo -S -p "" ...`). No sshpass on WS1 → SSH_ASKPASS script echoing the password + `SSH_ASKPASS_REQUIRE=force DISPLAY=:0`, with `-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o PubkeyAuthentication=no`.

**tatectl (TATE 2.1.0, `/usr/bin/tatectl`, python, talks to tated over /tmp/tate-socket):** config `/etc/tate.conf` (YAML: id, type gpio|sispm, tty, reset_only, active_low, gpiochip/line_nr or sispm_outlet, name). `-n/-f/-r ID` on/off/reset, `-c/-u ID` claim/unclaim (needs `export TATE_USER=<name>`), `-ll` list, `--get-json`, `-s ID` picocom. **Always exits 0, even on refusal** — check output/state. Reset on sispm/gpio power target = off, 1 s, on; on a `reset_only` gpio = pulse on the reset line; on/off refused for reset_only.

**tate-web HTTP API (no auth, nginx → gunicorn :8000, /opt/tate-web/api.py):**
- `GET /api/v1/targets`, `GET /api/v1/targets/<id>` → name, type, reset_only, tty, state ON/OFF, claimed_by, claimed_until.
- `POST /api/v1/targets/<id>/toggle|reset|claim|unclaim` with JSON `{"name": "<user>"}`; claim also `timeout_minutes` (1–1440, or "inf"/"eod") and `force`.
- toggle/reset reply `{"status":"ok"}` **even when tate refused** (claimed by someone else, reset_only) → re-read `state`. Only toggle exists: read state first, toggle only if different.
- claim → 409 if held by another name (a `SERIAL.` prefix is stripped before comparing); same name re-claims (refresh). Only the holder can unclaim without force. Expired claims are dropped by tated, which also kills users of the target's tty.
- Console: Socket.IO namespace `/terminal`, URL `http://tateN.codiax/terminal?target_id=<id>`, header `Cookie: tate_user=<name>`, events `output`/`input`. On connect it sends `\r` (getty prints `<hostname> login:`) and claims as `SERIAL.<name>` only if unclaimed. Works with python-socketio 5.x client.
- Direct serial on the tate also works: `stty -F /dev/ttyTGTn 115200 raw -echo; timeout N cat /dev/ttyTGTn` (never two readers at once).
- Identity check trick: from the target, `echo <token> > /dev/<console>` (first word of /proc/consoles), read it on the tate's console → proves which target id the board is on.

**Atlas demo boards (2026-11-27):** SSH `root@<host>` with no password.

| board | host | tate | power id | reset id | console tty (tate) / board |
|---|---|---|---|---|---|
| beaglebone-yocto | atlas-demo-bbb-1.codiax | tate7 | 1 gpio | – | ttyTGT1 / ttyS0 |
| imx93-11x11-lpddr4x-frdm | atlas-demo-frdm-1.codiax | tate7 | – | 3 (reset_only) | ttyTGT11 / ttyLP0 |
| imx93-var-som-a0 | atlas-demo-varsom-1.codiax | tate7 | 4 sispm | – | ttyTGT6 / ttyLP0 |
| imx95-19x19-verdin | atlas-demo-imx95-1.codiax | tate4 | 6 sispm | – | ttyTGT6.3 / ttyLP0 |
| imx8mm-lpddr4-evk | atlas-demo-imx8mm-1.codiax | tate4 | 3 sispm | 11 (reset line) | ttyTGT3.2 / ttymxc1 |

Other targets: tate7 2 = Atlas demo BBB 2 (2026-11-27: boots Atlas 5.0.10 scarthgap from eMMC, RAUC A/B, IP 192.168.75.122 via DHCP, no DNS name, SSH `root@` without password, Python 3.12 but no cryptography/docker/package manager; not in CI or the 4G flow, free for lab work — used for SSM/Anigma native runs under /data/ssm); tate4 4 = Boundary Devices Nitrogen8M (i.MX8MQ, runs Android 8.1, console ttyTGT4), 1 BeagleBoneBlack, 2 BananaPi, 5 Surfcleaner-BBB, 7 Setek HMX. atlas-demo's CI power tests lock boards with claims named `atlas-ci-<run_id>-<board>`; locally `atlas-ci-local`.

**USB-serial hang (tate4 imx8mm, FT2232 on USB port 1-1.2, 2026-11-27):** dmesg `ftdi_sio ... -110`, tate-web "Unexpected connection error". Recovered without replug, as root on tate4: `authorized` 0→1 (config failed), USBDEVFS_RESET ioctl (21780) on `/dev/bus/usb/001/<devnum>`, then `echo 1 > /sys/bus/usb/devices/1-1.2/bConfigurationValue`. Not caused by power-cycling the board (the adapter is USB-powered from the tate).
