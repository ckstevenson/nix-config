# Antivirus scanning

The workstation uses the open-source ClamAV engine with its `clamd` daemon and
the `freshclam` signature updater. It is configured for on-demand scanning;
files are not scanned automatically on access.

## Scan a download

Use the daemon for normal scans:

```bash
clamdscan --fdpass ~/Downloads/file.zip
clamdscan --fdpass --multiscan ~/Downloads
```

For a one-off scan without the daemon:

```bash
clamscan --recursive ~/Downloads
```

`--fdpass` lets the daemon scan files that are readable by your user but not by
the daemon account. A clean result ends with `OK`; detections are reported with
`FOUND`.

## Check the services

```bash
systemctl status clamav-daemon.service
systemctl status clamav-freshclam.service
freshclam --version
```

The signature updater runs automatically. Do not expose ClamAV's daemon socket
over TCP; use the local Unix socket.
