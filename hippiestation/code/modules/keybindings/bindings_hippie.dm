/mob/key_down(_key, client/user)
	if(client.keys_held["Shift"])
		switch(_key)
			if("F")
				emote("fart")
				return
			if("S")
				emote("scream")
				return
	return ..()
