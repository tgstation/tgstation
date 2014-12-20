// Technically the client argument is unncessary here since that SHOULD be src.client but let's not assume things
// All it takes is one badmin setting their focus to someone else's client to mess things up
// Looking at you mrglasses. Also you hornygranny

/mob/key_down(key, client/user)

	switch(key)
		if("delete")
			if(!pulling)
				src << "<span class='notice'>You are not pulling anything.</span>"
			else
				stop_pulling()

		if("numpad5") //Why isn't this resist?
			if(isobj(loc))
				var/obj/O = loc
				if(canmove)
					O.relaymove(src, 16)

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
		//if("numpad7", "q") // dropping items, in both bindings_robot.dm and bindings_carbon.dm
		//if("numpad1", "r") //throw mode, in bindings_carbon.dm

	if(client.keys_active["ctrl"])
		switch(movement_keys[key])
			if(NORTH)
				northface()
			if(SOUTH)
				southface()
			if(WEST)
				westface()
			if(EAST)
				eastface()

	return ..()