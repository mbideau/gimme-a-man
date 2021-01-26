#!/bin/sh
#
# generate a "man page" with the "troff" format, from the program's help output.
#
# Standards in this script:
#   POSIX compliance:
#      - http://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html
#      - https://www.gnu.org/software/autoconf/manual/autoconf.html#Portable-Shell
#   CLI standards:
#      - https://www.gnu.org/prep/standards/standards.html#Command_002dLine-Interfaces
#
# Source code, documentation and support:
#   https://github.com/mbideau/gimme-a-man
#
# Copyright (C) 2020 Michael Bideau [France]
#
# This file is part of gimme-a-man.
#
# gimme-a-man is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# gimme-a-man is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with gimme-a-man. If not, see <https://www.gnu.org/licenses/>.
#

# halt on first error
set -e


# package infos
VERSION=0.1.0
PACKAGE_NAME=gimme-a-man
AUTHOR='Michael Bideau'
HOME_PAGE='https://github.com/mbideau/gimme-a-man'
REPORT_BUGS_TO="$HOME_PAGE/issues"
PROGRAM_NAME="$PACKAGE_NAME"


# technical vars
THIS_SCRIPT_PATH="$(realpath "$0")"
THIS_SCRIPT_NAME="$(basename "$THIS_SCRIPT_PATH")"
THIS_SCRIPT_DIR="$(dirname "$THIS_SCRIPT_PATH")"


# functions

# sets all required locale variables and exports
setup_language()
{
    # translation variables

    # gettext binary or echo
    GETTEXT="$(which gettext 2>/dev/null || which echo)"

    # gettext domain name
    TEXTDOMAIN="$PACKAGE_NAME"

    # gettext domain directory
    if [ "$TEXTDOMAINDIR" = '' ]; then
        if [ -d "$THIS_SCRIPT_DIR"/locale ]; then
            TEXTDOMAINDIR="$THIS_SCRIPT_DIR"/locale
        elif [ -d /usr/share/locale ]; then
            TEXTDOMAINDIR=/usr/share/locale
        fi
    fi

    # environment variable priority defined by gettext are : LANGUAGE, LC_ALL, LC_xx, LANG
    # see: https://www.gnu.org/software/gettext/manual/html_node/Locale-Environment-Variables.html#Locale-Environment-Variables
    # and: https://www.gnu.org/software/gettext/manual/html_node/The-LANGUAGE-variable.html#The-LANGUAGE-variable

    # gettext requires that at least one local is specified and different from 'C' in order to work
    if { [ "$LC_ALL" = '' ] || [ "$LC_ALL" = 'C' ]; } && { [ "$LANG" = '' ] || [ "$LANG" = 'C' ]; }
    then

        # set the LANG to C.UTF-8 so gettext can handle the LANGUAGE specified
        LANG=C.UTF-8
    fi

    # export language settings
    export TEXTDOMAIN
    export TEXTDOMAINDIR
    export LANGUAGE
    export LC_ALL
    export LANG
}

# translate a text and use printf to replace strings
# @param  $1  string  the string to translate
# @param  ..  string  string to substitute to '%s' (see printf format)
__()
{
    _t="$("$GETTEXT" "$1" | tr -d '\n')"
    shift
    # shellcheck disable=SC2059
    printf "$_t\\n" "$@"
}

# print out debug information to STDERR
# @param  $1  formatting (like first arg of printf)
# @param  ..  string  string to substitute to '%s' (see printf format)
debug()
{
    if [ "$DEBUG" = "$PROGRAM_NAME" ]; then
        # shellcheck disable=SC2059
        printf "$@" | sed 's/^/[DEBUG] /g' >&2
    fi
}

# usage
usage()
{
    cat <<ENDCAT

$PROGRAM_NAME - $( __ 'generate a "man page" with the "troff" format, from a program'"'"'s help output.')

$(__ 'USAGE')

    $PROGRAM_NAME [$(__ 'OPTIONS')] $(__ 'PROG_BIN') $(__ 'PROG_NAME') $(__ 'PROG_VERSION') $(__ 'MAN_SECT_NUM')
    $PROGRAM_NAME [$(__ 'OPTIONS')] -f|--file $(__ 'HELP_FILE') $(__ 'PROG_NAME') $(__ 'PROG_VERSION') $(__ 'MAN_SECT_NUM')

    $PROGRAM_NAME -H|--help2man $(__ 'PROG_BIN') [ -- ..HELP2MAN_ARGS.. ]

    $PROGRAM_NAME -h|--help
    $PROGRAM_NAME -v|--version


$(__ 'ARGUMENTS')

    $(__ 'PROG_BIN')
        $(__ 'Path of the program binary.')
        $(__ "It will be executed with the option '%s'." '--help')

    $(__ 'PROG_NAME')
        $(__ 'Name of the program.')

    $(__ 'PROG_VERSION')
        $(__ 'Version of the program.')

    $(__ 'MAN_SECT_NUM')
        $(__ 'Man page section number.')

    $(__ 'HELP_FILE')
        $(__ "A file containing the program's help output.")

    ..HELP2MAN_ARGS..
        $(__ 'Arguments passed to the %s binary' 'GNU help2man')


$(__ 'OPTIONS')

    -l | --locale $(__ 'LOCALE')
        $(__ 'The language to use when calling the program.')
        $(__ "This will set the variable %s to the provided language." 'LANGUAGE')
        $(__ "See '%s' documentation for its definition." 'GNU gettext')

    -f | --file
        $(__ "Use the specified file as the program's help output.")

    -o | --help-option $(__ 'OPTION')
        $(__ "Use the specified option instead of calling the program with '%s'." '--help')

    -H | --help2man
        $(__ 'Use the %s binary to produce the man page.' 'GNU help2man')

    -h | --help
        $(__ 'Display help message.')

    -v | --version
        $(__ 'Display version and license informations.')


$(__ 'EXAMPLES')

    $(__ "Produce the french man page for '%s'" "$PROGRAM_NAME")
    \$ $PROGRAM_NAME -l fr_FR.UTF-8 $PROGRAM_NAME $PROGRAM_NAME "\$($PROGRAM_NAME --version | head -n 1)" 1 > /tmp/$PROGRAM_NAME.nice.fr.man

    $(__ "Read it with the '%s' command" 'man')
    \$ man /tmp/$PROGRAM_NAME.nice.fr.man


    $(__ "Produce the french man page for '%s' with the %s binary" "$PROGRAM_NAME" 'help2man')
    \$ $PROGRAM_NAME $PROGRAM_NAME --help2man -- -L fr_FR.UTF-8 --section 1 > /tmp/$PROGRAM_NAME.less-nice.man

    $(__ "Read it with the '%s' command" 'man')
    \$ man /tmp/$PROGRAM_NAME.less-nice.man


    $(__ "Save the help message for '%s'" "$PROGRAM_NAME")
    \$ $PROGRAM_NAME --help > /tmp/$PROGRAM_NAME.help.txt

    $(__ "Produce the man page for '%s' from the file containing the help output" "$PROGRAM_NAME")
    \$ $PROGRAM_NAME --file /tmp/$PROGRAM_NAME.help.txt $PROGRAM_NAME "\$($PROGRAM_NAME --version | head -n 1)" 1 > /tmp/$PROGRAM_NAME.nice.man

    $(__ "Read it with the '%s' command" 'man')
    \$ man /tmp/$PROGRAM_NAME.nice.man


$(__ 'ENVIRONMENT')

    DEBUG
        $(__ "Print debugging information to '%s' only if var %s='%s'." 'STDERR' 'DEBUG' "$PROGRAM_NAME")

    LANGUAGE
    LC_ALL
    LANG
    TEXTDOMAINDIR
        $(__ "Influence the translation.")
        $(__ "See %s documentation." 'GNU gettext')


$(__ 'AUTHORS')

    $(__ 'Written by'): $AUTHOR


$(__ 'REPORTING BUGS')

    $(__ 'Report bugs to'): <$REPORT_BUGS_TO>


$(__ 'COPYRIGHT')

    $(usage_version | tail -n +2 | sed "2,$ s/^/    /")


$(__ 'SEE ALSO')

    $(__ 'Home page'): <$HOME_PAGE>

ENDCAT
}

# display version
usage_version()
{
    _year="$(date '+%Y')"
    cat <<ENDCAT
$PROGRAM_NAME $VERSION
Copyright © 2020$([ "$_year" = '2020' ] || echo "-$_year") $AUTHOR.
$(__ "License %s: %s <%s>" 'GPLv3+' 'GNU GPL version 3 or later' 'https://gnu.org/licenses/gpl.html')
$(__ "This is free software: you are free to change and redistribute it.")
$(__ "There is NO WARRANTY, to the extent permitted by law.")
ENDCAT
}

# return 0 if section is using tags
is_section_using_tags()
{
    echo "$1" | grep -q "^\($SECT_ARGUMENTS\|$SECT_OPTIONS\|$SECT_FILES\|$SECT_ENVIRONMENT\|"`
                        `"$SECT_DIAGNOSTICS\|$SECT_COMMANDS\)"
}


# main program

# options (requires GNU getopt)
if ! TEMP="$(getopt -o 'l:fhHo:v' --long 'locale:,file,help,help2man,help-option:,version' \
                    -n "$THIS_SCRIPT_NAME" -- "$@")"
then
    __ 'Fatal error: invalid option' >&2
    exit 1
fi
eval set -- "$TEMP"

opt_locale=
opt_file=false
opt_help=false
opt_help2man=false
opt_version=false
opt_help_option='--help'
while true; do
    # shellcheck disable=SC2034
    case "$1" in
        -l | --locale      ) opt_locale="$2"      ; shift 2 ;;
        -f | --file        ) opt_file=true        ; shift   ;;
        -h | --help        ) opt_help=true        ; shift   ;;
        -H | --help2man    ) opt_help2man=true    ; shift   ;;
        -o | --help-option ) opt_help_option="$2" ; shift 2 ;;
        -v | --version     ) opt_version=true     ; shift   ;;
        -- ) shift; break ;;
        *  ) break ;;
    esac
done


# setup language
setup_language


# help/usage
if [ "$opt_help" = 'true' ]; then
    usage
    exit 0
fi

# display version
if [ "$opt_version" = 'true' ]; then
    usage_version
    exit 0
fi

# no enough argument
if { [ "$opt_help2man" != 'true' ] && [ "$#" -lt 4 ]; } || \
   { [ "$opt_help2man"  = 'true' ] && [ "$#" -lt 1 ]; }
then
    __ "Fatal error: Too few arguments (to display help, use '%s' option)" '--help' >&2
    exit 1
fi


# main program

debug "LANGUAGE='%s', LC_ALL='%s', LANG='%s', TEXTDOMAINDIR='%s'\n" \
    "$LANGUAGE" "$LC_ALL" "$LANG" "$TEXTDOMAINDIR"

# not using --file option
if [ "$opt_file" != 'true' ]; then

    # bin argument
    prog_bin="$1"

    if ! _bin="$(which "$prog_bin" 2>/dev/null)"; then
        if [ ! -x "$prog_bin" ]; then
            __ "Fatal error: invalid program binary '%s'" "$prog_bin" && exit 3
        fi
        _bin="$prog_bin"
    fi


    # create a temp file
    _help="$(mktemp)"

    # setup a trap to remove temp files
    # shellcheck disable=SC2064
    trap "rm -f '$_help'" INT QUIT ABRT TERM EXIT


    # use help2man instead
    if [ "$opt_help2man" = 'true' ]; then
        shift
        debug "Creating a temporary SHELL script to '%s' that will run the binary '%s'\n" \
            "$_help" "$_bin"
        cat > "$_help" <<ENDCAT
#!/bin/sh
$_bin "$@" \
|sed \
        -e 's/^\\([A-Z0-9_-][A-Z0-9_ -]*\\)$/*\1*/g' \
        -e "s/^$(__ 'USAGE')\$/$(__ 'SYNOPSIS')/g" \
        -e "s/^$(__ 'REPORTING BUGS')\$/$(__ 'BUGS')/g"
ENDCAT
        chmod +x "$_help"
        debug "Running '%s' on that SHELL SCRIPT with the following arguments: %s\n" \
            'help2man' "--no-info '$_help' $*"
        help2man --no-info "$_help" "$@"
        exit 0

    # not using help2man
    else

        # get the help of the program
        debug "Running the binary '%s' (locale: '%s') with the option '%s' "`
              `"and saving the output to '%s'\n" \
                  "$_bin" "$opt_locale" "$opt_help_option" "$_help"
        # shellcheck disable=SC2086
        if ! LANGUAGE='' LC_ALL="$opt_locale" LANG='' TEXTDOMAINDIR='' "$_bin" $opt_help_option > "$_help"; then
            __ "Fatal error: the binary '%s' exited with a non-zero value when asked for '%s'" \
                "$_bin" '--help' && exit 3
        fi
    fi

# using --file option
else
    _help="$1"

    if [ ! -r  "$_help" ]; then
        __ "Fatal error: file '%s' doesn't exist or is not readable" >&2 && exit 3
    fi
fi


# other arguments
prog_name="$2"
prog_version="$3"
man_section_num="$4"


# backup current values for translation
LANGUAGE_BAK="$LANGUAGE"
LC_ALL_BAK="$LC_ALL"
LANG_BAK="$LANG"

# enforce the language chosen, the time to do the translations
LANGUAGE=
LC_ALL="$opt_locale"
LANG=
export LANGUAGE
export LC_ALL
export LANG

# translate man section name
case "$man_section_num" in
    1) man_section_name="$(__ 'User commands')" ;;
    2) man_section_name="$(__ 'System calls')" ;;
    3) man_section_name="$(__ 'Subroutines')" ;;
    4) man_section_name="$(__ 'Devices')" ;;
    5) man_section_name="$(__ 'File format descriptions')" ;;
    6) man_section_name="$(__ 'Games')" ;;
    7) man_section_name="$(__ 'Miscellaneous')" ;;
    8) man_section_name="$(__ 'System administration tools')" ;;
    9) man_section_name="$(__ 'Kernel routine documentation')" ;;
    *) __ "Fatal error: invalid man page section number '%d'" "$man_section_num" && exit 3
esac

# translated section names
SECT_USAGE="$(__ 'USAGE')"
SECT_SYNOPSIS="$(__ 'SYNOPSIS')"
SECT_COMMANDS="$(__ 'COMMANDS')"
SECT_ARGUMENTS="$(__ 'ARGUMENTS')"
SECT_OPTIONS="$(__ 'OPTIONS')"
SECT_FILES="$(__ 'FILES')"
SECT_ENVIRONMENT="$(__ 'ENVIRONMENT')"
# shellcheck disable=SC2034
SECT_EXAMPLES="$(__ 'EXAMPLES')"
SECT_DIAGNOSTICS="$(__ 'DIAGNOSTICS')"
# shellcheck disable=SC2034
SECT_AUTHORS="$(__ 'AUTHORS')"
# shellcheck disable=SC2034
SECT_BUGS="$(__ 'BUGS')"
# shellcheck disable=SC2034
SECT_REPORTING_BUGS="$(__ 'REPORTING BUGS')"
# shellcheck disable=SC2034
SECT_COPYRIGHT="$(__ 'COPYRIGHT')"
# shellcheck disable=SC2034
SECT_SEE_ALSO="$(__ 'SEE ALSO')"

# translated alias
ALIAS="$(__ 'Alias')"

# restore the translation values
LANG="$LANG_BAK"
LC_ALL="$LC_ALL_BAK"
LANGUAGE="$LANGUAGE_BAK"
export LANGUAGE
export LC_ALL
export LANG


# shellcheck disable=SC2021
cat <<ENDCAT
.\" Process this file with
.\" groff -man -Tascii $(basename "$1")
.\"
.TH $(echo "$prog_name"|tr '[a-z]' '[A-Z]') "$man_section_num" "$(date '+%B %Y')" `
`"$prog_version" "$man_section_name"
ENDCAT
tabspace='    '
section=
aftersection=false
indent=0
IFS_BAK="$IFS"
IFS=
while read -r line; do
    debug "##### '%s'\n" "$line"
    if echo "$line" | grep -q '^[	 ]*$'; then
        if [ "$aftersection" = 'false' ]; then
            echo '.P' && debug '%s\n' '.P'
        fi
    elif echo "$line" | grep -q '^[A-Z0-9]'; then
        debug "prev section: '%s'\n" "$section"

        # if the section was the SYNOPSIS, close it
        if [ "$section" = "$SECT_USAGE" ] || [ "$section" = "$SECT_SYNOPSIS" ]; then
            debug 'closing SYNOPSIS command\n'
            echo '.YS'
        fi

        section="$line"
        debug " new section: '%s'\n" "$section"
        echo ".SH $section" && debug "%s\n" ".SH $section"
        echo '.SS ""' && debug "%s\n" '.SS ""'
        echo ".PP" && debug "%s\n" ".PP"
        indent=0
        aftersection=true
    else

        # turn spaces into tabulations
        line="$(echo "$line" | sed "/^\\($tabspace\\)\+./ s/$tabspace/\t/g")"
        debug "line: '%s'\n" "$line"

        # then count the number of tabulations as the indentation depth
        i="$(printf  '%s' "$line" | grep -o '^[	]\+' | tr -d '\n' | wc -c)"
        debug "indt: '%d'\n" "$indent"
        debug "   i: '%d'\n" "$i"

        # do not allow wrong indentation
        if [ "$i" -eq 0 ] && [ "$section" != '' ]; then
            echo "Fatal error: the following line should have indentation" >&2
            echo "> $line" >&2
            exit 3
        fi

        # try to mimic the indentation

        # special case when indentation don't change and it's not a tag
        if [ "$i" -eq "$indent" ] && [ "$i" -gt 1 ]; then
            debug 'no indent change, not a tag\n'
            echo ".RE" && debug '%s\n' ".RE"
            echo ".RS" && debug '%s\n' ".RS"
        fi

        # regular cases
        if [ "$i" -ne "$indent" ]; then

            # unindent
            new_indent="$indent"
            if [ "$i" -lt "$indent" ]; then
                debug 'unindent from %d to %d\n' "$indent" "$i"
                IFS="$IFS_BAK"
                for t in $(seq "$((i + 1))" "$indent"); do
                    debug 'unindent %d\n' "$((indent - $((t - i))))"
                    echo ".RE" && debug '%s\n' ".RE"
                done
                IFS=
                new_indent="$i"
            fi

            # indent
            if [ "$i" -ne 1 ]; then
                debug 'new indent: %d\n' "$new_indent"
                to_indent="$((i - new_indent))"

                if [ "$to_indent" -gt 0 ]; then
                    debug 'indent from %d to %d\n' "$new_indent" "$((new_indent + to_indent))"
                    #echo ".RS" && debug '%s\n' ".RS"
                    IFS="$IFS_BAK"
                    for t in $(seq "$((new_indent + 1))" "$((new_indent + to_indent))"); do
                        debug 'indent %d\n' "$t"
                        echo ".RS" && debug '%s\n' ".RS"
                    done
                    IFS=
                fi
            fi
        fi

        # now we can remove indentation from the line
        line="$(echo "$line" | sed 's/^\t*//g')"

        # escape dot dot
        line="$(echo "$line" | sed 's/^\.\(\.\+\)/\\\\[char46]\1/g')"

        # escape last backslash '\\'
        line="$(echo "$line" | sed 's/\\$/\\\\\\\\/g')"

        # first indentation special cases
        if [ "$i" -eq 1 ]; then
            debug 'first indent special case\n'

            # section using tags
            if is_section_using_tags "$section"; then
                debug 'section using tags\n'

                # if indentation hasn't changed and in section with potential multiple tags
                if [ "$i" -eq "$indent" ] &&
                   { [ "$section" = "$SECT_FILES" ] || [ "$section" = "$SECT_ENVIRONMENT" ] ; }
                then

                    # unindent (before beginning re-indented automatically)
                    debug 'unindent\n'
                    echo ".RE" && debug '%s\n' ".RE"
                fi

                # add italic for some sections
                if [ "$section" = "$SECT_FILES" ] || [ "$section" = "$SECT_ARGUMENTS" ]; then
                    debug 'italic is wanted for that section tag\n'
                    echo ".I" && debug '%s\n' ".I"
                fi

            # section not using tags
            else
                    debug 'unindent\n'
                    echo ".RE" && debug '%s\n' ".RE"
            fi
        fi

        # specific for section USAGE or SYNOPSIS
        if [ "$section" = "$SECT_USAGE" ] || [ "$section" = "$SECT_SYNOPSIS" ]; then
            debug 'section %s\n' "$section"

            # special case for command
            debug 'command line formatting\n'
            line="$(printf '.SY %s\n.R %s\n' \
                    "$(echo "$line" | awk '{print $1}')" \
                    "$(echo "$line" | awk '{$1=""; print $0}')")"

        # specific for section OPTIONS
        elif echo "$section" | grep -q "^$SECT_OPTIONS" && echo "$line" | grep -q '^ *-'; then
            debug 'section %s\n' "$section"

            debug 'adding option formatting\n'
            _opt="$(echo "$line" \
                    |sed 's/^ *\(-\([^ -] *\([,|] *--[^ -][^ ]\+\)\?\|-[^ -][^ ]\+\)\).*$/\1/g')"
            _arg="$(echo "$line" \
                    |sed 's/^ *\(-\([^ -] *\([,|] *--[^ -][^ ]\+\)\?\|-[^ -][^ ]\+\)\)\(.*\)$/\4/g')"
            if echo "$_opt" | grep -q '^-[^ -]$' && [ "$_arg" = '' ]; then
                debug "option is short with no argument (opt: '%s')\n" "$_opt"
                line="$(printf '.B "%s"\n' "$_opt")"
            else
                debug "option with an argument or long (opt: '%s', arg='%s')\n" \
                    "$_opt" "$_arg"
                line="$(printf '.BI "%s" "%s"\n' "$_opt" "$_arg")"
            fi

        # specific for section COMMANDS
        elif [ "$section" = "$SECT_COMMANDS" ]; then

            if echo "$line" | grep -q -i "^[ 	]*$ALIAS"; then
                debug "detected an alias => smaller font\n"
                echo ".SM" && debug '%s\n' ".SM"
            fi
        fi

        # print the line
        echo "$line"  && debug '%s\n' "$line"

        indent="$i"

        # special cases after a tag
        aftersection=false
    fi
done < "$_help"
