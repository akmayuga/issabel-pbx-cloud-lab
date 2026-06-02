# Call Test Procedures

Run these tests after both softphones show `Registered`.

## 1. Registration

On the PBX:

```bash
asterisk -rx "pjsip show contacts"
asterisk -rx "pjsip show endpoints"
```

Expected result:

- `1001` has at least one contact.
- `1002` has at least one contact.
- Endpoint state is reachable or available.

## 2. Basic Calling

1. From `1001`, dial `1002`.
2. Answer on `1002`.
3. Confirm two-way audio.
4. Hang up.
5. Repeat from `1002` to `1001`.

If the call connects but has no audio, check RTP firewall rules and NAT settings.

## 3. Blind Transfer

1. From `1001`, call `1002`.
2. Use the transfer button in the softphone.
3. Transfer to `1001` or `600`.
4. Confirm the target rings.

The dialplan includes `Tt` so transfers are permitted by caller and callee.

## 4. Voicemail

1. From `1001`, dial `1002`.
2. Let the call time out.
3. Leave a message.
4. From `1002`, dial `*97`.
5. Enter the voicemail PIN from `ansible/group_vars/issabel.yml`.
6. Confirm the message can be played.

## 5. IVR

1. Dial `700`.
2. Wait for the menu prompt.
3. Press `1`.
4. Confirm extension `1001` rings.
5. Dial `700` again.
6. Press `2`.
7. Confirm extension `1002` rings.

## 6. Ring Group

1. Dial `600`.
2. Confirm both `1001` and `1002` ring.
3. Answer on either extension.
4. Confirm audio works.

## 7. Call Recording

Make any internal call, then check:

```bash
ls -lah /var/spool/asterisk/monitor
```

Expected result: a `.wav` recording file appears for the test call.

## 8. Time Condition

1. Dial `800` during Monday-Friday, 09:00-17:00 in the PBX timezone.
2. Confirm it routes to `1001`.
3. Test outside that window or temporarily adjust the time in `extensions_custom.conf`.
4. Confirm it routes to `1002`.

## 9. CDR

After calls, inspect CSV call records:

```bash
ls -lah /var/log/asterisk/cdr-csv
tail -n 5 /var/log/asterisk/cdr-csv/Master.csv
```

Expected result: each call creates a CDR row.

## 10. Monitoring

Run:

```bash
/usr/local/sbin/healthcheck.sh
curl -s http://127.0.0.1:9100/metrics | grep asterisk_
```

Expected result:

- `asterisk_service_up 1`
- `asterisk_pjsip_registered_contacts` is `2` or higher when both phones are registered.
