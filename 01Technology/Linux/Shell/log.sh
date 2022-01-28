log() { # classic logger
    local prefix=$(date "+%Y-%m-%d %H:%M:%S")
    echo "${prefix} $@" >&2
}

log "INFO" "a message"
