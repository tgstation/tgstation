// Technically the client argument is unncessary here since that SHOULD be src.client but let's not assume things
// All it takes is one badmin setting their focus to someone else's client to mess things up
// Or we can have NPC's send actual keypresses and detect that by seeing no client

/mob/key_down(datum/keyinfo/I, client/user)
	switch(I.action)
		if(ACTION_SAY)
			get_say()
			return
		if(ACTION_ME)
			me_verb()
			return
		if(ACTION_STOPPULLING)
			if(!pulling)
				to_chat(src, "<span class='notice'>You are not pulling anything.</span>")
			else
				stop_pulling()
			return
		if(ACTION_INTENTRIGHT)
			a_intent_change(INTENT_HOTKEY_RIGHT)
			return
		if(ACTION_INTENTLEFT)
			a_intent_change(INTENT_HOTKEY_LEFT)
			return
		if(ACTION_SWAPHAND)
			swap_hand()
			return
		if(ACTION_USESELF)
			mode()					// attack_self(). No idea who came up with "mode()"
			return
		if(ACTION_DROP)
			var/obj/item/T = get_active_held_item()
			if(!T)
				to_chat(src, "<span class='warning'>You have nothing to drop in your hand!</span>")
			else
				dropItemToGround(T)
			return
		if(ACTION_EQUIP)
			quick_equip()
			return

		//Bodypart selections
		if(ACTION_TARGETHEAD)
			user.body_toggle_head()
			return
		if(ACTION_TARGETRARM)
			user.body_r_arm()
			return
		if(ACTION_TARGETCHEST)
			user.body_chest()
			return
		if(ACTION_TARGETLARM)
			user.body_l_arm()
			return
		if(ACTION_TARGETRLEG)
			user.body_r_leg()
			return
		if(ACTION_TARGETGROIN)
			user.body_groin()
			return
		if(ACTION_TARGETLLEG)
			user.body_l_leg()
			return

	return ..()

/mob/keyLoop(client/user)
	if(user.prefs.bindings.isheld_key("Ctrl"))
		var/list/keys = SSinput.movement_arrows + user.prefs.bindings.movement_keys
		var/dir = NONE
		for(var/_key in user.prefs.bindings.keys_held)
			dir = keys[_key]

		switch(dir)
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

/mob/proc/get_say()
	var/msg = input(src, null, "say \"text\"") as text|null
	say_verb(msg)
