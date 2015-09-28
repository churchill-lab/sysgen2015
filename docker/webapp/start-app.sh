#!/bin/bash

## Set default for DIRECTORY in case it is undefined
APPDIRECTORY=${APPDIRECTORY:="/data/webapp"}

cd $APPDIRECTORY

## Start both viewers
python $APPDIRECTORY/eqtl-viewer/src/application.py eqtl.cfg &
python $APPDIRECTORY/pqtl-viewer/src/application.py pqtl.cfg 
