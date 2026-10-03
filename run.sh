#!/bin/sh
set -e
python3 -m flask --app server.main:app run --host 0.0.0.0 --port "${PORT:-8787}"
