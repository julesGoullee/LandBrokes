#!/usr/bin/env bash

cd ../chain/landSC/ && npm run migrate:dev && \
cd ../bankContracts && npm run migrate:dev
