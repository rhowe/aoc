#!/bin/bash

foo=(1 2 3 4)

IFS="
"
echo "${foo[*]}"
