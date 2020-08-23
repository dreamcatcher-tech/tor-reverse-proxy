FROM debian:buster-slim
LABEL tor latest

RUN apt-get update
RUN apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    ntpdate \
    apache2 \
    sudo \
    tor
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    node-ws \
    nano \
    lsof
RUN apt-get clean
# RUN rm -rf /var/lib/apt/lists/*

RUN useradd --system --uid 666 -M --shell /usr/sbin/nologin tor
RUN echo "tor     ALL=NOPASSWD:/etc/init.d/apache2" >> /etc/sudoers

COPY tor-forward.conf /etc/apache2/sites-available/
RUN a2ensite tor-forward.conf
RUN a2enmod proxy proxy_http proxy_wstunnel ssl 

COPY main.sh /
RUN mkdir /web && \
    chown -R tor /web /etc/tor /main.sh && \
    chmod 700 /main.sh /web

USER tor

ENTRYPOINT ["/main.sh"]
CMD ["default"]

HEALTHCHECK --interval=5m --timeout=15s --start-period=20s \
    CMD curl -s --socks5 127.0.0.1:9052 'https://check.torproject.org/' | grep -qm1 Congratulations