GLOBAL_LIST_EMPTY(mentorlog)
GLOBAL_PROTECT(mentorlog)
GLOBAL_VAR_INIT(ip_address, _get_the_ip())
GLOBAL_PROTECT(ip_address)

/proc/_get_the_ip()
	GLOB.valid_HTTPSGet = TRUE
	var/ip = HTTPSGet("https://api.ipify.org/")
	return ip