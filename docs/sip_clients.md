# SIP Softphone Configuration

Replace `<PBX_HOST>` with your VM public IP, DNS name, or WireGuard address. Use the passwords you set in `ansible/group_vars/issabel.yml`.

## Common Settings

| Setting | Value |
|---|---|
| SIP server/domain | `<PBX_HOST>` |
| SIP port | `5060` |
| Transport | UDP |
| Registration | Enabled |
| Codec | PCMU/ulaw first, PCMA/alaw second |
| DTMF | RFC 2833/RFC 4733 |
| STUN | Off when using WireGuard or direct public IP |

## Extension 1001

| Setting | Value |
|---|---|
| Username | `1001` |
| Auth username | `1001` |
| Password | `extension_1001_password` |
| Display name | `Lab 1001` |
| Voicemail | `*97` |

## Extension 1002

| Setting | Value |
|---|---|
| Username | `1002` |
| Auth username | `1002` |
| Password | `extension_1002_password` |
| Display name | `Lab 1002` |
| Voicemail | `*97` |

## Zoiper

1. Open `Settings -> Accounts -> Add`.
2. Select SIP account.
3. Use `1001@<PBX_HOST>` or `1002@<PBX_HOST>`.
4. Enter the extension password.
5. Set transport to UDP.
6. Disable STUN for direct or VPN testing.
7. Confirm the account shows `Registered`.

## Linphone

1. Open `Preferences -> Manage SIP Accounts`.
2. Add an account.
3. SIP address: `sip:1001@<PBX_HOST>`.
4. Username: `1001`.
5. Password: your generated password.
6. Transport: UDP.
7. Confirm registration in the account status.

## MicroSIP

1. Right-click the MicroSIP window and choose `Add account`.
2. Account name: `Issabel 1001`.
3. SIP server: `<PBX_HOST>`.
4. SIP proxy: leave empty unless you use a proxy.
5. Username and login: `1001`.
6. Password: your generated password.
7. Transport: UDP.
8. Save and confirm `Online`.

## Useful Dial Codes

| Dial | Result |
|---|---|
| `1001` | Call extension 1001 |
| `1002` | Call extension 1002 |
| `600` | Ring group for 1001 and 1002 |
| `700` | IVR, press 1 for 1001 or 2 for 1002 |
| `800` | Time condition demo |
| `*97` | Voicemail login for caller extension |
