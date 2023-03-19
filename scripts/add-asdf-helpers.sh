#!/bin/bash

# ##############################################################################
#
# add-asdf-helpers.sh
#
# We add a custom function called `use` that will install a specific version of
# a language if it is not already installed and then set that version as the
# global version for that language.
#
# ##############################################################################

# Add executable file to /usr/local/bin with correct permissions
touch /usr/local/bin/use
chmod +x /usr/local/bin/use

# Start the file by loading the ASDF initialization steps
cat <<EOF >>/usr/local/bin/use
#!/bin/bash

# ##############################################################################
#
# load deps
#
# ##############################################################################

export ASDF_DIR=$ASDF_DIR
export ASDF_DATA_DIR=$ASDF_DATA_DIR
 
. $ASDF_DIR/asdf.sh

EOF

# Add and execute the custom use function to the file
cat <<'EOF' >>/usr/local/bin/use
# ##############################################################################
#
# use.sh
#
# A custom function called `use` that will install a specific version of a
# language if it is not already installed and then set that version as the
# global version for that language.
#
# ##############################################################################

function use() {
    if [[ "$#" -lt 2 ]]; then
        echo "Usage: use <language> <version>"
        return 1
    fi

    local language="$1"
    local version="$2"
    local resolved_version

    case "$language" in
        python) resolved_version="$(resolve_python_version "$version")" ;;
        nodejs) resolved_version="$(resolve_nodejs_version "$version")" ;;
        ruby) resolved_version="$(resolve_ruby_version "$version")" ;;
        go) resolved_version="$(resolve_golang_version "$version")" ;;
        *) echo "Unknown language: $language" ; return 1 ;;
    esac

    if ! asdf list "${language}" | grep -q "${resolved_version}"; then
        asdf install "${language}" "${resolved_version}" || return $?
    fi

    asdf global "${language}" "${resolved_version}" || return $?
}

# ##############################################################################
#
# utils (resolve versions for supported plugins)
#
# This uses the github api to resolve the latest version of a language that
# matches the partial version provided. This solution was chosen as it was the
# most consistent across all supported languages. It however may not be the most
# efficient solution. One other issue with it is the rate limit of the github
# api. This is not an issue for most users, but if you are using this script
# frequently you may run into issues.
#
# ##############################################################################

function resolve_python_version() {
    local version="$1"
    resolve_version "python/cpython" "$version"
}

function resolve_nodejs_version() {
    local version="$1"
    resolve_version "nodejs/node" "$version"
}

function resolve_ruby_version() {
    local version="$1"
    resolve_version "ruby/ruby" "$version"
}

function resolve_golang_version() {
    local version="$1"
    resolve_version "golang/go" "$version" "go"
}

function resolve_version() {
    local repo="$1"
    local version="$2"
    local tag_match="$3"

    tags="$(get_tags $repo $tag_match)"
    if [[ "$tags" =~ ^[[:space:]]*\[[[:space:]]*\][[:space:]]*$ ]]; then
        echo "No matching release found for version $partial_version" >&2
        return 1
    fi

    latest_matching_release="$(get_latest_matching_release $version "$tags")"
    if [ -n "$latest_matching_release" ]; then
        echo "$latest_matching_release"
        return 0
    else
        page=$((page + 1))
    fi

}

function get_tags() {
    local repo="$1"
    local tag_match="$2"

    curl -s -H "Accept: application/json" "https://api.github.com/repos/$repo/git/refs/tags/$tag_match"
}

function get_latest_matching_release() {
    local partial_version=$1
    local tags=$2

    # Extract tag names from the JSON array and remove the "refs/tags/" prefix
    tags=$(echo "$tags" | jq -r '.[].ref' | sed 's/^refs\/tags\///')

    # Replace non-period separators with periods and remove postfixes and prefixes from all tags
    tags=$(echo "$tags" | sed -E 's/(go|v)//' | tr '_-' '.' | sed -E 's/[a-zA-Z]+$//')

    # Construct regex pattern for matching tags
    local regex_pattern="^${partial_version//./\\.}[._-]?([0-9]+[._-]?){0,2}$"

    # Filter and sort matching tags
    echo "$tags" | grep -E "$regex_pattern" | sort -Vr | head -n1
}

# ##############################################################################
#
# execute
#
# ##############################################################################

use "$@"

EOF
