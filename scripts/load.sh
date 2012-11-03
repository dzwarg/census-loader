#!/bin/bash

pushd ../data &> /dev/null

SHP2PG=/Library/PostgreSQL/9.1/bin/shp2pgsql
PSQL=/Library/PostgreSQL/9.1/bin/psql
DATABASE=census

loadset()
{
    TABLE=$1
    SETUP=no

    for z in $2; do
        DIR="${z/\.zip/}"

        echo "Processing $DIR"

        unzip -d $DIR -qq $z
        pushd $DIR &> /dev/null

        if [ $SETUP == "no" ]; then
            $SHP2PG -I -p $DIR.shp postgres.$TABLE 2>/dev/null > $TABLE.sql
            SETUP=yes
        fi

        $SHP2PG -D -a -W LATIN1 $DIR.shp postgres.$TABLE 2>/dev/null >> $TABLE.sql

        echo "Loading $TABLE set."
        $PSQL -f $TABLE.sql -U postgres $DATABASE

        popd &> /dev/null

        rm -rf $DIR
    done
}

#loadset "blockgroup" "`ls *bg.zip`"
loadset "tract" "`ls *500k.zip`"
#loadset "county" "`ls *county.zip`"

popd &> /dev/null
