#!/bin/bash

find -type f -name "*.dm" -and -not -path "./code/white/*" -exec sed -ri 's/([^r])html_encode/\1rhtml_encode/' {} +
find -type f -name "*.dm" -and -not -path "./code/white/*" -exec sed -ri 's/([^r])html_decode/\1rhtml_decode/' {} +
find -type f -name "*.dm" -and -not -path "./code/white/*" -exec sed -ri 's/([^r])json_encode/\1r_json_encode/' {} +