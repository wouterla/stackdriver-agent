from debian:jessie

RUN apt-get update && apt-get install -y curl && \
    curl -o /etc/apt/sources.list.d/stackdriver.list https://repo.stackdriver.com/jessie.list && \
    curl --silent https://app.stackdriver.com/RPM-GPG-KEY-stackdriver | apt-key add - && \
    apt-get update && apt-get install -y libhiredis-dev libpq-dev libsystemd-dev ruby ruby-dev build-essential
RUN curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh && bash install-logging-agent.sh
#RUN apt-get install -y stackdriver-agent

# Install systemd journal driver
RUN gem install fluent-plugin-systemd -v 0.2.0

COPY collectd-gcm.conf.tmpl /opt/stackdriver/collectd/etc/collectd-gcm.conf.tmpl
COPY collectd.conf.tmpl /opt/stackdriver/collectd/etc/collectd.conf.tmpl
COPY run-agent.sh /usr/bin/run-agent.sh
COPY configurator /opt/configurator

CMD ["run-agent.sh"]
