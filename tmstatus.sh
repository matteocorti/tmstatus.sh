#!/bin/sh
#
# tmstatus.sh
#
# A simple script to summarise the Time Machine backup status
#
# Copyright (c) 2018-2021 Matteo Corti <matteo@corti.li>
#
# This module is free software; you can redistribute it and/or modify it
# under the terms of the Apache Licese v2
# See the LICENSE file for details.
#

# shellcheck disable=SC2034
VERSION=1.3.0

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

printf 'Backups %s\n\n' "$(hostname)"

##############################################################################
# Backup statistics

if tmutil listbackups 2>&1 | grep -q 'No machine directory found for host.'; then

    if tmutil status 2>&1 | grep -q 'HealthCheckFsck'; then

        printf 'Time Machine: no information available (performing backup verification)\n'

    else

        printf 'Time Machine (offline):\n'
        printf 'Oldest:\t\toffline\n'
        printf 'Last:\t\toffline\n'
        printf 'Number:\t\toffline\n'

    fi

elif tmutil listbackups 2>&1 | grep -q 'No backups found for host.'; then

    printf 'Time Machine: no backups found\n'

else

    tm_mount_point=$(tmutil destinationinfo | grep '^Mount\ Point' | sed 's/.*:\ //')
    tm_total=$(df -H "${tm_mount_point}" | tail -n 1 | awk '{ print $2 "\t" }' | sed 's/[[:blank:]]//g')
    tm_available=$(df -H "${tm_mount_point}" | tail -n 1 | awk '{ print $4 "\t" }' | sed 's/[[:blank:]]//g')
    printf '%s: %s (%s available)\n' "${tm_mount_point}" "${tm_total}" "${tm_available}"

    days=$(days_since "$(tmutil listbackups | head -n 1 | sed 's/.*\///' | sed 's/[.].*//' )")
    backup_date=$(tmutil listbackups | head -n 1 | sed 's/.*\///' |  | sed 's/[.].*//' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/')
    printf 'Oldest:\t\t%s (%s)\n' "${backup_date}" "$(format_days_ago "${days}")"

    latestbackup="$(tmutil latestbackup)"
    if echo "${latestbackup}" | grep -q '[0-9]'; then
        # a date was returned (should implement a better test)
        days=$(days_since "$(tmutil latestbackup | sed 's/.*\///')")
        backup_date=$(tmutil latestbackup | sed 's/.*\///' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/')
        printf 'Last:\t\t%s (%s)\n' "${backup_date}" "$(format_days_ago "${days}")"
    else
        printf 'Last:\t\t%s\n' "${latestbackup}"
    fi

    number=$(tmutil listbackups | wc -l | sed 's/\ //g')
    printf 'Number:\t\t%s\n' "${number}"

fi

echo

##############################################################################
# Local backup statistics

if tmutil listlocalsnapshotdates / 2>&1 | grep -q '[0-9]'; then

    tm_total=$(df -H / | tail -n 1 | awk '{ print $2 "\t" }' | sed 's/[[:blank:]]//g')
    tm_available=$(df -H / | tail -n 1 | awk '{ print $4 "\t" }' | sed 's/[[:blank:]]//g')
    printf 'Local: %s (%s available)\n' "${tm_total}" "${tm_available}"
    printf 'Local oldest:\t'
    tmutil listlocalsnapshotdates / | sed -n 2p | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/'

    printf 'Local last:\t'
    tmutil listlocalsnapshotdates / | tail -n 1 | sed 's/.*\///' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/'

    printf 'Local number:\t'
    tmutil listlocalsnapshotdates / | wc -l | sed 's/\ //g'

    echo

fi

##############################################################################
# Current status

status=$(tmutil status)

if echo "${status}" | grep -q 'BackupPhase'; then

    phase=$(echo "${status}" | grep BackupPhase | sed 's/.*\ =\ //' | sed 's/;.*//')

    case "${phase}" in
    'ThinningPostBackup')
        phase='Finished: thinning backups'
        ;;
    'ThinningPreBackup')
        phase='Starting: thinning backups'
        ;;
    'DeletingOldBackups')
        phase='Deleting old backups'
        ;;
    'MountingBackupVol')
        phase='Mounting backup volume'
        ;;
    'FindingChanges')
        phase='Finding changes'
        ;;
    'SizingChanges')
        phase='Sizing changes'
        ;;
    'HealthCheckFsck')
        phase='Verifying backup'
        ;;
    'PreparingSourceVolumes')
        phase='Preparing source volumes'
        ;;
    'MountingBackupVolForHealthCheck')
        phase='Preparing verification'
        ;;
    *) ;;

    esac

    printf 'Status:\t\t%s\n' "${phase}"

    echo

    if echo "${status}" | grep -q Remaining; then

        secs=$(echo "${status}" | grep Remaining | sed 's/.*\ =\ //' | sed 's/;.*//')

        # sometimes the remaining time is negative (?)
        if ! echo "${secs}" | grep -q '^"-'; then

            now=$(date +'%s')
            end=$((now + secs))
            end_formatted=$(date -j -f '%s' "${end}" +'%Y-%m-%d %H:%M')
            duration=$(format_timespan "${secs}")

            if [ "$(date -j -f '%s' "${end}" +'%Y-%m-%d')" != "$(date +'%Y-%m-%d')" ]; then
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
fi

if echo "${status}" | grep -q 'totalBytes'; then
    total_size=$(echo "${status}" | grep 'totalBytes\ \=' | sed 's/.*totalBytes\ \=\ //' | sed 's/;.*//' | format_size)
    size=$(echo "${status}" | grep 'bytes\ \=' | sed 's/.*bytes\ \=\ //' | sed 's/;.*//' | format_size)
    printf 'Size:\t\t%s of %s\n' "${size}" "${total_size}"
fi

# Print verifying status
if echo "${status}" | grep -q -F HealthCheckFsck; then
    if echo "${status}" | grep -q -F 'Percent = "0'; then
        percent=$(echo "${status}" | grep 'Percent = ' | sed 's/.*Percent\ =\ \"0\.//' | sed 's/\".*//')
        printf 'Percent:\t%s%%\n' "${percent}"
    fi
fi

echo

date

echo
