#!/bin/bash
# Should run from project root dir

touch ./service/po/unsort-POTFILES.in

find ./service/ -iname "*.vala" -type f -exec grep -lrE '_\(|C_|ngettext' {} + | while read file; do echo "${file#./}" >> ./service/po/unsort-POTFILES.in; done
find ./service/data/ -iname "*.desktop.in.in" | while read file; do echo "${file#./}" >> ./service/po/unsort-POTFILES.in; done
find ./service/data/ -iname "*.service.in" | while read file; do echo "${file#./}" >> ./service/po/unsort-POTFILES.in; done

cat ./service/po/unsort-POTFILES.in | sort | uniq > ./service/po/POTFILES.in

rm ./service/po/unsort-POTFILES.in

# To add translation, please use Damned Lies service https://l10n.gnome.org/
