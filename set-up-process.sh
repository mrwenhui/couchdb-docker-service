#!/bin/bash

# The primary node is couchdb1 and is the single node with which all secondary nodes register their
# membership. The primary node and secondary node designation only really matters during the setup
# process and is only used to implement a scalable service architecture.

# Wait until primary node is ready
/wait-for-it.sh couchdb1:5984 -t 300

if [ $TASK_SLOT -eq 1 ]; then
  echo "Setting up primary node..."

  # TODO: check couchdb1:5984/_users to make sure DB doesn't already exist before executing the
  # following

  # Create system databases
  curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_users
  curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_replicator
  curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5984/_global_changes
else
  echo "Setting up secondary node..."

  # Wait until secondary node is ready
  /wait-for-it.sh couchdb$TASK_SLOT:5984 -t 300

  # Register membership
  curl -X PUT http://$COUCHDB_USER:$COUCHDB_PASSWORD@couchdb1:5986/_nodes/couchdb@couchdb$TASK_SLOT -d {}
fi
