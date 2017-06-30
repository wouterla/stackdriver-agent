#!/bin/bash

# Copyright (C) 2016 wikiwi.io
#
# This software may be modified and distributed under the terms
# of the MIT license. See the LICENSE file for details.

if [ -n "${JOURNAL_TAG}" ]; then
echo Configuring journal...
mkdir -p /opt/stackdriver/collectd/etc/collectd.d
cat <<EOL > /etc/google-fluentd/config.d/journal.conf
<source>
  @type systemd
  path /var/log/journal
  <storage>
    @type local
    persistent true
    path journal.pos
  </storage>
  tag ${JOURNAL_TAG}
  read_from_head true
</source>

<match ${JOURNAL_TAG}>
  @type google_cloud
</match>
EOL
fi
