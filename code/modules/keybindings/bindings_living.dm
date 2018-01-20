/mob/living/key_down(_key, client/user)
	switch(_key)
		if("B")
			resist()
			return
		if("S")
			if(client.keys_held["Ctrl"])
				emote("scream")

	return ..()
