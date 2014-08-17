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
			user << "<span class='info'>Error: Device out of range of station communication arrays.</span>"
			return

		if(emergency_shuttle.location==0)
			if (emergency_shuttle.online)
				recalling = 1
				user << "<span class='info'>Generating shuttle recall order with codes retrieved from last call signal...</span>"
				sleep(10)
				user << "<span class='info'>Shuttle recall order generated.</span>"
				sleep(5)
				user << "<span class='info'>Accessing station long-range communication arrays...</span>"
				sleep(10)
				user << "<span class='info'>Comm arrays accessed.</span>"
				sleep(5)
				user << "<span class='info'>Broadcasting recall signal...</span>"
				sleep(20)
				recalling = 0
				if(!cancel_call_proc(user))
					user << "<span class='info'>No response recieved. Emergency shuttle cannot be recalled at this time.</span>"
				return

		user << "<span class='info'>Emergency shuttle cannot be recalled at this time.</span>"