/obj/item/device/codebreaker
	name = "\improper code breaker"
	desc = "Can be used to decipher a Nuclear Bomb's activation code"
	icon_state = "codebreaker"
	item_state = "electronic"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	m_amt = 50
	g_amt = 20
	w_type = RECYK_ELECTRONIC
	melt_temperature = MELTPOINT_SILICON
	origin_tech = "magnets=3;programming=6;syndicate=7"
	slot_flags = SLOT_BELT
	var/operation = 0

/obj/item/device/codebreaker/afterattack(obj/machinery/nuclearbomb/O, mob/living/carbon/user)
	if(istype(O) && (operation == 0))
		operation = 1
		icon_state = "codebreaker-working"
		user << "<span class='notice'>Stand still and keep the code breaker in your hands while it cracks the Nuclear Device's activation code.</span>"
		var/turf/T1 = get_turf(user)
		var/turf/T2 = get_turf(O)
		var/crackduration = rand(100,300)
		var/delayfraction = round(crackduration/6)

		for(var/i = 0, i<6, i++)
			sleep(delayfraction)
			if(!user || user.stat || user.weakened || user.stunned || !(user.loc == T1) || !(O.loc == T2) || (!(user.l_hand == src) && !(user.r_hand == src)))
				user << "<span class='warning'>You need to stand still for the whole duration of the code breaking for the device to work, and keep it in one of your hands.</span>"
				icon_state = "codebreaker"
				operation = 0
				return

		icon_state = "codebreaker-found"
		playsound(src, 'sound/machines/info.ogg', 50, 1)
		user << "It worked! The code is \"[O.r_code]\"."
		spawn(20)
			icon_state = "codebreaker"
			operation = 0
