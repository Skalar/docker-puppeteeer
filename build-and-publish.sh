#!/bin/bash

docker build . --target plain -t skalar/puppeteer:plain
docker build . --target vnc -t skalar/puppeteer:vnc
docker push skalar/puppeteer:plain
docker push skalar/puppeteer:vnc