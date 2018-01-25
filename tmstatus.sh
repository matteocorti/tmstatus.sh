#!/bin/sh
#
# tmstatus.sh
#
# A simple script to summarise the Time Machine backup status
#
# Copyright (c) 2018 Matteo Corti <matteo@corti.li>
#
# This module is free software; you can redistribute it and/or modify it
# under the terms of the Apache Licese v2
# See the LICENSE file for details.
#

format_size(){
    while read -r B ; do
	[ "$B" -lt 1024 ] && echo "${B}" B && break
	KB=$(((B+512)/1024))
	[ "$KB" -lt 1024 ] && echo "${KB}" KB && break
	MB=$(((KB+512)/1024))
	[ "$MB" -lt 1024 ] && echo "${MB}" MB && break
	GB=$(((MB+512)/1024))
	[ "$GB" -lt 1024 ] && echo "${GB}" GB && break
	echo $(((GB+512)/1024)) TB
    done
}

days_since(){

    start_date=$1

    start=$(date -j -f "%Y-%m-%d-%H%M%S" "${start_date}" "+%s")

    end=$(date -j '+%s')

    seconds=$((end - start))
    days=$(( seconds / 60 / 60 / 24 + 1))

    echo "${days}"
    
}

format_days_ago() {

    days=$1

    if [ "${days}" -eq 0 ] ; then
	echo 'today'
    elif [ "${days}" -eq 1 ] ; then
	echo "${days} day ago"
    else
	echo "${days} days ago"
    fi

}

printf "Backups "
hostname
echo

##############################################################################
# Backup statistics

if tmutil listbackups 2>&1 | grep -q 'No machine directory found for host.' ; then

    printf 'Oldest:\t\toffline\n'
    printf 'Last:\t\toffline\n'
    printf 'Number:\t\toffline\n'

else

    days=$( days_since "$(tmutil listbackups | head -n 1 | sed 's/.*\///')" )
    backup_date=$( tmutil listbackups  | head -n 1 | sed 's/.*\///' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/')
    printf 'Oldest:\t\t%s (%s)\n' "${backup_date}" "$( format_days_ago "${days}" )"

    days=$( days_since "$( tmutil latestbackup | sed 's/.*\///' )" )
    backup_date=$( tmutil latestbackup | sed 's/.*\///' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/')
    printf 'Last:\t\t%s (%s)\n' "${backup_date}" "$( format_days_ago "${days}" )"

    number=$( tmutil listbackups | wc -l | sed 's/\ //g' )
    printf 'Number:\t\t%s\n' "${number}"
    
fi

echo

##############################################################################
# Local backup statistics

if tmutil listlocalsnapshotdates / 2>&1 | grep -q '[0-9]' ; then

    printf 'Local oldest:\t'
    tmutil listlocalsnapshotdates / | sed -n 2p | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/'

    printf 'Local last:\t'
    tmutil listlocalsnapshotdates / | tail -n 1 | sed 's/.*\///' | sed 's/-\([^\-]*\)$/\ \1/' | sed 's/\([0-9][0-9]\)\([0-9][0-9]\)\([0-9][0-9]\)/\1:\2:\3/'

    printf 'Local number:\t'
    tmutil  listlocalsnapshotdates / | wc -l | sed 's/\ //g'

    echo

fi

##############################################################################
# Current status

status=$(tmutil status);

if echo "${status}" | grep -q 'BackupPhase' ; then
    
    phase=$( echo "${status}" | grep BackupPhase | sed 's/.*\ =\ //' | sed 's/;.*//' )

    case "${phase}" in
	'ThinningPostBackup')
	    phase='Finished: thinning backups'
	    ;;
	'ThinningPreBackup')
	    phase='Starting: thinning backups'
	    ;;
    esac

    printf 'Status:\t\t%s\n' "${phase}"

    echo;

    if echo "${status}" | grep -q  Remaining ; then
	
	secs=$(echo "${status}" | grep Remaining | sed 's/.*\ =\ //' | sed 's/;.*//');

	now=$(date +'%s')
	end=$(( now + secs ))
	end_formatted=$( date -j -f '%s' $end +'%Y-%m-%d %H:%M' )

	if [ "$(date -j -f '%s' $end +'%Y-%m-%d')" != "$(date +'%Y-%m-%d')" ] ; then
	    end_formatted=$( date -j -f '%s' $end +'%Y-%m-%d %H:%M' )
	else
	    end_formatted=$( date -j -f '%s' $end +'%H:%M' )
	fi
    
	printf 'Time remaining:\t%dh:%dm:%ds (finish by %s)\n' $((secs/3600)) $((secs%3600/60)) $((secs%60)) "${end_formatted}"

    fi
	
else

    printf 'Status:\t\tStopped\n'

fi

if echo "${status}" | grep '_raw_Percent' | grep -q -v '[0-9]e-' ; then
    percent=$(echo "${status}" | grep '_raw_Percent" = "0' | sed 's/.*[.]//' | sed 's/\([0-9][0-9]\)\([0-9]\).*/\1.\2%/' | sed 's/^0//')
    printf 'Percent:\t%s\n' "$percent";
fi

if echo "${status}" | grep -q 'totalBytes' ; then
    total_size=$(echo "${status}" | grep 'totalBytes\ \=' | sed 's/.*totalBytes\ \=\ //' | sed 's/;.*//' | format_size)
    size=$(echo "${status}" | grep 'bytes\ \=' | sed 's/.*bytes\ \=\ //' | sed 's/;.*//' | format_size)
    printf 'Size:\t\t%s of %s\n' "$size" "$total_size";
fi
    
echo
