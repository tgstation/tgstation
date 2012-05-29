//Blocks an attempt to connect before even creating our client datum thing.
world/IsBanned(key,address,computer_id)
    //Guest Checking
	if( !guests_allowed && IsGuestKey(key) )
		log_access("Failed Login: [key] - Guests not allowed")
		message_admins("\blue Failed Login: [key] - Guests not allowed")
		return list("reason"="guest", "desc"="\nReason: Guests not allowed.brb")

	//Ban Checking
	. = CheckBan( ckey(key), computer_id, address )
	if(.)
		log_access("Failed Login: [key] [computer_id] [address] - Banned [.["reason"]]")
		message_admins("\blue Failed Login: [key] [computer_id] [address] - Banned [.["reason"]]")
		return .

	return ..()	//default pager ban stuff
