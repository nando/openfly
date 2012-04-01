#!/bin/bash
wget http://morning-planet-6150.herokuapp.com/pilots.csv?admin=$1 -O pilots.csv
wget http://morning-planet-6150.herokuapp.com/pilots.json -O pilots.json
