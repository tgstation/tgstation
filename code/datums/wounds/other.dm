// stubbed toe (for when the captain needs to justify a shuttle call)
/datum/wound/brute/stubbed_toe
	name = "Stubbed Toe"
	desc = "Patient's large toe has been mildly bruised, resulting in moderate discomfort and an extreme need to abandon their post."
	treat_text = "Firm application of Space Law manual to patient or pressing a gun up to patient's head to remind them of their duties."
	examine_desc = "is slightly stubbed"
	occur_text = "bonks into a nearby object, injuring its big toe"
	sound_effect = 'sound/effects/crack1.ogg'
	wound_type = WOUND_TYPE_SPECIAL
	viable_zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	treatable_by = list(/obj/item/gun, /obj/item/book/manual/wiki/security_space_law) // IF YOU WILL NOT SERVE IN COMBAT, YOU WILL SERVE ON THE FIRING LINE
	severity = WOUND_SEVERITY_TRIVIAL

/datum/wound/brute/stubbed_toe/try_treating(obj/item/I, mob/user)
	if(istype(I, /obj/item/book/manual/wiki/security_space_law))
		if(user == victim)
			user.visible_message("<span class='notice'>[user] helpfully reminds [victim.p_them()]self of the punishment for gross deriliction of duty by studying [I], curing [victim.p_their()] stubbed toe!</span>", \
			"<span class='nicegreen'>You helpfully remind yourself of the punishment for gross deriliction of duty by studying [I], curing your stubbed toe!</span>")
		else
			user.visible_message("<span class='notice'>[user] helpfully reminds [victim] of the punishment for gross deriliction of duty by whapping [victim.p_them()] with [I], curing [victim.p_their()] stubbed toe!</span>", \
			"<span class='nicegreen'>You helpfully remind [victim] of the punishment for gross deriliction of duty by whapping [victim.p_them()] with [I], curing their stubbed toe!</span>", ignored_mobs=list(victim))
			to_chat(victim, "<span class='nicegreen'><b>[user] helpfully reminds you of the punishment for gross deriliction of duty by whapping you with [I], curing your stubbed toe!</b></span>")
		qdel(src)
		return TRUE
	else if(isgun(I) && user != victim && user.a_intent == INTENT_HELP && user.zone_selected == BODY_ZONE_HEAD)
		user.visible_message("<span class='notice'>[user] helpfully reminds [victim] of the punishment for gross deriliction of duty by aiming [I] point blank at [victim.p_their()] head, curing [victim.p_their()] stubbed toe!</span>", \
			"<span class='nicegreen'>You helpfully remind [victim] of the punishment for gross deriliction of duty by aiming [I] point blank at [victim.p_their()] head, curing [victim.p_their()] stubbed toe!</span>", ignored_mobs=list(victim))
		to_chat(victim, "<span class='nicegreen'><b>[user] helpfully reminds you of the punishment for gross deriliction of duty by aiming [I] point blank at your head! Suddenly your stubbed toe is cured!</b></span>")
		qdel(src)
		return TRUE
