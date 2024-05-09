FROM alpine:latest AS downloader
ARG TWITCHDOWNLOADER_VERSION="1.54.2"
RUN apk add unzip wget curl
RUN wget "https://github.com/lay295/TwitchDownloader/releases/download/${TWITCHDOWNLOADER_VERSION}/TwitchDownloaderCLI-${TWITCHDOWNLOADER_VERSION}-Linux-x64.zip" -O td.zip
RUN unzip -j td.zip "TwitchDownloaderCLI" -d /opt

FROM linuxserver/ffmpeg:amd64-7.0-cli-ls135
COPY --from=downloader /opt/TwitchDownloaderCLI /usr/local/bin/TwitchDownloaderCLI
RUN chmod +x /usr/local/bin/TwitchDownloaderCLI

ENTRYPOINT ["/usr/local/bin/TwitchDownloaderCLI"]