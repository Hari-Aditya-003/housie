#!/bin/zsh

set -euo pipefail

project_root="${0:A:h:h}"
app_file="$project_root/Housie/App/HousieApp.swift"
view_model_file="$project_root/Housie/App/CallerViewModel.swift"
caller_file="$project_root/Housie/Features/Caller/CallerView.swift"
guide_file="$project_root/Housie/Features/Rules/HowToPlayView.swift"

fail() {
    print -u2 "FAIL: $1"
    exit 1
}

if rg -q 'TicketView\(' "$app_file"; then
    fail "The main app still exposes the Tickets tab."
fi

if rg -q 'AnnouncementLanguage|తెలుగు|te-IN' "$view_model_file" "$caller_file"; then
    fail "The caller still exposes multiple languages instead of one English voice."
fi

rg -q 'AirPlayRoutePicker' "$caller_file" || fail "The caller has no AirPlay TV control."
rg -q 'Text\("How It Works"\)' "$guide_file" || fail "The compact guide is not titled How It Works."
rg -q 'ForEach\(1\.\.\.90' "$caller_file" || fail "The caller board does not render every number from 1 to 90."
rg -q 'Text\(String\(number\)\)' "$caller_file" || fail "Board cells do not visibly render their number."

print "PASS: Caller experience matches the simplified product requirements"
