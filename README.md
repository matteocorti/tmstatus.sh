
# tmstatus.sh

&copy; Matteo Corti, 2018-2023

![](https://img.shields.io/github/v/release/matteocorti/tmstatus.sh)&nbsp;![](https://img.shields.io/github/downloads/matteocorti/tmstatus.sh/latest/total)&nbsp;![](https://img.shields.io/github/downloads/matteocorti/tmstatus.sh/total)&nbsp;![](https://img.shields.io/github/license/matteocorti/tmstatus.sh)&nbsp;![](https://img.shields.io/github/stars/matteocorti/tmstatus.sh)&nbsp;![](https://img.shields.io/github/forks/matteocorti/tmstatus.sh)

A simple script to summarize the Time Machine backup status.

Sample output (```./tmstatus.sh --speed --log --today```)

```text
Backups for "macbookpro"

Volume (Local disk) "/Volumes/Time Machine Office": 6.0T (106G available, 1%)
Oldest:		2022-07-18 12:19:45 (288 days ago)
Last:		2023-05-03 10:53:32 (less than one day ago)
Number:		27

Local: 995G (196G available, 19%)
Local oldest:	2023-05-02 12:51:08
Local last:	2023-05-03 10:55:52
Local number:	6

Status:		Copying |••••••••  |
Backup size:	727 GB

Time remaining:	1 minute 25 seconds (finish by 11:03)
Percent:	82.6% (15 %/min)
Size:		2 GB of 2 GB (6.25 MB/s, avg: 6.25 MB/s)
Speed:		56.96 items/s, avg: 56.96 items/s

2 backups today (2023-05-03) at
  * 10:14
  * 10:53

Last log entries (last 20 entries):

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
2023-05-03 10:56:01 Info EventCollection               Finished collecting events on 1 volumes...
2023-05-03 10:56:01 Info SizingProgress                Estimated a total of 3503449 files (780.56 GB) will be in backup of 'Home storage (Offline)'
2023-05-03 10:56:01 Info SizingProgress                Estimated full backup will contain 3503449 files (780.56 GB) from all sources
2023-05-03 10:56:01 Info CopyProgress                  Starting propagation look-ahead for "Home storage (Offline)"
2023-05-03 10:56:01 Info CopyProgress                  Copying "Home storage (Offline)" (device: /dev/disk3s5 mount: '/System/Volumes/Data' fsUUID: 18CF3BC7-F23B-4779-B83F-D8858CF9E064 eventDBUUID: 9DC621CC-B29E-4632-816D-569AD
2023-05-03 10:56:07 Info CopyProgress                  Calculated first time remaining estimate. Waiting for more samples...
2023-05-03 10:56:21 Info CopyProgress                  .          .
                                                      Progress: 4% done, -, - MB/s, avg: 0.00 MB/s, - items/s, avg: 0.00 items/s
                                                      Copied: 19 (l:27 KB p:37 KB) Propagated: 5739 (l:29.57 GB p:29.51 GB) Propagated (shallow): 313 (l:Zero KB p:Zero KB)
                                                      Backup Projected Stats: 3503449 items (p:780.56 GB)
                                                      Sized: l:31.69 GB p:29.79 GB c:262865, Outstanding:1/407, Finished Volumes:0
                                                      Current: Zero KB/(l:4 KB,p:8 KB) - /Volumes/Time Machine Office/2023-05-03-105553.inprogress/Home storage (Offline)/Library/Application Support/Bitdefender/avformac/Logs/com
2023-05-03 10:56:53 Info PropagationLookAheads         Found 228.33 GB (404 items) of content to propagate down to depth 3 under "/Volumes/com.apple.TimeMachine.localsnapshots/Backups.backupdb/Matteo’s MacBook Pro/2023-05-03-
2023-05-03 10:57:19 Info CopyProgress                  Calculated first time remaining estimate. Waiting for more samples...
2023-05-03 11:01:22 Info CopyProgress                  .••••••••  .
                                                      Progress: 83% done, 0.2620%/s, 6.25 MB/s, avg: 6.25 MB/s, 56.96 items/s, avg: 56.96 items/s
                                                      Copied: 1465 (l:1.87 GB p:1.88 GB) Propagated: 1539959 (l:472.71 GB p:465.43 GB) Propagated (shallow): 16022 (l:Zero KB p:Zero KB)
                                                      Backup Projected Stats: 3503449 items (p:780.56 GB)
                                                      Sized: l:266.88 GB p:249.06 GB c:1905725, Outstanding:0/740, Finished Volumes:0
                                                      Current: Zero KB/(l:Zero KB,p:Zero KB) - /Volumes/Time Machine Office/2023-05-03-105553.inprogress/Home storage (Offline)/Users/corti/Library/Containers/com.apple.mail/Data/
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
```

## Usage

```text
Usage: tmstatus.sh [OPTIONS]

Options:
   -h,--help,-?                    This help message
   -l,--log [lines]                Show the last log lines
   -p,--progress                   Show a progress bar
   -q,--quick                      Skip the backup listing
   -s,--speed                      Show the speed of the running backup
   -t,--today                      List today's backups
   -V,--version                    Version

Report bugs to https://github.com/matteocorti/tmstatus.sh/issues
```

## Bugs

Report bugs to https://github.com/matteocorti/tmstatus.sh/issues
