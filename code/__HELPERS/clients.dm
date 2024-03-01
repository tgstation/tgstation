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

/// Ensures that the client has been fully initialized via New(), and can't somehow execute actions before that. Security measure.
/// Will return false if the client is not fully initialized and send an error out. True otherwise.
/proc/validate_client(client/target)
	. = FALSE
	if(target.fully_created)
		return TRUE

	to_chat(target, span_warning("You are not fully initialized yet! Please wait a moment."))
	log_access("Client [key_name(target)] attempted to execute a verb before being fully initialized.")
	return FALSE
