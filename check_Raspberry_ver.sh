cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}' | sed 's/^1000//'
# awk '/^Revision/ {sub("^1000", "", $3); print $3}' /proc/cpuinfo
