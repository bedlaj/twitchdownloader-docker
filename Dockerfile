FROM linuxserver/ffmpeg:amd64-7.0-cli-ls135

ARG TWITCHDOWNLOADER_VERSION="1.54.2"

RUN wget "https://github.com/lay295/TwitchDownloader/releases/download/${TWITCHDOWNLOADER_VERSION}/TwitchDownloaderCLI-${TWITCHDOWNLOADER_VERSION}-Linux-x64.zip" -O td.zip \
    && unzip -j td.zip "TwitchDownloaderCLI" -d /usr/local/bin/ \
    && rm td.zip \
    && chmod +x /usr/local/bin/TwitchDownloaderCLI \
    && ldd /usr/local/bin/TwitchDownloaderCLI

ENTRYPOINT ["/usr/local/bin/TwitchDownloaderCLI"]