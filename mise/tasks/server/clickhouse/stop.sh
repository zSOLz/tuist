#!/usr/bin/env bash
# mise description="Start ClickHouse server as daemon"

set -euo pipefail

kill $(cat server/.clickhouse.pid) || echo "ClickHouse is not running"
