FROM fedora:31
ENV CONFTEST_VERSION=0.18.0

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*; \
rm -f /etc/systemd/system/*.wants/*; \
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*; \
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN dnf clean all && \
    dnf -y upgrade && \
    dnf -y --allowerasing install coreutils && \
    dnf -y --setopt=install_weak_deps=false install \
    acl \
    bzip2 \
    file \
    findutils \
    gcc \
    git \
    glibc-locale-source \
    iproute \
    libffi \
    libffi-devel \
    make \
    openssh-clients \
    openssh-server \
    openssl-devel \
    pass \
    procps \
    python3-cryptography \
    python3-dbus \
    python3-devel \
    python3-dnf \
    python3-httplib2 \
    python3-jinja2 \
    python3-lxml \
    python3-mock \
    python3-nose \
    python3-passlib \
    python3-pip \
    python3-PyYAML \
    python3-setuptools \
    python3-virtualenv \
    rpm-build \
    rubygems \
    rubygem-rdoc \
    sshpass \
    subversion \
    sudo \
    tar \
    unzip \
    which \
    zip \
    wget \
    && \
    dnf clean all

RUN wget https://github.com/instrumenta/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz && \
    tar xzf conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz && \
    mv conftest /usr/local/bin

RUN ln -fs /usr/bin/python3 /usr/bin/python

RUN localedef --quiet -c -i en_US -f UTF-8 en_US.UTF-8
RUN /usr/bin/sed -i -e 's/^\(Defaults\s*requiretty\)/#--- \1/'  /etc/sudoers
RUN mkdir /etc/ansible/
RUN /usr/bin/echo -e '[local]\nlocalhost ansible_connection=local' > /etc/ansible/hosts
VOLUME /sys/fs/cgroup /run /tmp
RUN ssh-keygen -q -t dsa -N '' -f /etc/ssh/ssh_host_dsa_key && \
    ssh-keygen -q -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key && \
    ssh-keygen -m PEM -q -t rsa -N '' -f /root/.ssh/id_rsa && \
    cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys && \
    for key in /etc/ssh/ssh_host_*_key.pub; do echo "localhost $(cat ${key})" >> /root/.ssh/known_hosts; done
RUN pip3 install 'coverage<5' junit-xml
ENV container=docker
CMD ["/usr/sbin/init"]