
FROM node:10.15.0-slim@sha256:bb4a5a0bdc9886b180d52b556b1e3f3f624bc8c13d50bd3edca1dbeb7aa7ac0b as base

RUN apt-get update \
  && apt-get install -yq libgconf-2-4 \
  # See https://crbug.com/795759
  && apt-get install -yq \
  wget \
  ash \
  procps \
  && apt-get install -y wget --no-install-recommends \
  # Install latest chrome dev package, which installs the necessary libs to
  # make the bundled version of Chromium that Puppeteer installs work.
  && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
  && apt-get update \
  && apt-get install -y google-chrome-unstable --no-install-recommends \
  && rm /etc/apt/sources.list.d/google.list

# Tell Puppeteer to skip installing Chrome. We'll be using the installed package.
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD true

# Add user so we don't need --no-sandbox.
RUN groupadd -r testuser \
  && useradd -r -g testuser -G audio,video testuser \
  && mkdir -p /home/testuser/Downloads \
  && chown -R testuser:testuser /home/testuser


ADD https://github.com/krallin/tini/releases/download/v0.18.0/tini /tini
RUN chmod +x /tini
ENTRYPOINT ["/tini", "--"]


#
# vnc
#

FROM base AS vnc

RUN apt-get update && apt-get -yq install \
  vnc4server \
  jwm

RUN mkdir /.local && chown testuser:testuser /.local
USER testuser
RUN mkdir -p /home/testuser/.vnc 

COPY --chown=testuser:testuser files/start-vnc.sh files/.jwmrc /home/testuser/
COPY --chown=testuser:testuser files/xstartup /home/testuser/.vnc/

ENV \
  VNC_GEOMETRY=1680x1050 \
  VNC_PASSWORD=testing \
  VNC_COLOR_DEPTH=32

CMD ["/home/testuser/start-vnc.sh"]

#
# plain
#

FROM base AS plain

USER testuser
