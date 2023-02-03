#!/bin/sh
#
# tmstatus.sh
#
# A simple script to summarize the Time Machine backup status
#
# Copyright (c) 2018-2022 Matteo Corti <matteo@corti.li>
#
# This module is free software; you can redistribute it and/or modify it
# under the terms of the Apache License v2
# See the LICENSE file for details.
#

# shellcheck disable=SC2034
VERSION=1.7.0

export LC_ALL=C

format_size() {
    while read -r B; do
        [ "${B}" -lt 1024 ] && echo "${B}" B && break
        KB=$(((B + 512) / 1024))
        [ "${KB}" -lt 1024 ] && echo "${KB}" KB && break
        MB=$(((KB + 512) / 1024))
        [ "${MB}" -lt 1024 ] && echo "${MB}" MB && break
        GB=$(((MB + 512) / 1024))
        [ "${GB}" -lt 1024 ] && echo "${GB}" GB && break
        echo $(((GB + 512) / 1024)) TB
    done
}

days_since() {

    start_date=$1

    start=$(date -j -f "%Y-%m-%d-%H%M%S" "${start_date}" "+%s")

    end=$(date -j '+%s')

    seconds=$((end - start))
    days=$((seconds / 60 / 60 / 24))

    echo "${days}"

}

format_days_ago() {

    days=$1

    if [ "${days}" -eq 0 ]; then
        echo 'less than one day ago'
    elif [ "${days}" -eq 1 ]; then
        echo "${days} day ago"
    else
        echo "${days} days ago"
    fi

}

# adapted from https://unix.stackexchange.com/questions/27013/displaying-seconds-as-days-hours-mins-seconds
format_timespan() {

    input_in_seconds=$1

    days=$((input_in_seconds / 60 / 60 / 24))
    hours=$((input_in_seconds / 60 / 60 % 24))
    minutes=$((input_in_seconds / 60 % 60))
    seconds=$((input_in_seconds % 60))

    if [ "${days}" -gt 0 ]; then
        [ "${days}" = 1 ] && printf "%d day " "${days}" || printf "%d days " "${days}"
    fi
    if [ "${hours}" -gt 0 ]; then
        [ "${hours}" = 1 ] && printf "%d hour " "${hours}" || printf "%d hours " "${hours}"
    fi
    if [ "${minutes}" -gt 0 ]; then
        [ "${minutes}" = 1 ] && printf "%d minute " "${minutes}" || printf "%d minutes " "${minutes}"
    fi
    if [ "${seconds}" -gt 0 ]; then
        [ "${seconds}" = 1 ] && printf "%d second" "${seconds}" || printf "%d seconds" "${seconds}"
    fi

}

COMMAND_LINE_ARGUMENTS=$*

while true; do

    case "$1" in
        -l | --log)
            SHOWLOG=1
            shift
            ;;
        *)
            if [ -n "$1" ]; then
                echo "Error: unknown option: ${1}"
            fi
            break
            ;;
    esac

done

HOSTNAME_TMP="$(hostname)"
printf 'Backups for "%s"\n\n' "${HOSTNAME_TMP}"

##############################################################################
# Backup statistics

KIND="$( tmutil destinationinfo | grep '^Kind' | sed 's/.*:\ //')"
if [ "${KIND}" = "Local" ] ; then
    KIND="Local disk"
fi

LISTBACKUPS=$( tmutil listbackups 2>&1 )

if echo "${LISTBACKUPS}" | grep -q -F 'listbackups requires Full Disk Access privileges'; then

    cat <<'EOF'
Error:

tmutil: listbackups requires Full Disk Access privileges.

To allow this operation, select Full Disk Access in the Privacy
tab of the Security & Privacy preference pane, and add Terminal
to the list of applications which are allowed Full Disk Access.

EOF
    exit 1

elif echo "${LISTBACKUPS}" | grep -q 'No machine directory found for host.'; then

    if tmutil status 2>&1 | grep -q 'HealthCheckFsck'; then

        printf 'Time Machine: no information available (performing backup verification)\n'

    else

        printf 'Time Machine (%s):\n' "${KIND}"
        printf 'Oldest:\t\toffline\n'
        printf 'Last:\t\toffline\n'
        printf 'Number:\t\toffline\n'

    fi

elif echo "${LISTBACKUPS}" | grep -q 'No backups found for host.'; then

    printf 'Time Machine: no backups found\n'

else

    tm_mount_point=$(tmutil destinationinfo | grep '^Mount\ Point' | sed 's/.*:\ //')

    tm_total=$(df -H "${tm_mount_point}" | tail -n 1 | awk '{ print $2 "\t" }' | sed 's/[[:blank:]]//g')
    tm_available=$(df -H "${tm_mount_point}" | tail -n 1 | awk '{ print $4 "\t" }' | sed 's/[[:blank:]]//g')

    tm_total_raw=$(df "${tm_mount_point}" | tail -n 1 | awk '{ print $2 "\t" }' | sed 's/[[:blank:]]//g')
    tm_available_raw=$(df "${tm_mount_point}" | tail -n 1 | awk '{ print $4 "\t" }' | sed 's/[[:blank:]]//g')
    tm_percent_available=$(echo "${tm_available_raw} * 100 / ${tm_total_raw}" | bc)
    
    printf 'Volume (%s) "%s": %s (%s available, %s%%)\n' "${KIND}" "${tm_mount_point}" "${tm_total}" "${tm_available}" "${tm_percent_available}"
    
    DATE="$( echo "${LISTBACKUPS}" | head -n 1 | sed 's/.*\///' | sed 's/[.].*//')"
    days="$(days_since "${DATE}")"
    backup_date=$( echo "${LISTBACKUPS}" | head -n 1 | sed 's/.*\///' | sed 's/[.].*//' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/')
    DAYS_AGO="$(format_days_ago "${days}")"
    printf 'Oldest:\t\t%s (%s)\n' "${backup_date}" "${DAYS_AGO}"

    LATESTBACKUP="$(tmutil latestbackup)"
    if echo "${LATESTBACKUP}" | grep -q '[0-9]'; then
        # a date was returned (should implement a better test)
        DATE="$( echo "${LATESTBACKUP}" | sed 's/.*\///' | sed 's/[.].*//')"
        days=$(days_since "${DATE}")
        backup_date=$( echo "${LATESTBACKUP}" | sed 's/.*\///' | sed 's/[.].*//' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/')
        DAYS_AGO="$(format_days_ago "${days}")"
        printf 'Last:\t\t%s (%s)\n' "${backup_date}" "${DAYS_AGO}"
    else
        printf 'Last:\t\t%s\n' "${LATESTBACKUP}"
    fi

    number=$( echo "${LISTBACKUPS}" | wc -l | sed 's/\ //g')
    printf 'Number:\t\t%s\n' "${number}"

fi

echo

##############################################################################
# Local backup statistics

LOCALSNAPSHOTDATES=$( tmutil listlocalsnapshotdates / 2>&1 )

if echo "${LOCALSNAPSHOTDATES}" | grep -q '[0-9]'; then

    tm_total=$(df -H / | tail -n 1 | awk '{ print $2 "\t" }' | sed 's/[[:blank:]]//g')
    tm_available=$(df -H / | tail -n 1 | awk '{ print $4 "\t" }' | sed 's/[[:blank:]]//g')

    tm_total_raw=$(df / | tail -n 1 | awk '{ print $2 "\t" }' | sed 's/[[:blank:]]//g')
    tm_available_raw=$(df / | tail -n 1 | awk '{ print $4 "\t" }' | sed 's/[[:blank:]]//g')
    tm_percent_available=$(echo "${tm_available_raw} * 100 / ${tm_total_raw}" | bc)
    
    printf 'Local: %s (%s available, %s%%)\n' "${tm_total}" "${tm_available}" "${tm_percent_available}"
    printf 'Local oldest:\t'
    echo "${LOCALSNAPSHOTDATES}" | sed -n 2p | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/'

    printf 'Local last:\t'
    echo "${LOCALSNAPSHOTDATES}" | tail -n 1 | sed 's/.*\///' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/'

    printf 'Local number:\t'
    echo "${LOCALSNAPSHOTDATES}" | wc -l | sed 's/\ //g'

    echo

fi

##############################################################################
# Current status

status=$(tmutil status)

if echo "${status}" | grep -q 'BackupPhase'; then

    phase=$(echo "${status}" | grep BackupPhase | sed 's/.*\ =\ //' | sed 's/;.*//')

    case "${phase}" in
    'BackupNotRunning')
        phase='Not running'
        ;;
    'DeletingOldBackups')
        phase='Deleting old backups'
        ;;
    'FindingBackupVol')
        phase='Looking for backup disk'
        ;;
    'FindingChanges')
        phase='Finding changes'
        ;;
    'HealthCheckCopyHFSMeta')
        phase='Verifying backup'
        ;;
    'HealthCheckFsck')
        phase='Verifying backup'
        ;;
    'LazyThinning')
        phase='Lazy thinning'
        ;;
    'MountingBackupVol')
        phase='Mounting backup volume'
        ;;
    'MountingBackupVolForHealthCheck')
        phase='Preparing verification'
        ;;
    'PreparingSourceVolumes')
        phase='Preparing source volumes'
        ;;
    'SizingChanges')
        phase='Sizing changes'
        ;;
    'ThinningPostBackup')
        phase='Finished: thinning backups'
        ;;
    'ThinningPreBackup')
        phase='Starting: thinning backups'
        ;;
    *) ;;

    esac

    printf 'Status:\t\t%s\n' "${phase}"

    if echo "${status}" | grep -q 'totalBytes'; then
        total_size=$(echo "${status}" | grep 'totalBytes\ \=' | sed 's/.*totalBytes\ \=\ //' | sed 's/;.*//' | format_size)
        printf 'Backup size:\t%s\n' "${total_size}"
    fi

    if echo "${status}" | grep -q Remaining; then

        echo
        
        secs=$(echo "${status}" | grep Remaining | sed 's/.*\ =\ //' | sed -e 's/.*\ =\ //' -e 's/;.*//' -e 's/^"//' -e 's/"$//' -e 's/[.].*//')

        # sometimes the remaining time is negative (?)
        if ! echo "${secs}" | grep -q '^"-'; then

            now=$(date +'%s')
            end=$((now + secs))
            end_formatted=$(date -j -f '%s' "${end}" +'%Y-%m-%d %H:%M')
            duration=$(format_timespan "${secs}")

            DATE1="$(date -j -f '%s' "${end}" +'%Y-%m-%d')"
            DATE2="$(date +'%Y-%m-%d')"
            if [ "${DATE1}" != "${DATE2}" ]; then
                end_formatted=$(date -j -f '%s' "${end}" +'%Y-%m-%d %H:%M')
            else
                end_formatted=$(date -j -f '%s' "${end}" +'%H:%M')
            fi

            if [ "${secs}" -eq 0 ]; then
                printf 'Time remaining:\tunknown (finishing)\n'
            else
                printf 'Time remaining:\t%s (finish by %s)\n' "${duration}" "${end_formatted}"
            fi

        fi

    fi

else

    printf 'Status:\t\tStopped\n'

fi

if echo "${status}" | grep '_raw_Percent' | grep -q -v '[0-9]e-'; then
    if echo "${status}" | grep -q '_raw_Percent" = 1;'; then
        percent='100%'
    else
        percent=$(echo "${status}" | grep '_raw_Percent" = "0' | sed 's/.*[.]//' | sed 's/\([0-9][0-9]\)\([0-9]\).*/\1.\2%/' | sed 's/^0//')
    fi
    printf 'Percent:\t%s\n' "${percent}"

    raw_percent=$( echo "${status}" | grep '_raw_Percent' | sed 's/.*\ =\ "//' | sed 's/".*//')

    if echo "${status}" | grep -q 'bytes'; then
        size=$(echo "${status}" | grep 'bytes\ \=' | sed 's/.*bytes\ \=\ //' | sed 's/;.*//')
        copied_size=$( echo "${size} / ${raw_percent}" | bc | format_size)
        size=$(echo "${size}" | format_size)
        printf 'Size:\t\t%s of %s\n' "${size}" "${copied_size}"
    fi

    
fi

# Print verifying status
if echo "${status}" | grep -q -F HealthCheckFsck; then
    if echo "${status}" | grep -q -F 'Percent = "0'; then
        percent=$(echo "${status}" | grep 'Percent = ' | sed 's/.*Percent\ =\ \"0\.//' | sed 's/\".*//')
        printf 'Percent:\t%s%%\n' "${percent}"
    fi
fi

echo

if [ -n "${SHOWLOG}" ]; then

    echo "Last log entries:"
    echo

    WIDTH=$(tput cols)

    printf '%.s-' $( seq 1 "${WIDTH}" )
    echo
    # per default TM runs each hour: check the last 60 minutes
    log show --predicate 'subsystem == "com.apple.TimeMachine"' --info --last 60m |
        grep --line-buffered --invert \
             --regexp '^Timestamp' \
             --regexp  'TMPowerState: [0-9]' \
             --regexp 'Running for notifyd event com.apple.powermanagement.systempowerstate' \
             --regexp 'com.apple.backupd.*.xpc: connection invalid' \
             --regexp 'Skipping scheduled' \
             --regexp 'Failed to find a disk' \
             --regexp 'notifyd ' \
             --regexp TMSession \
             --regexp BackupScheduling \
             --regexp 'Mountpoint.*is still valid' \
             --regexp Local \
             --regexp 'Accepting a new connection' \
             --regexp 'Backup list requested' \
             --regexp 'Spotlight' \
             --regexp 'Rejected a new connection' |
        sed -e 's/\.[0-9]*+[0-9][0-9][0-9][0-9] 0x[0-9a-f]* */ /' \
            -e 's/^[^0-9]/\t/' \
            -e 's/\ *0x0 *[0-9]* *[0]9* */ /' \
            -e 's/com.apple.TimeMachine://' \
            -e 's/(TimeMachine) //' \
            -e 's/backupd-helper: //' \
            -e 's/backupd: //;' \
            -e 's/\]/\t/' \
            -e 's/\[//' |
        expand -t 27 |
        cut -c -"${WIDTH}" |
        tail -n 20
    
    printf '%.s-' $( seq 1 "$(tput cols)" )
    echo
    
fi

