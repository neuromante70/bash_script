#!/bin/bash

# test mode: remove -vn to execute
perl-rename -vn 's/\d+/sprintf("%02d", $&)/e' *

