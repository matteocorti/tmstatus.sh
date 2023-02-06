
# tmstatus.sh

&copy; Matteo Corti, 2018-2023

![](https://img.shields.io/github/v/release/matteocorti/tmstatus.sh)&nbsp;![](https://img.shields.io/github/downloads/matteocorti/tmstatus.sh/latest/total)&nbsp;![](https://img.shields.io/github/downloads/matteocorti/tmstatus.sh/total)&nbsp;![](https://img.shields.io/github/license/matteocorti/tmstatus.sh)&nbsp;![](https://img.shields.io/github/stars/matteocorti/tmstatus.sh)&nbsp;![](https://img.shields.io/github/forks/matteocorti/tmstatus.sh)

A simple script to summarize the Time Machine backup status.

Sample output

```text
Backups host.example.com

Oldest:         2017-10-12 11:13:27
Last:           2018-01-23 16:05:01
Number:         30 (104 days)

Local oldest:   2018-01-23 13:08:48
Local last:     2018-01-24 12:01:57
Local number:   7

Status:         Copying

Time remaining: 54h:7m:13s (finish by 2018-01-26 22:18)
Percent:        4.1%
Size:           4 GB of 109 GB

Last log entries:

------------------------------------------------------------------------------------------------------------------------------
2023-02-03 18:30:25 Info MountLock  Mount lock busy { destinationID: 61E72729-DC68-4013-A81F-ED0AA1F01A10 }
2023-02-03 18:31:21 Info MountLock  Mount lock busy { destinationID: 61E72729-DC68-4013-A81F-ED0AA1F01A10 }
------------------------------------------------------------------------------------------------------------------------------
```

## Usage

```text

Usage: tmstatus.sh [OPTIONS]

Options:
   -h,--help,-?                    This help message
   -l,--log [lines]                Show the last log lines


```

## Bugs

Report bugs to https://github.com/matteocorti/tmstatus.sh/issues
