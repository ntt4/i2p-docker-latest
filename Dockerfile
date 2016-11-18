FROM ubuntu:latest
MAINTAINER ntt4

ENV I2P_DIR /var/lib/i2p
ENV DEBIAN_FRONTEND noninteractive
ENV USER i2prouter
ENV GROUP i2prouter

RUN sed -i 's/.*\(en_US\.UTF-8\)/\1/' /etc/locale.gen && \
    /usr/sbin/locale-gen && \
    /usr/sbin/update-locale LANG=en_US.UTF-8 LANGUAGE="en_US:en"

RUN apt-add-repository ppa:i2p-maintainers/i2p && apt-get update

RUN apt-get -y install i2p

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#
# Expose some ports used by I2P
# Description at https://geti2p.net/ports
#
# Main ports:
# 4444 — HTTP proxy
# 6668 — Proxy to Irc2P
# 7657 — router console
# 7658 — self-hosted eepsite
# 7659 — SMTP proxy to smtp.postman.i2p
# 7660 — POP3 proxy to pop.postman.i2p
# 8998 — Proxy to mtn.i2p-projekt.i2p
#

EXPOSE 4444 7657 6668 7658 7659 7660

VOLUME /var/lib/i2p

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

RUN sed -i 's/false/true/' /etc/default/i2p
RUN service i2p start


RUN sed -i 's/127.0.0.1/0.0.0.0/g' ${I2P_DIR}/i2p-config/i2ptunnel.config
RUN sed -i 's/::1,127.0.0.1/0.0.0.0/g' ${I2P_DIR}/i2p-config/clients.config
RUN echo "i2cp.tcp.bindAllInterfaces=true" >> ${I2P_DIR}/i2p-config/router.config


CMD sudo /etc/init.d/i2p start && sudo tail -f /var/log/i2p/wrapper.log
