//Recaller device
//Allows gang leaders to recall the shuttle
/obj/item/device/recaller
	name = "suspicious device"
	desc = "A strange device of sorts. Hard to really make out what it actually does just by looking."
	icon_state = "recaller"
	item_state = "walkietalkie"
	throwforce = 0
	w_class = 1.0
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	var/recalling = 0

/obj/item/device/recaller/attack_self(mob/user)
	if(recalling)
		return
	if((user.mind in ticker.mode.A_bosses) || (user.mind in ticker.mode.B_bosses))
		var/turf/userturf = get_turf(user)
		if(userturf.z != 1)
			user << "<span class='info'>\icon[src]Error: Device out of range of station communication arrays.</span>"
			return

		switch(SSshuttle.emergency.mode)
			if(SHUTTLE_CALL)
				recalling = 1
				loc << "<span class='info'>\icon[src]Generating shuttle recall order with codes retrieved from last call signal...</span>"
				sleep(rand(10,30))
				loc << "<span class='info'>\icon[src]Shuttle recall order generated. Accessing station long-range communication arrays...</span>"
				sleep(rand(10,30))
				loc << "<span class='info'>\icon[src]Comm arrays accessed. Broadcasting recall signal...</span>"
				sleep(rand(10,30))
				recalling = 0
				log_game("[key_name(user)] has recalled the shuttle with a recaller.")
				message_admins("[key_name_admin(user)] has recalled the shuttle with a recaller.", 1)
				if(!SSshuttle.cancelEvac(user))
					loc << "<span class='info'>\icon[src]No response recieved. Emergency shuttle cannot be recalled at this time.</span>"
				return

		user << "<span class='info'>\icon[src]Emergency shuttle cannot be recalled at this time.</span>"