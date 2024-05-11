FROM alpine:latest AS downloader
ARG TWITCHDOWNLOADER_VERSION="1.54.2"
RUN apk add unzip wget curl
RUN wget -q "https://github.com/lay295/TwitchDownloader/releases/download/${TWITCHDOWNLOADER_VERSION}/TwitchDownloaderCLI-${TWITCHDOWNLOADER_VERSION}-Linux-x64.zip" -O td.zip
RUN unzip -j td.zip "TwitchDownloaderCLI" -d /opt
RUN wget https://github.com/google/fonts/archive/master.zip -O fonts.zip
RUN mkdir -p /opt/fonts && unzip -j fonts.zip -d /opt/fonts


FROM linuxserver/ffmpeg:amd64-7.0-cli-ls135
COPY --from=downloader /opt/TwitchDownloaderCLI /usr/local/bin/TwitchDownloaderCLI
COPY --from=downloader /opt/fonts /usr/local/share/fonts
RUN chmod +x /usr/local/bin/TwitchDownloaderCLI

RUN \
  echo "**** install runtime ****" && \
    apt-get update && \
    apt-get install -y ttf-mscorefonts-installer && \
  echo "**** clean up ****" && \
    rm -rf \
      /var/lib/apt/lists/* \
      /var/tmp/* && \
  echo "**** configure ****" && \
    fc-cache -f && fc-list

ENTRYPOINT ["/usr/local/bin/TwitchDownloaderCLI"]