#!/bin/zsh

set -euo pipefail

project_root="${0:A:h:h}"
podfile="$project_root/Podfile"
app_file="$project_root/Housie/App/HousieApp.swift"
cast_file="$project_root/Housie/Casting/GoogleCastManager.swift"
caller_file="$project_root/Housie/Features/Caller/CallerView.swift"
view_model_file="$project_root/Housie/App/CallerViewModel.swift"
info_file="$project_root/Housie/Resources/Info.plist"
receiver_file="$project_root/GoogleCastReceiver/app.js"
receiver_html="$project_root/GoogleCastReceiver/index.html"
receiver_css="$project_root/GoogleCastReceiver/styles.css"

fail() {
    print -u2 "FAIL: $1"
    exit 1
}

[[ -f "$podfile" ]] || fail "The Google Cast iOS SDK dependency is missing."
grep -Eq "pod ['\"]google-cast-sdk['\"]" "$podfile" || fail "The Podfile does not include Google's Cast SDK."

[[ -f "$cast_file" ]] || fail "The iOS Google Cast coordinator is missing."
grep -Eq 'GCKCastContext' "$cast_file" || fail "The Google Cast context is not configured."
grep -Eq 'GCKUICastButton' "$cast_file" || fail "The official Google Cast device button is missing."
grep -Eq 'urn:x-cast:com\.housie\.board' "$cast_file" || fail "The Housie board message channel is missing."
grep -Eq 'didChangeWritableState' "$cast_file" || fail "Cast state is not retried when the TV channel becomes writable."
grep -Eq '@UIApplicationDelegateAdaptor' "$app_file" || fail "Google Cast is not initialized at app launch."
grep -Eq 'GoogleCastButton' "$caller_file" || fail "The caller screen does not expose Google Cast."
grep -Eq 'publish.*Cast|castManager\.publish' "$view_model_file" || fail "Caller state is not synchronized to the TV."

[[ -f "$info_file" ]] || fail "The Cast local-network permissions are missing."
grep -Eq 'NSBonjourServices' "$info_file" || fail "Bonjour services are not configured for Cast discovery."
grep -Eq 'NSLocalNetworkUsageDescription' "$info_file" || fail "The Cast local-network permission message is missing."

[[ -f "$receiver_file" ]] || fail "The Google TV web receiver is missing."
grep -Eq 'urn:x-cast:com\.housie\.board' "$receiver_file" || fail "The TV receiver does not listen to the Housie channel."
grep -Eq 'calledNumbers' "$receiver_file" || fail "The TV receiver does not render called numbers."

grep -Fq '© Hari' "$receiver_html" || fail "The TV receiver is missing the Hari copyright footer."
number_rule="$(sed -n '/^\.number {/,/^}/p' "$receiver_css")"
grep -Fq 'border-radius: 50%' <<< "$number_rule" || fail "TV board numbers are not circular."

print "PASS: AirPlay and Google Cast implementation files are present"
