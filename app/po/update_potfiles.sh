#!/bin/bash
# Should run from project root dir

touch ./app/po/unsort-POTFILES.in

find ./app/data/ui -iname "*.blp" -type f -exec grep -lrE '_\(|C_|ngettext' {} + | while read file; do echo "${file#./}" >> ./app/po/unsort-POTFILES.in; done
find ./app/ -iname "*.vala" -type f -exec grep -lrE '_\(|C_|ngettext' {} + | while read file; do echo "${file#./}" >> ./app/po/unsort-POTFILES.in; done
find ./app/data/ -iname "*.desktop.in" | while read file; do echo "${file#./}" >> ./app/po/unsort-POTFILES.in; done
find ./app/data/ -iname "*.metainfo.xml.in" | while read file; do echo "${file#./}" >> ./app/po/unsort-POTFILES.in; done

cat ./app/po/unsort-POTFILES.in | sort | uniq > ./app/po/POTFILES.in

rm ./app/po/unsort-POTFILES.in

# To add translation, please use Damned Lies service https://l10n.gnome.org/
