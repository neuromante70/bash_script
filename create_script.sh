#!/bin/bash

touch $1
echo "#!/bin/bash" > $1
chmod +x $1

# install -m 777 /dev/null filename_as_arg

# chmod 777 filename.txt>>!#:2
