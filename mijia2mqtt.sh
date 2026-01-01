#!/bin/bash

hciconfig hci0 up || exit 1

declare -A sensor_array
sensor_name=false
for data in ${SENSORS}; do
    if [ $sensor_name == false ]; then
        sensor_name="${data}"
    else
        sensor_array[$sensor_name]="${data}"
        sensor_name=false
    fi
done

all_ok=true
for sensor_name in "${!sensor_array[@]}"; do
    sensor_mac="${sensor_array[$sensor_name]}"
    data="$(timeout 10 /app/mitemp/get_data.py "${sensor_mac}")"
    ret=$?

    if [[ $ret -ne 0 || -z "$data" ]]; then
        all_ok=false
        continue
    fi

    mosquitto_pub -u ${MQTT_USER} -P ${MQTT_PASSWORD} -p ${MQTT_PORT} -h ${MQTT_HOST} -q 1 -t "mijia/${sensor_name}" -m "$data"
done

hciconfig hci0 down

if [[ "$all_ok" == true && ! -z "$PUSH_URL" ]]; then
    curl -s -o /dev/null "$PUSH_URL"
fi
