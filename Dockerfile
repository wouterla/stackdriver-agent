from ubuntu:15.10

RUN apt-get update && apt-get dist-upgrade -y
RUN apt-get install -y curl lsb-release lsb-core libhiredis-dev libpq-dev libsystemd-dev ruby ruby-dev build-essential  liblz4-dev
RUN curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh && bash install-logging-agent.sh
#RUN curl -O "https://repo.stackdriver.com/stack-install.sh" && bash stack-install.sh \
#  --api-key "fake-api-key-for-empty-docker-container" --genhostid --no-start
#RUN apt-get install -y stackdriver-agent

# Recompile journalctl
RUN apt-get build-dep systemd -y
RUN apt-get source systemd -y
RUN cd systemd-225 && ./autogen.sh && \
  ./configure CFLAGS='-g -O0 -ftrapv' --enable-compat-libs --enable-kdbus \
  --sysconfdir=/etc --localstatedir=/var --libdir=/usr/lib  --with-rootprefix=/ \
  --with-rootlibdir=/lib --enable-pam --enable-audit --disable-selinux \
  --enable-ima --enable-apparmor --enable-smack --disable-sysvinit \
  --disable-utmp --disable-libcryptsetup --disable-gcrypt --disable-gnutils \
  --disable-acl --disable-xz --enable-lz4 --enable-seccomp --enable-blkid \
  --disable-elfutils --enable-kmods --disable-idn && \
  make install

# Install systemd journal driver
ENV GEM_HOME=/opt/google-fluentd/embedded/lib/ruby/gems/2.1.0/
ENV GEM_PATH=/opt/google-fluentd/embedded/lib/ruby/gems/2.1.0/
ENV PATH=/opt/google-fluentd/embedded/bin:$PATH
RUN /opt/google-fluentd/embedded/bin/fluent-gem install fluent-plugin-systemd -v 0.2.0

COPY collectd-gcm.conf.tmpl /opt/stackdriver/collectd/etc/collectd-gcm.conf.tmpl
COPY collectd.conf.tmpl /opt/stackdriver/collectd/etc/collectd.conf.tmpl
COPY run-agent.sh /usr/bin/run-agent.sh
COPY configurator /opt/configurator

CMD ["run-agent.sh"]
