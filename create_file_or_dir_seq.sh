#!/bin/bash
#touch  file{1..15}

echo "Do you want to create a sequence of files or directories?"
select df in "dir" "file"; do
    case $df in
        dir ) CHOICE="d"; echo -e "Ok, you choose dir.\n"; break;;
        file ) CHOICE="f"; echo -e "Ok, you choose file.\n"; break;;
    esac
done

while [ -z "$NR" ]; do
    echo -n "How many files/dirs? Insert a number: "
    read NR
done

echo -n "Basename of the file/directory? Insert a name: "
read NAME

echo $(`$NAME`)
if [ -z "$NAME" ]; then
    if [ "$CHOICE"=="d" ]; then
        NAME='dir-'
    fi
fi

echo "Now Name is $NAME, and choice is $CHOICE."

if [ -z "$NAME" ]; then
    if [ "$CHOICE"=="f" ]; then
        NAME='file-'
    fi
fi

echo "Now Name is $NAME, and choice is $CHOICE."
echo -e "You didn't insert any name. Using defaults: $NAME. \n"

if [ "$CHOICE" == "d" ]; then
	for i in $(seq -f "%02g" 1 $NR);
		do mkdir ./$NAME${i};
	done
elif [ "$CHOICE" == "f" ]; then
	for i in $(seq -f "%02g" 1 $NR);
	    do touch $NAME${i};
	done
fi


