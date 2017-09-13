/obj/item/grenade/spawnergrenade
	desc = "It will unleash an unspecified anomaly into the vicinity."
	name = "delivery grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "delivery"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4"
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver
	var/flashes = TRUE
	var/walk_chance = 50
	var/walk_distance = 1

/obj/item/grenade/spawnergrenade/prime()			// Prime now just handles the two loops that query for people in lockers and people who can see it.
	update_mob()
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		if(flashes)
			for(var/mob/living/carbon/C in viewers(T, null))
				C.flash_act()

		// Spawn some hostile syndicate critters and spread them out
		spawn_and_random_walk(spawner_type, T, deliveryamt, walk_chance, walk_distance, admin_spawn=admin_spawned)

	qdel(src)

/obj/item/grenade/spawnergrenade/manhacks
	name = "viscerator delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/viscerator
	deliveryamt = 10
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/grenade/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/carp
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=3"

/obj/item/grenade/spawnergrenade/syndiesoap
	name = "Mister Scrubby"
	spawner_type = /obj/item/soap/syndie
	walk_chance = 100


/obj/item/grenade/spawnergrenade/repressurizer
	name = "Atmospheric restoration grenade"
	desc = "Quickly repressurizes a room by opening numerous portals which will siphon air from a backwater planet."
	spawner_type = /obj/machinery/atmospherics/miner/gas_portal/repressurizer
	walk_distance = 10
	walk_chance = 100
	deliveryamt = 10
	flashes = FALSE
