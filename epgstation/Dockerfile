FROM l3tnun/epgstation:master-debian
EXPOSE 8888

RUN apt-get update && apt-get -y install ffmpeg && \
    apt-get autoremove -y && apt-get autoclean -y
