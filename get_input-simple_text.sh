#!/bin/bash

echo "Enter the nome of the repository: "
read depository_name
# sudo touch /etc/apt/sources.list.d/"$depository_name"
touch "$depository_name.list"

echo "Please enter first deb: "
read first_deb
echo "$first_deb" >> "$depository_name.list"
printf "\n"
tail -n 1 "$depository_name.list"
printf "\n"

echo "Please enter second deb: "
read second_deb
echo "$second_deb" >> "$depository_name.list"
printf "\n\n"
tail -n 2 "$depository_name.list"
printf "\n"

# echo 'deb http://www.yourdomain.com/packages/ubuntu /' >> /etc/apt/sources.list.d/yourdomain.sources.list

