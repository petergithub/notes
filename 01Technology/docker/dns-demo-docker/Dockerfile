FROM centos:7

ENV container docker

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Install anything. The service you want to start must be a SystemD service.

RUN yum install -y bind bind-utils iproute initscripts
RUN touch /etc/sysconfig/network
COPY named.conf /etc/named.conf
COPY named.rfc1912.zones /etc/named.rfc1912.zones
COPY yumaozdy.com.zone /var/named/yumaozdy.com.zone
COPY example.com.zone /var/named/example.com.zone

RUN chown root:named /etc/named* /var/named/yumaozdy.com.zone /var/named/example.com.zone

#RUN echo 'root:root' | chpasswd

VOLUME [ "/sys/fs/cgroup" ]
CMD ["/usr/sbin/init"]

#WORKDIR /app
#EXPOSE 3000

