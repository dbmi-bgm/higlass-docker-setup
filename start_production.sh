#!/usr/bin/env bash
set -e
set -v


# DOCKER_VERSION is the version of higlass/higlass-docker
# docker pull higlass/higlass-docker:v0.6.51
DOCKER_VERSION=v0.6.51
IMAGE=higlass/higlass-docker:$DOCKER_VERSION
PORT=80
FILE_VERSION=20200814

# stop container
docker stop higlass-container
# remove container
docker rm higlass-container


docker run --name higlass-container \
           --publish $PORT:80 \
           --volume ~/hg-data:/data \
           --volume ~/hg-tmp:/tmp \
           --detach \
           $IMAGE

docker exec higlass-container python higlass-server/manage.py ingest_tileset \
            --filename /data/hg38_full.txt \
            --filetype chromsizes-tsv \
            --datatype chromsizes \
            --coordSystem hg38

docker exec higlass-container python higlass-server/manage.py ingest_tileset \
            --filename /data/transcripts_$FILE_VERSION.beddb \
            --filetype beddb --coordSystem hg38 \
            --datatype gene-annotation \
            --uid transcripts_$FILE_VERSION

docker exec higlass-container python higlass-server/manage.py ingest_tileset \
            --filename /data/canonical_transcripts_$FILE_VERSION.beddb \
            --filetype beddb --coordSystem hg38 \
            --datatype gene-annotation \
            --uid canonical_transcripts_$FILE_VERSION