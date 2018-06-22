// Technically the client argument is unncessary here since that SHOULD be src.client but let's not assume things
// All it takes is one badmin setting their focus to someone else's client to mess things up
// Or we can have NPC's send actual keypresses and detect that by seeing no client

/mob/key_down(_key, client/user)
	switch(_key)
		if("Delete", "H")
			if(!pulling)
				to_chat(src, "<span class='notice'>You are not pulling anything.</span>")
			else
				stop_pulling()
			return
		if("Insert", "G")
			a_intent_change(INTENT_HOTKEY_RIGHT)
			return
		if("F")
			a_intent_change(INTENT_HOTKEY_LEFT)
			return
		if("X", "Northeast") // Northeast is Page-up
			swap_hand()
			return
		if("Y", "Z", "Southeast")	// Southeast is Page-down
			mode()					// attack_self(). No idea who came up with "mode()"
			return
		if("Q", "Northwest") // Northwest is Home
			var/obj/item/I = get_active_held_item()
			if(!I)
				to_chat(src, "<span class='warning'>You have nothing to drop in your hand!</span>")
			else
				dropItemToGround(I)
			return
		if("E")
			quick_equip()
			return
		if("Alt")
			toggle_move_intent()
			return
		//Bodypart selections
		if("Numpad8")
			user.body_toggle_head()
			return
		if("Numpad4")
			user.body_r_arm()
			return
		if("Numpad5")
			user.body_chest()
			return
		if("Numpad6")
			user.body_l_arm()
			return
		if("Numpad1")
			user.body_r_leg()
			return
		if("Numpad2")
			user.body_groin()
			return
		if("Numpad3")
			user.body_l_leg()
			return

	if(client.keys_held["Ctrl"])
		switch(SSinput.movement_keys[_key])
			if(NORTH)
				northface()
				return
			if(SOUTH)
				southface()
				return
			if(WEST)
				westface()
				return
			if(EAST)
				eastface()
				return
	return ..()

/mob/key_up(_key, client/user)
	switch(_key)
		if("Alt")
			toggle_move_intent()
			return
	return ..()