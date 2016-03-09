/obj/item/weapon/grenade/spawnergrenade
	desc = "It will unleash unleash an unspecified anomaly into the vicinity."
	name = "delivery grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "delivery"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4"
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver

/obj/item/weapon/grenade/spawnergrenade/prime()			// Prime now just handles the two loops that query for people in lockers and people who can see it.
	update_mob()
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		for(var/mob/living/carbon/C in viewers(T, null))
			C.flash_eyes()

		for(var/i=1, i<=deliveryamt, i++)
			var/atom/movable/x = new spawner_type
			x.loc = T
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(x, pick(NORTH,SOUTH,EAST,WEST))

			// Spawn some hostile syndicate critters

	qdel(src)

/obj/item/weapon/grenade/spawnergrenade/manhacks
	name = "viscerator delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/viscerator
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/grenade/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/carp
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=4"