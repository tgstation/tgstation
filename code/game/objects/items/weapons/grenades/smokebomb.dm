/obj/item/weapon/grenade/smokebomb
	name = "smoke grenade"
	desc = "The word 'Dank' is scribbled on it in crayon."
	icon = 'icons/obj/grenade.dmi'
	icon_state = "smokewhite"
	det_time = 20
	item_state = "flashbang"
	slot_flags = SLOT_BELT
	var/datum/effect_system/smoke_spread/bad/smoke

/obj/item/weapon/grenade/smokebomb/New()
	..()
	src.smoke = new /datum/effect_system/smoke_spread/bad
	src.smoke.attach(src)

/obj/item/weapon/grenade/smokebomb/Destroy()
	qdel(smoke)
	return ..()

/obj/item/weapon/grenade/smokebomb/prime()
	update_mob()
	playsound(src.loc, 'sound/effects/smoke.ogg', 50, 1, -3)
	smoke.set_up(4, usr.loc)
	smoke.start()


	for(var/obj/effect/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.health -= damage
		B.update_icon()
	sleep(80)
	qdel(src)
