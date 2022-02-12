# xCloud Wireshark Dissector

This repo contains a wireshark dissector to view xCloud RTP traffic.

## Requirements:

- LUA 5.2 (Other versions dont work)
- luegcrypt (https://github.com/Lekensteyn/luagcrypt)
- NodeJS (For generating the keys only)

## Setup

1. Install the plugin in wireshark
2. Go to Preferences -> Protocols -> XCLOUD-RTP
3. Enter keys generated from your SRTP key that matches your PCAP file (more below)

## How to get your keys from the SRTP key?

1. Make sure you have NodeJS installed for this step.
2. Open extract_keys.js and replace the SRTP Key on line 103
3. Run the script via `node extract_keys.js`