FROM python:3

ENV MQTT_USER="changeme" \
    MQTT_PASSWORD="changeme" \
    MQTT_PORT="1883" \
    MQTT_HOST="localhost"
# space separated list of "<sensor1_name> <sensor1_mac> <sensor2_name> <sensor2_mac> ..."
ENV SENSORS="test 01:23:45:67:89:01"
# URL to call after every cron job run
ENV PUSH_URL=""

RUN apt-get update \
    && apt-get install -y --no-install-recommends bluez mosquitto-clients busybox-static \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install bluepy

RUN mkdir /app
WORKDIR /app

RUN git clone https://github.com/ratcashdev/mitemp.git \
    && git clone https://github.com/ChristianKuehnel/btlewrap.git \
    && mv btlewrap/btlewrap/ mitemp/ \
    && rm -rf btlewrap/

ADD get_data.py /app/mitemp
ADD mijia2mqtt.sh /app
RUN chmod a+x mijia2mqtt.sh mitemp/get_data.py

RUN mkdir -p /var/spool/cron/crontabs \
    && echo '*/2 * * * * timeout 55 /app/mijia2mqtt.sh' > /var/spool/cron/crontabs/root

ENTRYPOINT busybox crond -f -l 0 -L /dev/stdout
