set -eu

THEME=$(gsettings get org.gnome.desktop.interface color-scheme)

THEME=$(echo $THEME | tr -d "'")
SUBSTR=${THEME%-dark}

if [ "$SUBSTR" = "$THEME" ]
then
        echo light
else
        echo dark
fi
