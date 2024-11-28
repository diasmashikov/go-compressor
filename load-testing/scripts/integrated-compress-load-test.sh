#!/bin/bash

docker compose down
docker compose up -d influxdb grafana
sleep 5

curl -X POST -H "Content-Type: application/json" -d '{
    "name": "k6",
    "type": "influxdb",
    "url": "http://influxdb:8086",
    "database": "k6",
    "access": "proxy"
}' http://localhost:3000/api/datasources

curl -X POST -H "Content-Type: application/json" -d '{
    "dashboard": {
        "title": "Image Compression Performance",
        "panels": [
            {
                "title": "Response Time Distribution",
                "type": "timeseries",
                "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
                "datasource": "k6",
                "targets": [
                    {
                        "measurement": "http_req_duration",
                        "select": [[{"type": "field", "params": ["value"]}]],
                        "alias": "Response Time"
                    }
                ]
            },
            {
                "title": "Active Virtual Users",
                "type": "timeseries",
                "gridPos": {"h": 8, "w": 12, "x": 12, "y": 0},
                "datasource": "k6",
                "targets": [
                    {
                        "measurement": "vus",
                        "select": [[{"type": "field", "params": ["value"]}]],
                        "alias": "Active Users"
                    }
                ]
            },
            {
                "title": "Success Rate",
                "type": "gauge",
                "gridPos": {"h": 8, "w": 8, "x": 0, "y": 8},
                "datasource": "k6",
                "targets": [
                    {
                        "measurement": "checks",
                        "select": [[{"type": "field", "params": ["value"]}]],
                        "alias": "Success Rate"
                    }
                ],
                "options": {
                    "maxValue": 100,
                    "minValue": 0
                }
            },
            {
                "title": "Data Transferred",
                "type": "timeseries",
                "gridPos": {"h": 8, "w": 8, "x": 8, "y": 8},
                "datasource": "k6",
                "targets": [
                    {
                        "measurement": "data_sent",
                        "select": [[{"type": "field", "params": ["value"]}]],
                        "alias": "Data Sent"
                    },
                    {
                        "measurement": "data_received",
                        "select": [[{"type": "field", "params": ["value"]}]],
                        "alias": "Data Received"
                    }
                ]
            },
            {
                "title": "Error Rate",
                "type": "timeseries",
                "gridPos": {"h": 8, "w": 8, "x": 16, "y": 8},
                "datasource": "k6",
                "targets": [
                    {
                        "measurement": "http_req_failed",
                        "select": [[{"type": "field", "params": ["value"]}]],
                        "alias": "Errors"
                    }
                ]
            }
        ],
        "refresh": "5s",
        "time": {
            "from": "now-5m",
            "to": "now"
        }
    },
    "overwrite": true
}' http://localhost:3000/api/dashboards/db

docker compose run k6

echo "Dashboard ready at http://localhost:3000"