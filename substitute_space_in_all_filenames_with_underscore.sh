#!/bin/bash

# find . -name "* *" -exec rename --verbose 's/\ /_/g' {} \;

# rename ' ' '_' *

for file in *; do mv "$file" ${file// /_}; done

# ls | while read -r FILE
# do
#     mv -v "$FILE" `echo $FILE | tr ' ' '_' | tr -d '[{}(),\!]' | tr -d "\'" | tr '[A-Z]' '[a-z]' | sed 's/_-_/_/g'`
# done
