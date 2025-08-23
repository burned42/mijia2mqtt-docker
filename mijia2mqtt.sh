#!/bin/bash

hciconfig hci0 up

get_data_for_mac="/app/mitemp/get_data.py"
mqtt_pub="mosquitto_pub -u ${MQTT_USER} -P ${MQTT_PASSWORD} -p ${MQTT_PORT} -h ${MQTT_HOST} -l -t"

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

for sensor_name in "${!sensor_array[@]}"; do
    sensor_mac="${sensor_array[$sensor_name]}"
    data="$(${get_data_for_mac} "${sensor_mac}")"

    echo "$data" | $mqtt_pub "mijia/${sensor_name}"
done

hciconfig hci0 down

if [[ ! -z "$PUSH_URL" ]]; then
    curl -s -o /dev/null "$PUSH_URL"
fi
