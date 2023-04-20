///Returns whether or not a player is a guest using their ckey as an input
/proc/is_guest_key(key)
	if(findtext(key, "Guest-", 1, 7) != 1) //was findtextEx
		return FALSE

	var/i, ch, len = length(key)

	for(i = 7, i <= len, ++i) //we know the first 6 chars are Guest-
		ch = text2ascii(key, i)
		if (ch < 48 || ch > 57) //0-9
			return FALSE
	return TRUE

/client/proc/is_localhost()
	var/static/list/localhost_addresses = list("localhost", "127.0.0.1", "::1")
	return (src.address in localhost_addresses)
