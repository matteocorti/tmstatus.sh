
# tmstatus.sh

&copy; Matteo Corti, 2018-2023

![](https://img.shields.io/github/v/release/matteocorti/tmstatus.sh)&nbsp;![](https://img.shields.io/github/downloads/matteocorti/tmstatus.sh/latest/total)&nbsp;![](https://img.shields.io/github/downloads/matteocorti/tmstatus.sh/total)&nbsp;![](https://img.shields.io/github/license/matteocorti/tmstatus.sh)&nbsp;![](https://img.shields.io/github/stars/matteocorti/tmstatus.sh)&nbsp;![](https://img.shields.io/github/forks/matteocorti/tmstatus.sh)

A simple script to summarize the Time Machine backup status.

Sample output (```./tmstatus.sh --speed --log --today```)

```text
Backups for "Matteo’s MacBook Pro"

Volume (Local disk) "/Volumes/External Office": 1.0T (93G available, 9%)
  Oldest:	2023-06-28 11:35:25 (23 days ago)
  Last:		2023-07-21 13:36:34 (less than one day ago)
  Number:	16

Volume (Local disk) "/Volumes/Time Machine Office": 6.0T (660G available, 10%)
  Oldest:	2022-09-30 11:49:44 (294 days ago)
  Last:		2023-07-21 13:36:34 (less than one day ago)
  Number:	39

Local: 995G (138G available, 13%)
  Local oldest:	2023-07-20 13:34:45 (1 day ago)
  Local last:	2023-07-21 13:22:17 (less than one day ago)
  Local number:	10

Status:         Stopped

3 backups today (2023-07-21) on "/Volumes/External Office" at 09:22 (6.9 GB), 10:51 (3.59 GB), 13:36 (2.85 GB)
2 backups today (2023-07-21) on "/Volumes/Time Machine Office" at 09:57 (8.49 GB), 12:33 (3.53 GB)

Last log entries (last 20 entries in the last 3600m):
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                   bytes = 2845208576;
                                   files = 6451;
                                   sizingFreePreflight = 1;
                                   totalBytes = 836630519808;
                                   totalFiles = 3715161;
                               };
                               Running = 1;
                               "com.apple.backupd.SnapshotTotalBytesCopied" = 2845208576;
                           }
2023-07-21 13:36:34 Info General                       Found incomplete backups ready for deletion: (
                               "<APFSBackup: > (2023-07-21-105134.previous) baseline"
                           )
2023-07-21 13:36:42 Info BackupThinning                Deleted incomplete backup '/Volumes/External Office/2023-07-21-105134.previous'
2023-07-21 13:36:42 Info General                       Creating APFS snapshot com.apple.TimeMachine.2023-07-21-133634.backup
2023-07-21 13:36:43 Info Manifest                      17 backups: 2023-06-28-113525 to 2023-07-03-125401 (1hr,3d,4wk,9m) MΔ: 11.72 GB
2023-07-21 13:36:43 Info General                       Completed backup: 2023-07-21-133634.backup
2023-07-21 13:36:43 Info BackupThinning                Thinning 1 backups using age-based thinning, expected free space: 92.9 GB actual free space: 92.9 GB trigger 50 GB thin 83.33 GB da
                               "2023-07-20-122943"
                           )
2023-07-21 13:36:43 Info General                       Unmounted '/Volumes/.timemachine/975AE10D-DA02-4EBF-B707-51680391E23A/2023-07-20-122943.backup'
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

```

## Usage

```text

Usage: tmstatus.sh [OPTIONS]

Options:
   -a,--all                        Show information for all the volumes
   -h,--help,-?                    This help message
   -l,--log [lines]                Show the last log lines
   -p,--progress                   Show a progress bar
   -q,--quick                      Skip the backup listing
   -s,--speed                      Show the speed of the running backup
   -t,--today                      List today's backups
   -v,--verbose                    Show all the available information
   -V,--version                    Version

Report bugs to https://github.com/matteocorti/tmstatus.sh/issues
```

## Bugs

Report bugs to https://github.com/matteocorti/tmstatus.sh/issues
