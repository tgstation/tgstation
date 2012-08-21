/obj/item/device/radio/intercom
	name = "station intercom"
	desc = "Talk through this."
	icon_state = "intercom"
	anchored = 1
	w_class = 4.0
	canhear_range = 4
	var/number = 0
	var/anyai = 1
	var/mob/living/silicon/ai/ai = list()

/obj/item/device/radio/intercom/New()
	spawn(5)
		checkpower()
	..()

/obj/item/device/radio/intercom/attack_ai(mob/user as mob)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/attack_paw(mob/user as mob)
	return src.attack_hand(user)


/obj/item/device/radio/intercom/attack_hand(mob/user as mob)
	src.add_fingerprint(user)
	spawn (0)
		attack_self(user)

/obj/item/device/radio/intercom/receive_range(freq, level)
	if (!on)
		return 0
	if (!(src.wires & WIRE_RECEIVE))
		return 0
	var/turf/position = get_turf(src)
	if(isnull(position) || position.z != level)
		return 0
	if (!src.listening)
		return 0
	if(freq == SYND_FREQ)
		if(!(src.syndie))
			return 0//Prevents broadcast of messages over devices lacking the encryption

	return canhear_range


/obj/item/device/radio/intercom/hear_talk(mob/M as mob, msg)
	if(!src.anyai && !(M in src.ai))
		return
	..()

/obj/item/device/radio/intercom/proc/checkpower()

	// Simple loop, checks for power. Strictly for intercoms
	while(src)

		if(!src.loc)
			on = 0
		else
			var/area/A = src.loc.loc
			if(!A || !isarea(A) || !A.master)
				on = 0
			else
				on = A.master.powered(EQUIP) // set "on" to the power status

		if(!on)
			icon_state = "intercom-p"
		else
			icon_state = "intercom"

		sleep(30)