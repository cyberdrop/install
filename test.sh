#!/bin/bash

RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)
col=$(tput cols)

success()
{
    printf '%s%*s%s' "$GREEN" $col "[OK]" "$NORMAL"
}

fail()
{
    printf '%s%*s%s' "$RED" $col "[FAIL]" "$NORMAL"
}

