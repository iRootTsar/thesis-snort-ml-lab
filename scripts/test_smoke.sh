#!/bin/bash
snort -V --daq-dir /usr/local/lib/daq_s3/lib/daq
snort --daq-list --daq-dir /usr/local/lib/daq_s3/lib/daq
echo "Smoke test passed."
