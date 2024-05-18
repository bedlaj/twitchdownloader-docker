FROM alpine:latest AS twitchdownloader-downloader
ARG TWITCHDOWNLOADER_VERSION
ARG TARGETPLATFORM

ENV TWITCHDOWNLOADER_PLATFORM="Linux-x64"

RUN apk add unzip wget
RUN if [ "${TARGETPLATFORM}" = "linux/amd64" ]; then \
        TWITCHDOWNLOADER_PLATFORM="Linux-x64"; \
    elif [ "${TARGETPLATFORM}" = "linux/arm64" ]; then \
        TWITCHDOWNLOADER_PLATFORM="LinuxArm64"; \
    else \
        echo "No valid platform specified"; \
    fi && \
    echo "Downloading TwitchDownloader platform $TWITCHDOWNLOADER_PLATFORM" && wget -q "https://github.com/lay295/TwitchDownloader/releases/download/${TWITCHDOWNLOADER_VERSION}/TwitchDownloaderCLI-${TWITCHDOWNLOADER_VERSION}-$TWITCHDOWNLOADER_PLATFORM.zip" -O td.zip

RUN unzip -qq -j td.zip "TwitchDownloaderCLI" -d /opt/TwitchDownloader
RUN wget -q https://github.com/google/fonts/archive/refs/heads/main.zip -O fonts.zip
RUN unzip -qq -j -o fonts.zip -d /opt/fonts


FROM alpine:latest AS fonts-downloader
RUN apk add unzip wget
RUN wget -q https://github.com/google/fonts/archive/refs/heads/main.zip -O fonts.zip
RUN unzip -qq -j -o fonts.zip -d /opt/fonts


FROM linuxserver/ffmpeg:7.0-cli-ls137
COPY --from=twitchdownloader-downloader /opt/TwitchDownloader/TwitchDownloaderCLI /usr/local/bin/TwitchDownloaderCLI
COPY --from=fonts-downloader /opt/fonts /usr/local/share/fonts
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

RUN /usr/local/bin/ffmpeg -version && /usr/local/bin/TwitchDownloaderCLI --version

ENTRYPOINT ["/usr/local/bin/TwitchDownloaderCLI"]
