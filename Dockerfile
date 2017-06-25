FROM centos:7

ENV RIAK_VERSION=2.2.3-1

RUN curl -s https://packagecloud.io/install/repositories/basho/riak/script.rpm.sh | bash
RUN yum -y install riak-$RIAK_VERSION.el7.centos.x86_64

EXPOSE 8087 8098

COPY prestart.d /etc/riak/prestart.d
COPY poststart.d /etc/riak/poststart.d
COPY prestop.d /etc/riak/prestop.d

COPY riak-up.sh /usr/local/bin/

USER riak

CMD ["/bin/bash", "riak-up.sh"]
