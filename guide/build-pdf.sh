#!/usr/bin/env bash
#
# Build each guide markdown as a PDF without modifying the source files.
# Pipeline: <guide>.md -> sed (normalise unicode) -> pandoc -> PDF
#
# Only pdflatex is available on this machine (no xelatex/lualatex), so the
# sed pass substitutes the unicode characters pdflatex's default fonts
# cannot render into ASCII / LaTeX-friendly equivalents.

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Guides: SRC_BASENAME : TITLE
declare -a GUIDES=(
    "README:Bare-metal MKR1000: a self-guided course"
    "rtos:Adding an RTOS to your MKR1000: a self-guided course"
    "linux:Embedded Linux and Yocto: a self-guided course"
)

normalise() {
    sed \
        -e 's/\xe2\x80\x94/ -- /g' \
        -e 's/\xe2\x80\x93/ - /g' \
        -e 's/\xe2\x86\x92/->/g' \
        -e 's/\xe2\x86\x90/<-/g' \
        -e 's/\xc2\xb2/2/g' \
        -e 's/\xc2\xa0/ /g' \
        -e "s/\xe2\x80\x98/'/g" \
        -e "s/\xe2\x80\x99/'/g" \
        -e 's/\xe2\x80\x9c/"/g' \
        -e 's/\xe2\x80\x9d/"/g' \
        -e 's/\xe2\x80\xa6/.../g' \
        -e 's/\xc2\xb7/*/g' \
        -e 's/\xe2\x80\xa2/*/g' \
        -e 's/\xe2\x89\x88/~/g' \
        -e 's/\xc3\x97/x/g' \
        -e 's/\xc2\xb0/ deg /g' \
        -e 's/\xce\xa9/ Ohm/g' \
        -e 's/\xc2\xb5/u/g' \
        -e 's/\xe2\x94\x9c/+/g' \
        -e 's/\xe2\x94\x80/-/g' \
        -e 's/\xe2\x94\x82/|/g' \
        -e 's/\xe2\x94\x94/+/g' \
        -e 's/\xe2\x94\x8c/+/g' \
        -e 's/\xe2\x94\x90/+/g' \
        -e 's/\xe2\x94\xac/+/g' \
        -e 's/\xe2\x94\xb4/+/g' \
        -e 's/\xe2\x94\xbc/+/g' \
        "$1"
}

build_one() {
    local base="$1"
    local title="$2"
    local src="${HERE}/${base}.md"
    local outname

    case "${base}" in
        README) outname="mkr1000-baremetal-course.pdf" ;;
        rtos)   outname="mkr1000-rtos-course.pdf" ;;
        linux)  outname="mkr1000-linux-yocto-course.pdf" ;;
        *)      outname="${base}.pdf" ;;
    esac
    local out="${HERE}/${outname}"

    if [[ ! -f "${src}" ]]; then
        echo "skip: ${src} not found" >&2
        return
    fi

    normalise "${src}" \
    | pandoc \
        --from markdown-smart \
        --to pdf \
        --pdf-engine=pdflatex \
        --toc \
        --toc-depth=2 \
        --number-sections \
        -V geometry:margin=2cm \
        -V documentclass=article \
        -V linkcolor=blue \
        -V urlcolor=blue \
        -V toccolor=black \
        -V fontsize=11pt \
        --metadata title="${title}" \
        --metadata author="Christoph Ungricht" \
        -o "${out}"

    echo "Wrote ${out}"
}

# If args given, build only those bases; otherwise build all.
if (( $# > 0 )); then
    for arg in "$@"; do
        for entry in "${GUIDES[@]}"; do
            base="${entry%%:*}"
            title="${entry#*:}"
            if [[ "${base}" == "${arg}" ]]; then
                build_one "${base}" "${title}"
            fi
        done
    done
else
    for entry in "${GUIDES[@]}"; do
        base="${entry%%:*}"
        title="${entry#*:}"
        build_one "${base}" "${title}"
    done
fi
