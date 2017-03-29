# uptimemon - Simple Service Monitoring in Bash

I guess something has to go here at some point


## Files you need to create
 * domains.list - list of domains to check (newline separated)
 * Slack
   * slack.token - slack token
 * Twilio tokens
   * twilio_auth.token  API auth token
   * twilio_sid.token - Account SID
   * twilio_from.token - Number to send message to
   * twilio_to.token - Number to alert


## Todo
### Short term
 * Rewrite in python, darnit
   * Probably use sqlite for data storage
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
 * Allow two way conversation, to mark an issue as "received"
   * Alert flow would be: notify -> marked as confirmed received -> fixed
 * Alert escalation
   * Start with level 1 (email or slack, for example)
   * If no response in x minutes, go to level 2 (sms, for example)
   * If no response in x minutes, go to level 3 (call and another email, for example)
   * Also, allow escalation blocking on a per-site basis - some sites aren't important enough to get a phone call about

### Long Term:
 * Add dashboard functionality - query the script to find site health
 * Historical data storage - like smokeping, for example


## Requirements - from Apt Repositories 
 * BC
