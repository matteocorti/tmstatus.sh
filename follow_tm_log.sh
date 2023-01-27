#!/bin/sh

log stream --color=always --predicate 'subsystem == "com.apple.TimeMachine"' --info |
    grep --line-buffered --invert-match Browsing |
    grep --line-buffered --invert-match TMSession |
    grep --line-buffered --invert-match BackupClientManager |
    grep --line-buffered --invert-match connection\ invalid |
    grep --line-buffered --invert-match Mountpoint
