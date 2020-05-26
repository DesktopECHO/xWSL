# shellcheck shell=sh

# Expand $PATH to include the directory where snappy applications go.
system32_path="/mnt/c/Windows/System32"
if [ -n "${PATH##*${system32_path}}" -a -n "${PATH##*${system32_path}:*}" ]; then
    export PATH=$PATH:${system32_path}
fi

# Ensure base distro defaults xdg path are set if nothing filed up some
# defaults yet.
if [ -z "$XDG_DATA_DIRS" ]; then
    export XDG_DATA_DIRS="/usr/local/share:/usr/share"
fi

# Runlevel Hack
export RUNLEVEL=2

# Force indirect rendering
export LIBGL_ALWAYS_INDIRECT=1

