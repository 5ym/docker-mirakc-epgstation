#!/bin/sh

git clone https://github.com/5ym/docker-mirakc-epgstation.git
cd docker-mirakc-epgstation
cp compose.sample.yml compose.yml
cp epgstation/config/enc.js.template epgstation/config/enc.js
cp epgstation/config/config.yml.template epgstation/config/config.yml
cp epgstation/config/operatorLogConfig.sample.yml epgstation/config/operatorLogConfig.yml
cp epgstation/config/epgUpdaterLogConfig.sample.yml epgstation/config/epgUpdaterLogConfig.yml
cp epgstation/config/serviceLogConfig.sample.yml epgstation/config/serviceLogConfig.yml
cp mirakc/config.sample.yml config.yml