---
layout: default
title: Recursos
---

## Recursos


### Openflydb

* Site: [http://morning-planet-6150.herokuapp.com](http://morning-planet-6150.herokuapp.com)
* [Solicitud de Inscripción](http://morning-planet-6150.herokuapp.com/pilots/new.pdf): [http://morning-planet-6150.herokuapp.com/pilots/new.pdf](http://morning-planet-6150.herokuapp.com/pilots/new.pdf)
* [Registro de Despegues](http://morning-planet-6150.herokuapp.com/pilots.pdf): [http://morning-planet-6150.herokuapp.com/pilots.pdf](http://morning-planet-6150.herokuapp.com/pilots.pdf)
* Repo en Heroku: git@heroku.com:morning-planet-6150.git
* Repo en Github: git@github.com:nando/openflydb.git

### Open de PB

* Site: [http://clubdevuelopb.com/open](http://clubdevuelopb.com/open)
* Repo: git@github.com:nando/open_de_pb.git

## Mantenimientos

* Balizas
  Edición de KML a mano y de ahí a WPT y GPX con GPSDump, CSV con GPSBabel y PDF leyendo el CSV desde Excel o Libre Office.
<pre>
    $EDITOR Balizas.KML
    wine ~/bin/GpsDump.exe # generar WPT y GPX con GPSDump
    gpsbabel -i kml -f downloads/Balizas.KML -o unicsv -F downloads/Balizas.csv
    oocalc downloads/Balizas.csv # y con él CSV generamos el PDF
</pre>
