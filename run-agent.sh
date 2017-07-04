#!/bin/bash

# Copyright (C) 2016 wikiwi.io
#
# This software may be modified and distributed under the terms
# of the MIT license. See the LICENSE file for details.

PID_FILE=/var/run/stackdriver-agent.pid
FLUENTD_PID_FILE=/var/run/google-fluentd/google-fluentd.pid

set -eo pipefail

for f in /opt/configurator/*.sh; do source $f; done

stopFluentd() {
  service google-fluentd stop
  kill -9 ${FLUENTD_LOG_PID}
}

service google-fluentd start
trap stopFluentd SIGINT SIGTERM
#touch /var/log/google-fluentd/google-fluentd.log
#tail /var/log/google-fluentd/google-fluentd.log -f &
# Send all journalctl data to stdout as long as fluentd isn't working
journalctl -f | grep -v "docker\["

# # echo Waiting for fluentd daemon to start
# while [ ! -f "${FLUENTD_PID_FILE}" ] ; do
#   sleep 1;
# done
#
# # Waiting for fluentd daemon to stop
# while [ -f "${FLUENTD_PID_FILE}" ] ; do
#   sleep 1;
# done
