# uptimemon - Simple Service Monitoring in Bash

I guess something has to go here at some point


## Todo
### Short term
 * Clean up logging - it's currently a mess
 * Only output errors to slack - clean up that output too
 * Tracking for how many alerts have been sent - only send every X minutes (perhaps exponential backoff)
 * Alerts only on "status change" (one on site down, one on site restored)
 * SMS alerts with twillio
 * Add an optional random backoff before pinging server - so as to not hit single servers with multiple monitored sites as hard
 * Add error checking for when slack alerts fail - write to log, alert other methods?
 * Add a dashboard/debug mode, outputing info on all sites
 * Add Exact HTTP code to error string when curl returns 22 code
 * Add custom useragent to tests - for the purposes of cleaning webserver logs
 * Retry before alerting to confirm actual error instead of single reporting failure
   * Only log, don't alert, if failure does not get reported
 * Add option to test less frequently on individual sites

### Long Term:
 * Add dashboard functionality - query the script to find site health
