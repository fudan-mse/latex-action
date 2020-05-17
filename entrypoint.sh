#!/bin/sh

set -e

info() {
  echo -e "\033[1;34m$1\033[0m"
}

warn() {
  echo "::warning :: $1"
}

error() {
  echo "::error :: $1"
  exit 1
}

root_file="$1"
working_directory="$2"
compiler="$3"
args="$4"
extra_packages="$5"
extra_system_packages="$6"
pre_compile="$7"
post_compile="$8"

if [ -z "$root_file" ]; then
  error "Input 'root_file' is missing."
fi

if [ -z "$compiler" ] && [ -z "$args" ]; then
  warn "Input 'compiler' and 'args' are both empty. Reset them to default values."
  compiler="latexmk"
  args="-pdf -file-line-error -interaction=nonstopmode"
fi

if [ -n "$extra_system_packages" ]; then
  for pkg in $extra_system_packages; do
    info "Install $pkg by apk"
    apk --no-cache add "$pkg"
  done
fi

if [ -n "$extra_packages" ]; then
  for pkg in $extra_packages; do
    echo "Installing $pkg by tlmgr"
    tlmgr install "$pkg"
  done
fi

if [ -n "$working_directory" ]; then
  cd "$working_directory"
  echo "switched to $working_directory"
fi

if [ -z "$working_directory" ]; then
  cd "$PWD"
  echo "switched to $PWD"
fi

if [ ! -f "$root_file" ]; then
  error "File '$root_file' cannot be found from the directory '$PWD'."
  echo "files here:"
  ls | echo
fi

if [ -n "$pre_compile" ]; then
  info "Run pre compile commands"
  eval "$pre_compile"
fi

echo "$root_file" | while IFS= read -r f; do
  if [ -z "$f" ]; then
    continue
  fi

  info "Compile $f"

  if [ ! -f "$f" ]; then
    error "File '$f' cannot be found from the directory '$PWD'."
  fi

  # shellcheck disable=SC2086
  "$compiler" $args "$f"
done

if [ -n "$post_compile" ]; then
  info "Run post compile commands"
  eval "$post_compile"
fi
