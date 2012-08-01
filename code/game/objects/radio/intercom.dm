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


	attack_ai(mob/user as mob)
		src.add_fingerprint(user)
		spawn (0)
			attack_self(user)

	attack_paw(mob/user as mob)
		if ((ticker && ticker.mode.name == "monkey"))
			return src.attack_hand(user)


	attack_hand(mob/user as mob)
		src.add_fingerprint(user)
		spawn (0)
			attack_self(user)


	send_hear(freq, level)
		var/range = receive_range(freq, level)
		if(range > 0)
			return get_mobs_in_view(canhear_range, src)

	receive_range(freq, level)
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


	hear_talk(mob/M as mob, msg)
		if(!src.anyai && !(M in src.ai))
			return
		..()