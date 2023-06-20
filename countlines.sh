#!/bin/bash

# Assumptions:
# - Only count lines for .txt files
# - Abbreviations only will be accepted for the month (see HELP_MESSAGE for further details)
# - Files which will have their number of lines counted are located in the same folder as this script.

# Valid cases:
# - ./countlines.sh -o owner
# - ./countlines.sh -m month

# Invalid cases:
# - ./countlines.sh -o owner -m month
# - ./countlines.sh -x owner
# - ./countlines.sh -x
# - ./countlines.sh

count_owner_files () {
    OWNER=$2
    echo "Looking for .txt files where the owner is: $OWNER"

    result=""

    # Loop through each text file in the directory (non-recursive).
    for file in "$(pwd)"/*.txt; do
        # Validates that the file exists.
        if [ -f "$file" ]; then
            # Get the owner of the file and compare it to the owner passed in.
            if [ "$(stat -c '%U' "$file")" = "${OWNER}" ]; then
                line_count=$(wc -l < $file)
                result+="File: $file, Lines: $line_count\n"
            fi
        fi
    done
    
    echo -e "$result"
}

count_month_files () {
    MONTH=$2
    NUMERIC_USER_MONTH=""

    # Map the month the user specified to its numeric value.
    case $MONTH in
        "Jan")
            NUMERIC_USER_MONTH="01"
        ;;
        "Feb")
            NUMERIC_USER_MONTH="02"
        ;;
        "March")
            NUMERIC_USER_MONTH="03"
        ;;
        "April")
            NUMERIC_USER_MONTH="04"
        ;;
        "May")
            NUMERIC_USER_MONTH="05"
        ;;
        "June")
            NUMERIC_USER_MONTH="06"
        ;;
        "July")
            NUMERIC_USER_MONTH="07"
        ;;
        "Aug")
            NUMERIC_USER_MONTH="08"
        ;;
        "Sept")
            NUMERIC_USER_MONTH="09"
        ;;
        "Oct")
            NUMERIC_USER_MONTH="10"
        ;;
        "Nov")
            NUMERIC_USER_MONTH="11"
        ;;
        "Dec")
            NUMERIC_USER_MONTH="12"
        ;;
        *)
            # Throw an error if the month entered is invalid.
            echo -e "ERROR: Invalid month option: '${MONTH}'.\n\n"
            echo "$HELP_MESSAGE"
        ;;
    esac

    if [ "$NUMERIC_USER_MONTH" != "" ]; then
        echo "Looking for .txt files where the month is: $MONTH"
        result=""

        # Loop through each text file in the directory (non-recursive).
        for file in "$(pwd)"/*.txt; do
            # Validates that the file exists.
            if [ -f "$file" ]; then
                # To get the file "birth" or "creation" information, use `stat -c '%w'``.
                # Pipe that into awk which will split each line on the - and store the results in the `a` array.
                # The month is stored at index 2, so a[2] is used to get the creation month.
                creation_month=$(stat -c '%w' "$file" | awk '{split($0,a,"-"); print a[2]}')

                if [ "$creation_month" = "${NUMERIC_USER_MONTH}" ]; then
                    line_count=$(wc -l < $file)
                    result+="File: $file, Lines: $line_count\n"
                fi
            fi
        done
        echo -e "$result"
    fi
}

count_lines () {
    # Check that there are exactly 2 parameters specified.
    if [ $# != 2 ]; then
        echo $'ERROR: Invalid number of parameters. This script expects 1 parameter and its corresponding argument.\n\n'
        echo "$HELP_MESSAGE"
    else
        # Check that the arguments specified are either -o or -m. Anything else will throw an error.
        case $1 in
            -o)
                count_owner_files $@ 
            ;;
            -m)
                count_month_files $@
            ;;
            *)
                echo $'ERROR: illegal option -x. Specify either -m or -o.\n\n'
                echo "$HELP_MESSAGE"
            ;;
        esac
    fi
}

HELP_MESSAGE=$'This script will count the number of lines in text files located in the current directory when:
- They belong to an owner OR
- When were created in a specific month

There can be a maximum of 1 flag and its corresponding argument passed in at a time. Valid flags are the following:\n
-o <owner> The owner\'s name of the file.
-m <month> The month the file was created on. Valid options for months are as followed:
    - Jan
    - Feb
    - March
    - April
    - May
    - June
    - July
    - Aug
    - Sept
    - Oct
    - Nov
    - Dec\n
Examples:\n./countlines.sh -o owner_name\n\nor\n\n./countlines.sh -m June'

count_lines $@