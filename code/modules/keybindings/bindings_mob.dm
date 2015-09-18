// Technically the client argument is unncessary here since that SHOULD be src.client but let's not assume things
// All it takes is one badmin setting their focus to someone else's client to mess things up
// Or we can have NPC's send actual keypresses and detect that by seeing no client

/mob/keyDown(key, client/user)

	switch(key)
		if("delete")
			if(!pulling)
				src << "<span class='notice'>You are not pulling anything.</span>"
			else
				stop_pulling()
		if("insert", "g")
			a_intent_change("right")
		if("f")
			a_intent_change("left")
		if("t")
			say_verb()
		if("numpad9", "x")
			swap_hand()
		if("numpad3", "y", "z") // attack_self(). No idea who came up with "mode()"
			mode()

	if(client.keys_held["ctrl"])
		switch(movement_keys[key])
			if(NORTH)
				northface()
			if(SOUTH)
				southface()
			if(WEST)
				westface()
			if(EAST)
				eastface()
	..()