#!/usr/bin/env bash
set -u

if [[ -n "${YAZI_ORIG_WAYLAND_DISPLAY-}" ]]; then
    export WAYLAND_DISPLAY="$YAZI_ORIG_WAYLAND_DISPLAY"
fi

if [[ -n "${YAZI_ORIG_DISPLAY-}" ]]; then
    export DISPLAY="$YAZI_ORIG_DISPLAY"
fi

if [[ -n "${YAZI_ORIG_XDG_SESSION_TYPE-}" ]]; then
    export XDG_SESSION_TYPE="$YAZI_ORIG_XDG_SESSION_TYPE"
fi

is_image() {
    local path="$1"
    local ext="${path##*.}"
    ext="${ext,,}"

    case "$ext" in
        png|jpg|jpeg|gif|bmp|webp|avif|heic|heif|tif|tiff|svg)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

is_pdf() {
    local path="$1"
    local ext="${path##*.}"
    ext="${ext,,}"
    [[ "$ext" == "pdf" ]]
}

launch_images() {
    local -a images=("$@")
    if command -v sxiv >/dev/null 2>&1; then
        sxiv "${images[@]}" >/dev/null 2>&1 &
        return 0
    fi

    if command -v kitty >/dev/null 2>&1 && command -v sxiv >/dev/null 2>&1; then
        kitty --detach sxiv "${images[@]}" >/dev/null 2>&1 &
        return 0
    fi

    return 1
}

launch_pdfs() {
    local -a pdfs=("$@")
    if command -v zathura >/dev/null 2>&1; then
        zathura "${pdfs[@]}" >/dev/null 2>&1 &
        return 0
    fi

    if command -v kitty >/dev/null 2>&1 && command -v zathura >/dev/null 2>&1; then
        kitty --detach zathura "${pdfs[@]}" >/dev/null 2>&1 &
        return 0
    fi

    return 1
}

# rm /tmp/_yazi_test_*
# echo "$@" > /tmp/_yazi_test_$(date +%s).txt

hovered="${1-}"
if [[ $# -gt 0 ]]; then
    shift
fi

declare -a candidates=()
if [[ $# -gt 0 ]]; then
    candidates=("$@")
elif [[ -n "$hovered" ]]; then
    candidates=("$hovered")
else
    exit 0
fi

declare -A seen=()
declare -a images=()
declare -a pdfs=()

if [[ -n "$hovered" ]] && is_image "$hovered"; then
    images+=("$hovered")
    seen["$hovered"]=1
fi

for path in "${candidates[@]}"; do
    if is_image "$path"; then
        if [[ -z "${seen[$path]-}" ]]; then
            images+=("$path")
            seen["$path"]=1
        fi
    elif is_pdf "$path"; then
        pdfs+=("$path")
    fi
done

if [[ ${#images[@]} -gt 0 ]]; then
    launch_images "${images[@]}"
    exit 0
fi

if [[ ${#pdfs[@]} -gt 0 ]]; then
    launch_pdfs "${pdfs[@]}"
fi

exit 0
