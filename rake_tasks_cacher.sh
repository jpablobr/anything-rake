#!/bin/sh

set -e

prgm=$(basename $0)
tmp_fl=".rake_tasks~"

usage() {
    cat <<EOT

usage: $prgm optional [-h] [-e TASK] [-p PATH] [-g GREP]

see also: grep(1)

EOT
    exit 0
}

invalid_option() {
    cat <<EOT

$(tput setaf 1)"$1" $(tput op) is not a valid option.
$(usage)
EOT
    die
}

die() {
    echo 1>&2 "$1"
    exit 1
}

execute_task() {
    rake_command "$1"
    exit
}

rake_command() {
    if [ -f "Gemfile" ]; then
        bundle exec rake "$1"
    else
        rake "$1"
    fi
}

grep_tasks() {
    grep "$1" $tmp_fl | cut -c 6-
}

find_rake_file() {
    cd $1
    if [ -f "Rakefile" ]; then
        local rk_fls="$tmp_fl Rakefile **/*.rake Gemfile.lock"
        local rcnt=$(ls -t $rk_fls 2>/dev/null | head -n 1)
        if [ "$rcnt" = $tmp_fl ]; then
            grep_tasks "$2"; exit
        else
            if $(rake_command "-T" >$tmp_fl); then
                grep_tasks "$2"; exit
            else
                grep_tasks "$2"
                rm -f $tmp_fl
                die "Rake task failed"
            fi
        fi
    else
        die "No Rakefile found"
    fi
}

[ $# -gt 0 -a "$1" != "-e" ] && {
    echo "$1" | grep -q '^-' || invalid_option $*
}

[ "$1" = "--help" ] && usage

[ -f ~/.rvm/scripts/rvm ] && {
    source ~/.rvm/scripts/rvm >/dev/null
    [ -f $(pwd -P)/.rvmrc ] && {
        source $(pwd -P)/.rvmrc >/dev/null
    }
}

while getopts "he:p:g:" opt; do
    case $opt in
        p ) [ -d $OPTARG ] || die "$OPTARG is not a directory."
            tasks_path=$OPTARG
            ;;
        g ) grep_for=$OPTARG
            ;;
        e ) execute_task $OPTARG
            ;;
        h ) usage
            ;;
        * ) usage
    esac
done

find_rake_file ${tasks_path:=.} ${grep_for:=''}
:
