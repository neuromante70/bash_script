#!/bin/bash
# echo 'deb http://www.yourdomain.com/packages/ubuntu /' >> /etc/apt/sources.list.d/yourdomain.sources.list


sudo cp /etc/apt/sources.list /etc/apt/sources.list.orig

echo "Enter the nome of the repository: "
read depository_name
touch /etc/apt/sources.list.d/"$depository_name.list"
# touch "$depository_name.list"

echo "Please enter first deb: "
read first_deb
echo "$first_deb" >> /etc/apt/sources.list.d/"$depository_name.list"
printf "\n"
tail -n 1 /etc/apt/sources.list.d/"$depository_name.list"
printf "\n"

echo "Please enter second deb: "
read second_deb
echo "$second_deb" >> /etc/apt/sources.list.d/"$depository_name.list"
printf "\n\n"
tail -n 2 /etc/apt/sources.list.d/"$depository_name.list"
printf "\n"

sudo apt-get update
