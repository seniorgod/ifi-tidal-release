FROM debian:stretch-slim
RUN echo "deb http://security.debian.org/debian-security jessie/updates main" > /etc/apt/sources.list.d/jessie-updates.list
RUN apt-get -y update 
RUN apt-get -y  install libssl1.0.0 libportaudio2 libflac++6v5 libcurl3 libavformat57 libavahi-common3 libavahi-client3  avahi-daemon
RUN mkdir /usr/ifi/
RUN mkdir /usr/ifi/ifi_tidal_release
RUN apt-get
