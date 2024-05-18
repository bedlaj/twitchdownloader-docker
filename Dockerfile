FROM alpine:latest AS downloader
ARG TWITCHDOWNLOADER_VERSION="1.54.3"
RUN apk add unzip wget curl
RUN wget -q "https://github.com/lay295/TwitchDownloader/releases/download/${TWITCHDOWNLOADER_VERSION}/TwitchDownloaderCLI-${TWITCHDOWNLOADER_VERSION}-Linux-x64.zip" -O td.zip
RUN unzip -qq -j td.zip "TwitchDownloaderCLI" -d /opt/TwitchDownloader
RUN wget -q https://github.com/google/fonts/archive/refs/heads/main.zip -O fonts.zip
RUN unzip -qq -j -o fonts.zip -d /opt/fonts


FROM linuxserver/ffmpeg:amd64-version-7.0-cli
COPY --from=downloader /opt/TwitchDownloader/TwitchDownloaderCLI /usr/local/bin/TwitchDownloaderCLI
COPY --from=downloader /opt/fonts /usr/local/share/fonts
RUN chmod +x /usr/local/bin/TwitchDownloaderCLI

RUN \
  echo "**** install runtime ****" && \
    echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections && \
    apt-get update && \
    ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive apt-get install -y fontconfig ttf-mscorefonts-installer && \
  echo "**** clean up ****" && \
    rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/* && \
  echo "**** configure ****" && \
    fc-cache -f && fc-list

ENTRYPOINT ["/usr/local/bin/TwitchDownloaderCLI"]
