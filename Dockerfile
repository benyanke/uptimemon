FROM ubuntu:latest
MAINTAINER ben@benyanke.com
 
# Add crontab file in the cron directory
ADD crontab /etc/cron.d/monitoring-cron
 
# Give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/monitoring-cron
 
# Create the log file to be able to run tail
RUN touch /var/log/cron.log
 
# Run the command on container startup
CMD cron && tail -f /var/log/cron.log
