ARG RELEASE="2024.1"
ARG TAG="latest"

FROM keppel.eu-de-1.cloud.sap/ccloud/swift:${RELEASE}-${TAG}

ARG RELEASE="2024.1"
ENV RELEASE=${RELEASE}

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        attr \
        memcached \
        rsyslog \
        git \
        xfsprogs \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN	sed -i '/imklog/s/^/#/' /etc/rsyslog.conf && \
    sed -i 's/RSYNC_ENABLE=false/RSYNC_ENABLE=true/' /etc/default/rsync && \
    sed -i 's/\$PrivDropToGroup syslog/\$PrivDropToGroup adm/' /etc/rsyslog.conf && \
    # reanable login shell
    usermod -s /bin/bash swift && \
    # add swift to sudo group
    usermod -a -G sudo swift && \
    # remove password
    passwd -d swift && \
    # no password prompt with sudo
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

    #mkdir -p /var/log/swift/hourly; chown -R syslog.adm /var/log/swift; chmod -R g+w /var/log/swift && \    

# clone swift src to get tests again and install test requirements
RUN git clone --branch stable/${RELEASE}-m3 --single-branch --depth 1 https://github.com/sapcc/swift.git /usr/local/src/swift && \
    pip3 install -r /usr/local/src/swift/test-requirements.txt && \
    # tests stated as swift needs access here for .pytest_cache and .stestr.conf
    chown -R swift:swift /usr/local/src/swift

COPY ./etc/rsyncd.conf /etc/
COPY ./etc/rsyslog.d/10-swift.conf /etc/rsyslog.d/10-swift.conf
COPY ./swift /etc/swift
COPY ./bin /swift/bin

RUN chown -R swift:swift /etc/swift

USER swift

RUN SWIFT_BIN_PATH="$(dirname "$(which swift-proxy-server)")" && \
    echo "export PATH=${SWIFT_BIN_PATH}:/swift/bin:${PATH}" >> $HOME/.bashrc && \
    echo "export TMPDIR=/mnt/tmp" >> $HOME/.bashrc

EXPOSE 8080

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
# Source the ENV variables here explicitly
CMD ["/bin/bash", "-c", ". $HOME/.bashrc && /swift/bin/prepare_tests.sh && exec /swift/bin/tests.sh"]
