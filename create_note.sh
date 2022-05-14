#!/bin/bash

result=$(echo $* | sed -e 's/ /_/g')

echo "Do you want to write the file in linux-docs (y) or in actual path (n)? " 
read answer 
case $answer in
 [yY] ) echo -n >  ~/linux-docs/${result}.md;;
 [nN] ) echo -n > ${result}.md;;
 ""   ) echo -n > ${result}.md;;
 *    ) echo -e "\ninvalid";;
esac
# optionsAudits=("y" "n")
# select opt in "${optionsAudits[@]}" ;
# do
#     # $opt being empty signals invalid input.
#     [[ -n $opt ]] || { echo "What's that? Please try again." >&2; continue; }
#     break # a valid choice was made, exit the prompt.
# done

# read answer 
# case $answer in
# 	[y|yes] ) echo -n > ~/linux-docs/$result.md;;
# 	[n|no]  ) echo -n > $result.md;;
#     ""    ) echo -n $result.md;;
#     *     ) echo -e "\ninvalid";;
# esac


# ls $result.md
# ls ~/linux-docs/$result.md

# if [-f $result.md]; then
#     echo $?
# fi

# if [-f ~/linux-docs/$result.md]; then
#     echo $?
# fi

