#!/usr/bin/env bash
set -e
set -v

# DOCKER_VERSION is the version of higlass/higlass-docker
# docker pull higlass/higlass-docker:v0.8.7
DOCKER_VERSION=v0.8.7
IMAGE=higlass/higlass-docker:$DOCKER_VERSION
PORT=80
FILE_VERSION=20200814

# stop and remove container, if it exists
docker stop higlass-container || true && docker rm higlass-container || true

# remove previously ingested data
rm -f ~/hg-data/db.sqlite3
rm -rf ~/hg-data/media

sleep 5

docker run --name higlass-container \
           --publish $PORT:80 \
           --volume ~/hg-data:/data \
           --volume ~/hg-tmp:/tmp \
           --detach \
           $IMAGE

# We have to wait to make sure the container is properly running
sleep 5

docker exec higlass-container python higlass-server/manage.py ingest_tileset \
            --filename /data/hg38_full.txt \
            --filetype chromsizes-tsv \
            --datatype chromsizes \
            --coordSystem hg38 \
            --uid chromsizes_hg38

docker exec higlass-container python higlass-server/manage.py ingest_tileset \
            --filename /data/transcripts_$FILE_VERSION.beddb \
            --filetype beddb \
            --coordSystem hg38 \
            --datatype gene-annotation \
            --uid transcripts_hg38

docker exec higlass-container python higlass-server/manage.py ingest_tileset \
            --filename /data/orthologs_transcripts_$FILE_VERSION.beddb \
            --filetype beddb \
            --coordSystem hg38 \
            --datatype gene-annotation \
            --uid orthologs_transcripts_hg38

docker exec higlass-container python higlass-server/manage.py ingest_tileset \
            --filename /data/canonical_transcripts_$FILE_VERSION.beddb \
            --filetype beddb \
            --coordSystem hg38 \
            --datatype gene-annotation \
            --uid canonical_transcripts_hg38

docker exec higlass-container python higlass-server/manage.py ingest_tileset \
            --filename /data/gene-annotations-hg38.db \
            --filetype beddb \
            --coordSystem hg38 \
            --datatype gene-annotation \
            --uid gene_annotation_hg38

# ClinVar data version 20200824
docker exec higlass-container python higlass-server/manage.py ingest_tileset \
            --filename /data/clinvar_$FILE_VERSION.beddb \
            --filetype beddb \
            --datatype bedlike \
            --uid clinvar_20200824_hg38

docker exec higlass-container python higlass-server/manage.py ingest_tileset \
            --filename /data/gnomad.r3.0.1.median.coverage.bw \
            --filetype bigwig \
            --datatype vector \
            --coordSystem hg38 \
            --uid gnomad_coverage