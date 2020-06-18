FROM l3tnun/epgstation:master-debian
EXPOSE 8888

RUN apt-get update && \
    apt-get -y install ffmpeg && \
    sudo apt-get autoremove -y && sudo apt-get autoclean -y
