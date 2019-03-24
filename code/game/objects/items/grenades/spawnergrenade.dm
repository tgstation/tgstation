/obj/item/grenade/spawnergrenade
	desc = "It will unleash an unspecified anomaly into the vicinity."
	name = "delivery grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "delivery"
	item_state = "flashbang"
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver

/obj/item/grenade/spawnergrenade/prime()			// Prime now just handles the two loops that query for people in lockers and people who can see it.
	update_mob()
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		for(var/mob/living/carbon/C in viewers(T, null))
			C.flash_act()

		// Spawn some hostile syndicate critters and spread them out
		spawn_and_random_walk(spawner_type, T, deliveryamt, walk_chance=50, admin_spawn=((flags_1 & ADMIN_SPAWNED_1) ? TRUE : FALSE))

	qdel(src)

/obj/item/grenade/spawnergrenade/manhacks
	name = "viscerator delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/viscerator
	deliveryamt = 10

/obj/item/grenade/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/carp
	deliveryamt = 5

/obj/item/grenade/spawnergrenade/syndiesoap
	name = "Mister Scrubby"
	spawner_type = /obj/item/soap/syndie

/obj/item/grenade/spawnergrenade/buzzkill
	name = "Buzzkill grenade"
	desc = "The label reads: \"WARNING: DEVICE WILL RELEASE LIVE SPECIMENS UPON ACTIVATION. SEAL SUIT BEFORE USE.\" It is warm to the touch and vibrates faintly."
	icon_state = "holy_grenade"
	spawner_type = /mob/living/simple_animal/hostile/poison/bees/toxin
	deliveryamt = 10
