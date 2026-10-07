#!/bin/sh
set -e
java -jar /cloudwatch_exporter.jar 9106 /etc/cloudwatch-exporter/cloudwatch.yml &
CW_PID=$!
/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/prometheus &
PROM_PID=$!
trap 'kill $CW_PID $PROM_PID 2>/dev/null || true' TERM INT
wait $PROM_PID
