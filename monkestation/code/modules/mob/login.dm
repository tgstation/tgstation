/mob/Login()
	. = ..()
	if(!. || QDELETED(client))
		return FALSE

	if(QDELETED(client?.patreon))
		client?.patreon = new(client)

	if(QDELETED(client?.twitch))
		client?.twitch = new(client)

	if(QDELETED(client?.client_token_holder))
		client?.client_token_holder = new(client)
