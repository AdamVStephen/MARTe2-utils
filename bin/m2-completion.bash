#!/usr/bin/env bash
#
# Bash completion support for m2 top level execution script.
#
# Ideas to implement : m2ls with completions based on MARTe2_CONFIGPATH

# REF : https://stackoverflow.com/questions/57426500/list-directories-at-a-specific-path-as-autocomplete-options-for-a-bash-script
# The following stackoverflow answer falls down on the underscore functions not being recognised : TO FIX

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
#SETENV_SCRIPT_PATH="$SCRIPT_DIR/setenv.sh"
source "${SCRIPT_DIR}/m2lib"

export MARTe2_CONFIG_PATH=${MARTe2_ACTIVE_PROJECT}/Configurations

_configs()
{
	local cfgs cur
	# Better Shell Scripts Tip
	# Manual composition
	# cfgs=$(find ${MARTe2_CONFIG_PATH} -type f -name "*.cfg" | while read f; do echo $(basename $f); done)
	# cur=${COMP_WORDS[COMP_CWORD]}
	# COMPREPLY=( $(compgen -W "$cfgs" -- ${cur}) )
	#
	# ChatGPT is more elegant
        COMPREPLY=(
            $(compgen -W "$(find ${MARTe2_CONFIG_PATH} -type f -name '*.cfg')" -- "$cur")
        )
	return 0
}

for utility in m2check m2db m2edit m2grep m2ioc m2less m2ls m2ps m2states
do
	complete -F _configs "${utility}"
done

# Dynamic bash completion to help selection from available RealTimeStates

_basic_m2_completion() {
    local cur prev cfg
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # First argument: complete .cfg files
    if (( COMP_CWORD == 1 )); then
        COMPREPLY=(
            $(compgen -W "$(find ${MARTe2_CONFIG_PATH} -type f -name '*.cfg')" -- "$cur")
        )
        return
    fi

    # After the cfg filename, complete RealTimeState names from it
    cfg="${COMP_WORDS[1]}"

    if [[ -f "$cfg" ]]; then
        COMPREPLY=(
            $(compgen -W "$(_find_realtime_states "$cfg")" -- "$cur")
        )
    fi
}

_better_m2_completion() {
    local cur cfg
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"

    case "$COMP_CWORD" in
        1)
            # cfg filename
            mapfile -t COMPREPLY < <(
                compgen -W "$(find "$MARTe2_CONFIG_PATH" -type f -name '*.cfg')" -- "$cur"
            )
            ;;

        2)
            # RealTimeState within selected cfg
            cfg="${COMP_WORDS[1]}"

            [[ -f "$cfg" ]] || return

            mapfile -t COMPREPLY < <(
                compgen -W "$(_find_realtime_states "$cfg")" -- "$cur"
            )
            ;;
    esac
}

_best_m2_completion() {
    local cur prev cfg
    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Assume cfg is first positional argument.
    cfg="${COMP_WORDS[1]}"

    case "$prev" in
        -s)
            [[ -f "$cfg" ]] || return

            mapfile -t COMPREPLY < <(
                compgen -W "$(_find_realtime_states "$cfg")" -- "$cur"
            )
            return
            ;;

        -m)
            [[ -f "$cfg" ]] || return

            mapfile -t COMPREPLY < <(
                compgen -W "$(_find_messages "$cfg")" -- "$cur"
            )
            return
            ;;
    esac

    # First argument: cfg file
    if (( COMP_CWORD == 1 )); then
        mapfile -t COMPREPLY < <(
            compgen -W "$(find "$MARTe2_CONFIG_PATH" -type f -name '*.cfg')" -- "$cur"
        )
        return
    fi

    # Otherwise offer m2 options
    COMPREPLY=(
        $(compgen -W "-s -m" -- "$cur")
    )
}

_awesome_m2_cfg_completion()
{
    local cur rel_dir partial abs_dir
    local entry name candidate

    cur="${COMP_WORDS[COMP_CWORD]}"

    # Split the partially entered path into:
    #
    #   Machines/MASTU/PC
    #
    # rel_dir = Machines/MASTU/
    # partial = PC

    if [[ "$cur" == */* ]]; then
        rel_dir="${cur%/*}/"
        partial="${cur##*/}"
    else
        rel_dir=""
        partial="$cur"
    fi

    abs_dir="${MARTe2_CONFIG_PATH}/${rel_dir}"

    [[ -d "$abs_dir" ]] || return

    COMPREPLY=()

    #
    # Examine immediate children of the current directory.
    #
    for entry in "$abs_dir"*; do

        [[ -e "$entry" ]] || continue

        name="${entry##*/}"

        # Respect what the user has typed so far.
        [[ "$name" == "$partial"* ]] || continue

        if [[ -d "$entry" ]]; then

            # Only expose this directory if there is at least
            # one .cfg file somewhere beneath it.
            if find "$entry" -type f -name '*.cfg' -print -quit |
                    grep -q .; then

                candidate="${rel_dir}${name}/"
                COMPREPLY+=("$candidate")
            fi

        elif [[ -f "$entry" && "$name" == *.cfg ]]; then

            candidate="${rel_dir}${name}"
            COMPREPLY+=("$candidate")
        fi
    done

    #
    # Don't append a space after directory completions.
    # This lets the next TAB descend naturally into it.
    #
    if ((${#COMPREPLY[@]})); then
        local reply

        for reply in "${COMPREPLY[@]}"; do
            if [[ "$reply" == */ ]]; then
                compopt -o nospace
                break
            fi
        done
    fi
}

_awesome_m2_completion()
{
    local cur prev cfg

    COMPREPLY=()

    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    #
    # First argument: navigate the configuration tree.
    #
    if (( COMP_CWORD == 1 )); then
        _awesome_2_cfg_completion
        return
    fi

    #
    # The first argument is now our selected configuration.
    #
    cfg="${MARTe2_CONFIG_PATH}/${COMP_WORDS[1]}"

    case "$prev" in

        -s)
            [[ -f "$cfg" ]] || return

            mapfile -t COMPREPLY < <(
                compgen -W "$(_find_realtime_states "$cfg")" -- "$cur"
            )
            ;;

        -m)
            [[ -f "$cfg" ]] || return

            mapfile -t COMPREPLY < <(
                compgen -W "$(_find_messages "$cfg")" -- "$cur"
            )
            ;;

        *)
            mapfile -t COMPREPLY < <(
                compgen -W "-s -m" -- "$cur"
            )
            ;;
    esac
}

complete -F _awesome_m2_completion m2

_epicsdbs()
{
	local dbs cur
	dbs=$(ls -1 ${MARTe2_CONFIG_PATH}/*.db| while read f; do echo $(basename $f); done)
	cur=${COMP_WORDS[COMP_CWORD]}
	COMPREPLY=( $(compgen -W "$dbs" -- ${cur}) )
	return 0
}
#} && complete -o nospace -F _configs m2} && complete -o nospace -F _configs m2

complete -F _epicsdbs m2ioc

# Tacking on an extra function to give cd like semantics
#function m2cd() {
#	export MARTe2_ACTIVE_PROJECT_LAST=$MARTe2_ACTIVE_PROJECT
#        export MARTe2_ACTIVE_PROJECT="$PWD"
#}





