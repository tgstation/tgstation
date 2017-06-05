GLOBAL_LIST_EMPTY(mentorlog)
GLOBAL_PROTECT(mentorlog)
GLOBAL_VAR_INIT(ip_address, HTTPSGet("https://api.ipify.org/"))
GLOBAL_PROTECT(ip_address)