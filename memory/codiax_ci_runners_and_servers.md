---
name: codiax-ci-runners-and-servers
description: Codiax Forgejo CI runners (heineken, tuborg) and tuborg's TFTP/NFS boot server on the rig net
metadata:
  type: reference
---

**Forgejo:** git.codiax.se (Forgejo 16.0.5), ssh remote `ssh://git@git.codiax.se:222/...`. The REST API needs a token; `tea` on WS1 has no login yet, so CI runs can't be read from a session unless the user adds one (`tea login add --url https://git.codiax.se --token ...`, the user handles the token).

**Runners (2026-11-27):** two hosts, **heineken** and **tuborg**, each running two docker containers: `forgejo-runner-test` and `forgejo-runner-build` (`forgejo-runner daemon --config /config/config.yml`, under dumb-init). Test runners have `capacity: 4` each → 8 concurrent `atlas-test` jobs in total. Check config with `docker exec forgejo-runner-test grep -n -E 'capacity|labels' /config/config.yml`.

**tuborg as boot server:** Ubuntu (resolute), `eno1` 192.168.75.15/24 on the rig net. Set up 2026-11-27 for netbooting rig boards:
- TFTP: tftpd-hpa, `/srv/tftp` (owner anders), `--secure` (paths relative to /srv/tftp, e.g. `tate/<file>`).
- NFS: nfs-kernel-server, `/etc/exports.d/nitrogen8m.exports`: `/srv/nfs/nitrogen8m 192.168.75.0/24(rw,sync,no_subtree_check,no_root_squash)`. mountd pinned to port 20048 in `/etc/nfs.conf`.
- ufw active: allows from 192.168.75.0/24 udp 69, 111, 2049, 20048 (plus OpenSSH). VPN clients (192.168.70.x) are not allowed, so test from a tate (e.g. `tftp -g -r tate/test.txt 192.168.75.15` on tate4).
- Old netboot server 192.168.75.144 (used by Nitrogen8M's U-Boot env) no longer answers.
