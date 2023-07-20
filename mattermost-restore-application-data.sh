#!/bin/bash

MATTERMOST_BACKUPS_CONTAINER=$(docker ps -aqf "name=mattermost_backups")

echo "--> All available application data backups:"

for entry in $(docker container exec -it $MATTERMOST_BACKUPS_CONTAINER sh -c "ls /srv/mattermost-application-data/backups/")
do
  echo "$entry"
done

echo "--> Copy and paste the backup name from the list above to restore application data and press [ENTER]
--> Example: mattermost-application-data-backup-YYYY-MM-DD_hh-mm.tar.gz"
echo -n "--> "

read SELECTED_APPLICATION_BACKUP

echo "--> $SELECTED_APPLICATION_BACKUP was selected"

echo "--> Scaling service down..."
docker service scale mattermost_mattermost=0

echo "--> Restoring application data..."
docker exec -it $MATTERMOST_BACKUPS_CONTAINER sh -c "rm -rf /mattermost/data/* && tar -zxpf /srv/mattermost-application-data/backups/$SELECTED_APPLICATION_BACKUP -C /"
echo "--> Application data recovery completed..."

echo "--> Scaling service up..."
docker service scale mattermost_mattermost=1
