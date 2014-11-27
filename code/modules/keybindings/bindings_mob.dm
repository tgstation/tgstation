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

		if("center") //Why isn't this resist?
			if(isobj(loc))
				var/obj/O = loc
				if(canmove)
					O.relaymove(src, 16)

		if("insert", "g")
			a_intent_change("right")
		if("f")
			a_intent_change("left")

		if("t")
			send_to_input("say")

		if("north","w")
			if(client.keys_active["ctrl"])
				northface()
		if("south", "s")
			if(client.keys_active["ctrl"])
				southface()
		if("west", "a")
			if(client.keys_active["ctrl"])
				westface()
		if("east", "d")
			if(client.keys_active["ctrl"])
				eastface()
		if("northeast", "x")
			swap_hand()
		if("southeast", "y", "z") // attack_self(). No idea who came up with "mode()"
			mode()
		//if("northwest", "q") // dropping items, in both bindings_robot.dm and bindings_carbon.dm
		//if("soutwest", "r") //throw mode, in bindings_carbon.dm

	return ..()