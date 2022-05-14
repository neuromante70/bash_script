#!/bin/bash
# 
#   copyright © 2015 retiredbutstillhavingfun
#
#   Happy Desktop
#   Version 0.99
#   drm 20Nov2015
#   drm200@free.fr
#
#
#### Program Requirements: #####
#  This program is used to save/restore/align the Ubuntu Desktop icons
#  positions when Nautilus is managing the desktop (this is the ubuntu
#  14.04 default). I have only tested this with ubuntu 14.04 but it should
#  also work with Ubuntu 14.10 and 15.04 as the requirements are installed
#  by default. Ubuntu 12.04 does not have the required gvfs-info.
#	
#   Requirements:
#     Nautilus is your file manager
#     bash, gvfs-info, zenity, gsettings, xprop, sed, grep
#
#   Optional:
#     xdotool (is used to automatically refresh desktop)
#     Use F5 to manually refresh if it is not installed
#
#exec 5> debug_output.txt
#BASH_XTRACEFD="5"
#set -x
#PS4='$LINENO: '

### Definition of constants #####

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE is a relative symlink, resolve it
done
script_path="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
desktop_path="$(eval echo ~$USER)/Desktop" # must NOT end with backslash
restore_file="$script_path/happy_desktop_restore.txt"
ini_file="$script_path/happy_desktop.ini"
lang_file="$script_path/happy_desktop_lang"
title_text="Happy Desktop"
x_min=62 # x-axis icon canvas offset .. for values below this the icon fails to move left
this_script_name=$(basename "${BASH_SOURCE[0]}")
sure_name="$script_path/$this_script_name"

### functions #####

get_screen_data ()
{
nautilus_icon_zoom=$(gsettings get org.gnome.nautilus.icon-view default-zoom-level)
if [ $? -eq 1 ]; then
	zenity --warning --no-wrap --text="Failed to get Nautilus icon zoom.\n\nAborting"
	reply="abort"
else
	current_zoom=$(convert_zoom $nautilus_icon_zoom)
	available_screen=$(xprop -root | grep -e 'NET_WORKAREA(CARDINAL)') #get available screen dimensions
	available_screen=${available_screen##*=} #strip off beginning text
	current_screen_width=$(echo $available_screen | cut -d ',' -f3 | sed -e 's/^[ \t]*//')
	current_screen_height=$(echo $available_screen | cut -d ',' -f4 | sed -e 's/^[ \t]*//')
	reply="continue"
fi
}


# pass nautilus setting and return zoom in %
convert_zoom ()
{
case "$1" in
	*"smallest"*) echo 33;;
	*"smaller"*) echo 50;;
	*"small"*) echo 66;;
	*"standard"*) echo 100;;
	*"large"*) echo 150;;
	*"larger"*) echo 200;;
	*"largest"*) echo 400;;
	*) echo 100;;
esac
}

#check for changes in screen resolution or icon scale since last run
check_for_screen_changes()
{
if [ "$current_screen_width" -ne "$screen_width" ] || [ "$current_screen_height" -ne "$screen_height" ] ; then
	warning_popup "${lang[msg9]} $screen_width x $screen_height ${lang[msg10]} $current_screen_width x $current_screen_height"
	adjust_icon_positions
fi
if [ "$current_zoom" -ne "$icon_zoom" ]; then
	warning_popup "${lang[msg12]} $icon_zoom ${lang[msg10]} $current_zoom"
	icon_zoom=$current_zoom
	adjust_icon_positions
fi
}


warning_popup ()
{
zenity --info --no-wrap --text="$1  \n${lang[msg11]}"
}

set_lang_default()
{
typeset -gA lang
lang=(
		[main1]="Save current icon positions"
		[main2]="Save icon positions to grid"
		[main3]="Restore icon positions"
		[main4]="Configuration"
		[main5]="Help"
		[main6]="About"
		[main7]="Select an item"
		[pb_done]="Done"
		[pb_select]="Select"
		[pb_return]="Return"
		[pb_edit]="Edit"
		[pb_save]="Save"
		[pb_cancel]="Cancel"
		[config1]="Language"
		[config2]="Icons per row"
		[config3]="Icons per column"
		[config4]="Left Margin"
		[config5]="Top Margin"
		[config6]="Grid Width"
		[config7]="Grid Height"
		[config8]="Select an item"
		[msg1]="Icon positions saved"
		[msg2]="Icon positions restored"
		[msg3]="Press F5 to refresh desktop"
		[msg4]="Enter new value for"
		[msg5]="Negative values are\n not allowed!"
		[msg6]="Values must be numbers ... Not text!"
		[msg7]="Xdotool is NOT installed and is required\nto auto-refresh the desktop.\n\n Press F5 to manually refresh."
		[msg8]="Would you like to create a desktop icon\nto launch the application?"
		[msg9]="Screen resolution has changed from"
		[msg10]="to"
		[msg11]="since the icon positions were last saved.  \n\nIcon positions will be updated!"
		[msg12]="The Nautilus default icon zoom has changed from"
	)
}


set_language()
{
reply=$(zenity --title="$title_text" --hide-header --text="${lang[main7]}" --list --cancel-label="${lang[pb_return]}" \
--ok-label="${lang[pb_select]}" --column="" "${lang_list[@]}")
if [ ! $? -eq 0 ]; then
	if [ -z "$1" ]; then reply="English"; else reply="$1"; fi
fi
echo "$reply"
}


get_languages()
{
lang_list=("English")
while read -r line; do
	if [ "${line:0:1}" == "[" ] && [ "${line: -1}" == "]" ]; then
		tmp="${#line}"
		if (( "$tmp" > "2" )); then
			(( tmp="$tmp"-2 ))
			tmp="${line:1:$tmp}"
			if [ ! "$tmp" == "English" ]; then lang_list=("${lang_list[@]}" "$tmp"); fi
		fi
	fi
done < "$lang_file"
}


#arguments: language
language_config()
{
set_lang_default
if [ -z "$1" ]; then
	language="English"
	write_ini
elif [ ! "$1" == "English" ] && [ -s "$lang_file" ]; then
	read_lang_data "$1"
fi
}



#arguments language
read_lang_data()
{
start=0
while read -r line; do
	case "$start" in
		"1") 
			case "$line" in
			     *=*) tmp="${line%=*}"; lang[$tmp]="${line#*=}";;
			esac
			if [ "${line:0:1}" == "[" ]; then start=2; fi
			;;
		"0")
			case "$line" in
				"[""$1""]") start=1
				;;
			esac
			;;
	esac
done < "$lang_file"
}


start_dialog ()
{
zenity --list \
	--title="    $title_text" \
	--text "${lang[main7]}:" --ok-label="${lang[pb_select]}"\
	--cancel-label="${lang[pb_done]}" --width $(($screen_width * 10 / 40)) --height $(($screen_height * 10 / 30)) \
	--column="" --column="" --hide-column=1 --hide-header "Save current icon positions" "${lang[main1]}" \
	"Save icon positions to grid" "${lang[main2]}" "Restore icon positions" "${lang[main3]}" "Configuration" "${lang[main4]}" \
	"Help" "${lang[main5]}" "About" "${lang[main6]}"
}


#arguments filename grid
#Get current icon positions, adjust to grid if requested & create restore file
write_icon_pos()
{
local tmp=""
while read line; do
	case "$line" in
		*"standard::name:"*) name=${line#*name: }
			;;
		*"metadata::nautilus-icon-position:"*)
			position=${line#*position: }
			if [ "$2" == "true" ]; then #adjust positions to grid
				x_pos=${position%,*}
				y_pos=${position#*,}
				((left_min = ($left_margin + $x_min))) # x-axis icon canvas offset
				x_pos="$(convert_coordinates $x_pos $left_min $grid_width $x_max)"
				y_pos="$(convert_coordinates $y_pos $top_margin $grid_height $y_max)"
				position="$x_pos,$y_pos"
			fi
			tmp="$tmp""\n""gvfs-set-attribute \"$desktop_path/$name\" metadata::nautilus-icon-position $position"
			;;
	esac
done < <(gvfs-info $desktop_path/* | grep -e 'standard::name: [^ ]\+\|nautilus-icon-position: [^ ]\+')
tmp=$(echo "$tmp" | sed 's/\\n//')
echo -e "$tmp" > "$1"
}


# arguments: position, margin, grid, max
# this routine converts an icon coordinates to the closest grid lines
convert_coordinates ()
{
	if (("$1" <= "$2")); then
		ret=$(($2))
	else
		((ret = ((($1-$2) / $3) * $3) +$2))
		if (("(($1-$2) % $3) * 2" > "$3")); then ((ret = $ret + $3)); fi
		if (("$ret" > "($4 - ($3))")); then ((ret = ((($4-$2-$3) / $3) * $3) +$2)); fi
	fi
	echo $ret
}


# restore icon positions from file
restore_op ()
{
	cnt=0
	while read line
	do
		eval "$line"
		if [ $? -eq 0 ]; then
			: # do nothing the icon was found and will be updated
		else
			echo "Desktop icon has been deleted since last save"
		fi
		((cnt=cnt+1))
	done < "$restore_file"
}

set_default_values ()
{
language="English"
x_max=$(($current_screen_width * 100 / $current_zoom))
y_max=$((($current_screen_height * 100) / $current_zoom))
icons_per_row=12
icons_per_column=7
grid_width=$(($x_max/($icons_per_row + 1)))
grid_height=$(($y_max/($icons_per_column+1)))
left_margin=$(($grid_width/4))
top_margin=$(($grid_height/4))
screen_width=$current_screen_width
screen_height=$current_screen_height
icon_zoom=$current_zoom
xdotool_warning_seen="false"
}


read_ini ()
{
while read -r line; do
	case "$line" in
		language=*) language=${line#*=};;
		screen_width=*) screen_width=${line#*=};;
		screen_height=*) screen_height=${line#*=};;
		icon_zoom=*) icon_zoom=${line#*=};;
		left_margin=*) left_margin=${line#*=};;
		top_margin=*) top_margin=${line#*=};;
		grid_width=*) grid_width=${line#*=};;
		grid_height=*) grid_height=${line#*=};;
		icons_per_row=*) icons_per_row=${line#*=};;
		icons_per_column=*) icons_per_column=${line#*=};;
		xdotool_warning_seen=*) xdotool_warning_seen=${line#*=};;
	esac
done < "$ini_file"
}


write_ini ()
{
new_ini="[configuration]\nlanguage=$language\nscreen_width=$screen_width\nscreen_height=$screen_height\nicon_zoom=$icon_zoom\nicons_per_row=$icons_per_row\nicons_per_column=$icons_per_column\ngrid_width=$grid_width\ngrid_height=$grid_height\nleft_margin=$left_margin\ntop_margin=$top_margin\nxdotool_warning_seen=$xdotool_warning_seen"
echo -e "$new_ini" > "$ini_file"
}


# dialog box to pick field to be edited in ini file
edit_ini()
{
repeat=1
while [ $repeat -eq 1 ]; do
edit_field=$(zenity --list --title="$title_text" --text="${lang[config8]}:" --editable \
	--width $(($screen_width * 10 / 45)) --height $(($screen_height * 10 / 30)) \
	--ok-label="${lang[pb_edit]}" --cancel-label="${lang[pb_return]}" --column="" --column="" --hide-header --hide-column=1 \
	"language" "${lang[config1]} = $language" \
	"icons_per_row" "${lang[config2]} = $icons_per_row" "icons_per_column" "${lang[config3]} = $icons_per_column" \
	"left_margin" "${lang[config4]} = $left_margin" "top_margin" "${lang[config5]} = $top_margin" \
	"grid_width" "${lang[config6]} = $grid_width" "grid_height" "${lang[config7]} = $grid_height")
	if [ $? -eq 0 ]; then
		edit_dialog "$edit_field"
	else
		repeat=0
	fi
done
}


edit_dialog()
{
case "$1" in
	"language") value="language";;
	"icons_per_row") etext="${lang[config2]}"; value=$icons_per_row;;
	"icons_per_column") etext="${lang[config3]}"; value=$icons_per_column;;
	"left_margin") etext="${lang[config4]}"; value=$left_margin;;
	"top_margin") etext="${lang[config5]}"; value=$top_margin;;
	"grid_width") etext="${lang[config6]}"; value=$grid_width;;
	"grid_height") etext="${lang[config7]}"; value=$grid_height;;
esac

case "$value" in
language ) ret=$(set_language "$language")
			if [ ! "$ret" == "$language" ]; then
				language="$ret"
				write_ini
				language_config "$language"
			fi
			;;
		*)
			new_val=$(zenity --entry --title="$title_text" --ok-label="${lang[pb_save]}" --cancel-label="${lang[pb_cancel]}" \
			--text="${lang[msg4]}\n$etext:" --entry-text="$value")
			if [ $? -eq 0 ] ; then
				ret=$(verify_limits "$new_val" "$etext")
				if [ "$ret" = "true" ]; then
					if [ "$new_val" -ne "$value" ]; then
						(($1=$new_val))  #sets the variable defined by $1 to the new value
						if [ "$1" == "icons_per_row" ]; then
							grid_width=$((($x_max - $left_margin - $x_min - $x_min) / ($icons_per_row)))
						fi
						if [ "$1" == "icons_per_column" ]; then
							grid_height=$((($y_max - $top_margin) / ($icons_per_column)))
						fi
						write_ini
						move_icons_to_grid
					fi
				fi
			else
				echo "cancel"
			fi
			;;
esac
}


# arguments: $new_val $etext
verify_limits()
{
ret="false"
if [ "$1" -eq "$1" ] 2>/dev/null; then #checks if the value is an integer
	if [ "$1" -ge 0 ]; then #must not be negative integer
		case "$2" in
			Grid*) if [ "$1" -gt 50 ]; then ret="true"; else zenity --warning --text="Grid size too small!"; fi;;
			Icons*) if [ "$1" -gt 4 ]; then ret="true"; else zenity --warning --text="Icon count too small!"; fi;;
			*) ret="true";;
		esac
	else
		zenity --warning --text="${lang[msg5]}!"
	fi
else
zenity --warning --text="${lang[msg6]}"
fi
echo $ret
}

#arguments "restore"
desktop_refresh()
{
if [ $xdotool_installed == "true" ]; then
 	tmp=$(xdotool search --name "Desktop")
	WID=$(echo ${tmp//$'\n'/ } | sed 's/ .*//')
  	xdotool windowfocus $WID
	xdotool key F5
	if [ "$1" == "restore" ]; then
		notify-send --hint=int:transient:1 -a Icons "${lang[msg2]}";
	else
		notify-send --hint=int:transient:1 -a Icons "${lang[msg1]}";
	fi
else
	if [ "$xdotool_warning_seen" == "false" ] ; then
		zenity --info --title "Info" --text="${lang[msg7]}" --no-wrap
		xdotool_warning_seen="true"
		write_ini
	else
		notify-send --hint=int:transient:1 -a Icons "${lang[msg3]}";
	fi
fi
}


move_icons_to_grid()
{
	grid="true"
	write_icon_pos "$restore_file" "$grid"
	grid="false"
	restore_op "$restore_file"
	desktop_refresh
}

restore_icon_positions()
{
	if [ -f "$restore_file" ]; then
		restore_op "$restore_file"
		desktop_refresh "restore"
	else
		zenity --info --title "Info" --text "No backup file exists. Restore cancelled." --no-wrap
	fi
}

create_desktop_icon()
{
desktop_file=$desktop_path/"Happy Desktop.desktop"
zenity --question --text="\n${lang[msg8]}?"
if [ $? -eq 0 ]; then
	temp="#!/usr/bin/env xdg-open\n[Desktop Entry]\nName=Happy Desktop\nComment=Organize, Save and Restore your desktop icons\nKeywords=icons;desktop\nExec=$script_path/Happy_Desktop.sh\nIcon=$script_path/Happy_Desktop.png\nTerminal=false\nType=Application\nStartupNotify=false"
	echo -e "$temp" > "$desktop_file"
	chmod +x "$desktop_file"
fi
}

adjust_icon_positions()
{
grid_width=$(($grid_width * $current_screen_width / $screen_width))
grid_height=$(($grid_height * $current_screen_height / $screen_height))
screen_width=$current_screen_width
screen_height=$current_screen_height
x_max=$(($screen_width * 100 / $icon_zoom))
y_max=$((($screen_height * 100) / $icon_zoom))
write_ini
move_icons_to_grid
}


read_text()
{
local start=0
local ret=""
while read -r line; do
	if [ "${line}" == "$2" ]; then start=2; fi
	if [ $start -eq 1 ]; then ret="$ret\n$(echo "${line:1}")"; fi
	if [ "${line}" == "$1" ]; then start=1; fi
done < "$sure_name"
echo "$ret"
}


display_help()
{
help_txt=$(read_text "#done" "#gnu_text")
echo -e "$help_txt" | zenity --text-info --cancel-label="${lang[pb_return]}" --font="tahoma" --title="     $title_text Help " --width $(($screen_width / 2)) --height $(($screen_height / 2))
}


about_this()
{
gnu_txt=$(read_text "#gnu_text" "end")
about_txt="<span background=\"#007f00\" font_desc=\"WebDings Italic 24\" foreground=\"#ff7f7f\" stretch=\"ultraexpanded\" underline=\"double\" variant=\"smallcaps\" weight=\"900\">  Happy Desktop  </span>\\n\\n<small>version 0.99\\n\\ncopyright © 2015 retiredbutstillhavingfun\\ndrm200@free.fr\\n$gnu_txt</small>"
zenity --info --no-wrap --title="$title_text" --text="$about_txt"
}


### Program Start #########

#check if gvfs-info is installed
command -v gvfs-info >/dev/null 2>&1 || { zenity --warning --no-wrap --text="\ngvfs-info is required to obtain\nicon positions but is not installed.\n\n Aborting."; exit 1; }

#check if xdotool installed
if xdotool --version >/dev/null 2>&1; then xdotool_installed="true"; else xdotool_installed="false"; fi

get_screen_data
if [ "$reply" == "abort" ]; then exit 0; fi

# if ini file missing, create it
if [ ! -s "$ini_file" ]; then
	set_default_values
	write_ini
	create_icon="true"
else
	read_ini
	x_max=$(($screen_width * 100 / $icon_zoom))
	y_max=$((($screen_height * 100) / $icon_zoom))
fi

if [ -s "$lang_file" ]; then get_languages; fi
language_config "$language"

check_for_screen_changes


# if restore file does not exist then create it
if [ ! -s "$restore_file" ]; then
	grid="false"
	write_icon_pos "$restore_file" "$grid"
fi

# on first run create desktop icon 
if [ "$create_icon" == "true" ]; then create_desktop_icon; fi


repeat=1
while [ $repeat -eq 1 ]; do
	reply="$(start_dialog)"
	[ $? -eq 0 ] || repeat=0
	case "$reply" in
   "Save current icon positions")
			grid="false"
			write_icon_pos "$restore_file" "$grid"
			notify-send --hint=int:transient:1 -a Icons "${lang[msg1]}";
			repeat=0
			;;
   "Save icon positions to grid") move_icons_to_grid; repeat=0;;
   "Restore icon positions") restore_icon_positions; repeat=0;;
   "Configuration") read_ini; edit_ini; repeat=1;;
   "Help") display_help; repeat=1;;
   "About") about_this; repeat=1;;
	esac
done
exit 0

#done
#   Happy Desktop
#   Version 0.99
#   drm 20Nov2015
#   drm200@free.fr
#
#   copyright © 2015 retiredbutstillhavingfun
#
#    This program save/restore/align the Ubuntu Desktop icons when
# Nautilus is managing the desktop (this is the ubuntu 14.04 default)
# I have only tested this with ubuntu 14.04 but it should also work on
# Ubuntu 14.10 and 15.04 as the requirements are installed by default.
# Ubuntu 12.04 does not use the required gvfs-info.
#	
#  Requirements:
#    ... Nautilus is your file manager
#    ... bash, gvfs-info, zenity, gsettings, xprop, sed, grep
#
#  Optional:
#    ... xdotool (is used to automatically update/refresh desktop)
#    ... Use F5 to manually refresh the desktop icons positions if xdotool is not installed
#
#
#Purpose: This script provides a GUI interface for all actions:
#    ...Saves the current icon layout to file
#    ...Align your icon positions to a grid and save the new layout to file
#    ...Restore your icon layout using the previously saved file
#
##### Installation Instructions  ####
#
#1.   (Optional) Install xdotool from the Ubuntu software repository.  This program allows auto refresh of the desktop by sending an F5 keystroke. If you choose not to install, you must use F5 to manually refresh the desktop to view icon position changes.
#
#2. Copy the three files:
#		Happy_Desktop.sh
#		Happy_Desktop.png
#		happy_desktop.lang
#
# 	to either your bin or nautilus scripts folder or subfolder with name of your choice:
#        (/home/YourUserName/bin) or
#        (/home/YourUserName/.local/share/nautilus/scripts) or
#        (/home/YourUserName/bin/anysubfolder) or
#        (/home/YourUserName/.local/share/nautilus/scripts/anysubfolder)
#
##### Initial Setup ####
#
#1. Make the script executable and run the script. You will be given the option to create a desktop icon to launch the application on the first script run.   
#
#2. On the first run, two files will be created in the installation directory:
#         happy_desktop.ini   (where your preferences are saved)
#         happy_desktop_restore.txt   (used to restore icon positions)
#   
#
#3.   Select "Configuration". Edit the "Icons Per Row" and "Icons per column" based upon your preferences.  This will create the initial grid size.
#
#4.   Now select "Save icon positions to grid".  This will move the icons to the nearest grid line.
#
#5.   Now return to configuration and adjust the left and top margins to your requirements.
#
#6.   Now tweak the grid width and height to finalize your setup.
#
#     Note: The "Icons Per Row" and "Icons per column" values are only used to determine initial grid values.  After that, the margins and grid dimensions control the layout. Changing the "Icons Per Row" and "Icons per column" again will also change the grid dimensions (but not the margins).
#
#     Note: This program uses your screen resolution and the "default icon zoom" (under Nautilus\preferences) to determine the initial grid size.  Changing either the screen resolution or "default icon zoom" will require the repeat of the initial setup.
#
#
##### Running the program after setup ####
#
#     There are five options:
#1.   "Save current icon positions" - This creates a file "happy_desktop_restore.txt". This file will be used restore the current icon layout. (Note, saving does not move icons ... it just saves their positions)
#
#2.   "Save icon positions to grid" - This will align the icons to the nearest grid lines established earlier. If xdotool is not installed you will need to depress F5  or logout to see the results.
#
#3.   "Restore icon positions" - This will restore the icon positions using the file "happy_desktop_restore.txt". If xdotool is not installed you will need to depress F5  or logout to see the results.
#
#4.   "Configuration" - This allows you to change language, edit margins and grid size.
#
#5.   "Help" - Displays this Help text.
#
##### Language Translations ####
# Beginning version 0.86 the interface supports multilanguage by using the file "happy_desktop_lang
#
# To add support for your language, just add your translations to "happy_desktop_lang". Use the English and Spanish translations as a template for your language.  Your new language will automatically appear as an option in the language configuration menu.
#
##### Creating a desktop icon  ####
#
#1. The program will prompt you to create a desktop icon to launch the application on the first script run.  If you did not create a desktop icon on the first script run, you can delete the file "Happy_Desktop.ini" and then the next time you run the script it will prompt you again to create the desktop launch icon.
#
#
##### Change log ####
# Version 0.80 ... initial release
#
# Version 0.82
#   ... improved handling of icons that have consecutive spaces in the icon name.
#   ... improved positioning of icon to the grid when at the screen extremes
#   ... added ability to automatically create a desktop launch icon on first script run
#   ... fixed bug that causes error when desktop size is changed
#
# Version 0.84
#   ... Previously xrandr was used to provide screen resolution information. But
#       xrandr disregards any panels taking up desktop space such as the menu bar
#       or a fixed launcher (when launcher auto-hide is not enabled).  Xprop is now
#       used to provide screen information. Xprop has the ability to provide the
#       actual "available screen dimensions" after considering things like the menu
#       bar or a fixed launcher. This improves the icon grid positioning.
#   ... Suppressed the popup message "Press F5 to manually refresh" after it has been
#       displayed one time. This warning only occurs if you do not have xdotool installed.
#   ... Added simple validation of input data in the edit boxes with warning box feedback
#
# Version 0.85
#   ... Improved error feedback
#   ... fixed problem where desktop icon did not display properly
#   ... some code optimization
#
# Version 0.86
#   ... multi-language support for user interface via language file
#   ... separate help file no longer required
# 
# Version 0.86a
#   ... language file now includes English,Español,Français,Italiano,Português
#
# Version 0.87
#   ... in some cases if multiple windows were open on the desktop, the desktop
#       refresh would not happen.  This version fixes that problem.
#
# Version 0.99
#   ... fixed grid calculation error introduced in v0.86 when changing
#       icons per row or icons per column
#   ... improved menus and translations
#   ... eliminated the need to create a tmp file during program execution
#  
#
#   Is this program is working/not working for you on Ubuntu 14.04, 14.10 or 15.04?
#   Please provide some feedback on the download site.
#
#
#gnu_text
#This program is free software; you can redistribute
#it and/or modify it under the terms of the GNU General
#Public License as published by the Free Software
#Foundation; either version 2 of the License, or
#(at your option) any later version.
#
#This program is distributed in the hope that it will be
#useful, but WITHOUT ANY WARRANTY; without even
#the implied warranty of MERCHANTABILITY or FITNESS
#FOR A PARTICULAR PURPOSE.  See the GNU General
#Public License for more details.

#You should have received a copy of the GNU General
#Public nLicense along with this program; if not, write
#to:
#              Free Software Foundation, Inc.
#              51 Franklin St, Fifth Floor
#              Boston, MA  02110-1301 USA

