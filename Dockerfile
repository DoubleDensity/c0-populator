# CEPH BASE IMAGE
# CEPH VERSION: Hammer
# CEPH VERSION DETAIL: 0.94.x

FROM ubuntu:14.04
MAINTAINER Sébastien Han "seb@redhat.com"

ENV ETCDCTL_VERSION v2.2.0
ENV ETCDCTL_ARCH linux-amd64
ENV CEPH_VERSION hammer

ENV KVIATOR_VERSION 0.0.5
ENV CONFD_VERSION 0.10.0

# Install prerequisites
RUN apt-get update &&  apt-get install -y wget unzip

# Install Ceph
RUN wget -q -O- 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc' | apt-key add -
RUN echo deb http://ceph.com/debian-${CEPH_VERSION}/ trusty main | tee /etc/apt/sources.list.d/ceph-${CEPH_VERSION}.list
RUN apt-get update && apt-get install -y --force-yes ceph radosgw && \
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install etcdctl
RUN wget -q -O- "https://github.com/coreos/etcd/releases/download/${ETCDCTL_VERSION}/etcd-${ETCDCTL_VERSION}-${ETCDCTL_ARCH}.tar.gz" |tar xfz - -C/tmp/ etcd-${ETCDCTL_VERSION}-${ETCDCTL_ARCH}/etcdctl
RUN mv /tmp/etcd-${ETCDCTL_VERSION}-${ETCDCTL_ARCH}/etcdctl /usr/local/bin/etcdctl

#install kviator
ADD https://github.com/AcalephStorage/kviator/releases/download/v${KVIATOR_VERSION}/kviator-${KVIATOR_VERSION}-linux-amd64.zip /tmp/kviator.zip
RUN cd /usr/local/bin && unzip /tmp/kviator.zip && chmod +x /usr/local/bin/kviator && rm /tmp/kviator.zip

# Install confd
ADD https://github.com/kelseyhightower/confd/releases/download/v${CONFD_VERSION}/confd-${CONFD_VERSION}-linux-amd64 /usr/local/bin/confd
RUN chmod +x /usr/local/bin/confd && mkdir -p /etc/confd/conf.d && mkdir -p /etc/confd/templates

COPY app /app

#ADD entrypoint.sh /entrypoint.sh
#ENTRYPOINT ["/entrypoint.sh"]
ENTRYPOINT ["/app/populate.sh"]
