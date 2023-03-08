/obj/structure/pinata
	name = "corgi pinata"
	desc = "A paper mache representation of a corgi that contains all sorts of sugary treats."
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "pinata_placed"
	max_integrity = 300 //20 hits from a baseball bat
	anchored = TRUE

/obj/structure/pinata/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pinata)

/obj/structure/pinata/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(damage_amount >= 10) // Swing means minimum damage threshhold for dropping candy is met.
		flick("[icon_state]_swing", src)

/obj/structure/pinata/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/slash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/obj/item/pinata
	name = "pinata assembly kit"
	desc = "a paper mache corgi that contains various candy, most be set up before you can smash it"
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "pinata"

/obj/item/pinata/attack_self(mob/user)
	var/turf/player_turf = get_turf(user)
	if(player_turf?.is_blocked_turf(TRUE))
		return FALSE
	user.visible_message(span_info("[user] begins to set up \the [src]..."))
	if(do_after(user, 4 SECONDS, target = user.drop_location(), progress = TRUE))
		new /obj/structure/pinata(user.drop_location())
		to_chat(user, span_notice("You set up \the [src]."))
		qdel(src)
