#!/bin/bash
snort -V
snort --daq-list --daq-dir /usr/local/lib/daq_s3/lib/daq
echo "Smoke test passed."
