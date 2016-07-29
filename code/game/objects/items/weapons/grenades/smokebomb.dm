<<<<<<< HEAD
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
	smoke.set_up(4, src)
	smoke.start()


	for(var/obj/effect/blob/B in view(8,src))
		var/damage = round(30/(get_dist(B,src)+1))
		B.health -= damage
		B.update_icon()
	sleep(80)
	qdel(src)
=======
/obj/item/weapon/grenade/smokebomb
	desc = "It is set to detonate in 2 seconds."
	name = "smoke bomb"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"
	det_time = 20
	item_state = "flashbang"
	flags = FPRINT
	slot_flags = SLOT_BELT
	var/datum/effect/effect/system/smoke_spread/bad/smoke

	New()
		..()
		src.smoke = new /datum/effect/effect/system/smoke_spread/bad
		src.smoke.attach(src)

	prime()
		playsound(get_turf(src), 'sound/effects/smoke.ogg', 50, 1, -3)
		src.smoke.set_up(10, 0, usr.loc)
		spawn(0)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()
			sleep(10)
			src.smoke.start()

		for(var/obj/effect/blob/B in view(8,src))
			var/damage = round(30/(get_dist(B,src)+1))
			B.health -= damage
			B.update_icon()
		sleep(80)
		qdel(src)
		return
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
