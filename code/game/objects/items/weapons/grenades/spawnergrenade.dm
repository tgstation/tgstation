/obj/item/weapon/grenade/spawnergrenade
	desc = "It is set to detonate in 5 seconds. It will unleash unleash an unspecified anomaly into the vicinity."
	name = "delivery grenade"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "delivery"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4"
	var/banglet = 0
	var/spawner_type = null // must be an object path
	var/deliveryamt = 1 // amount of type to deliver
	var/mob/living/owner = null
	var/mob_faction = ""

/obj/item/weapon/grenade/spawnergrenade/prime(var/mob/living/L = null)
	// Prime now just handles the two loops that query for people in lockers and people who can see it.
	if(spawner_type && deliveryamt)
		// Make a quick flash
		var/turf/T = get_turf(src)
		playsound(T, 'sound/effects/phasein.ogg', 100, 1)
		for(var/mob/living/carbon/human/M in viewers(T, null))
			M.flash_eyes(visual = 1)

		var/list/spawned_atoms = list()
		for(var/i=1, i<=deliveryamt, i++)
			var/atom/movable/x = new spawner_type
			spawned_atoms += x
			x.loc = T
			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(x, pick(NORTH,SOUTH,EAST,WEST))
			if(L && istype(L))
				handle_faction(x,L)
			// Spawn some hostile critters
		postPrime(spawned_atoms)
	qdel(src)
	return

/obj/item/weapon/grenade/spawnergrenade/proc/handle_faction(var/mob/living/spawned, var/mob/living/L)
	return

/obj/item/weapon/grenade/spawnergrenade/proc/postPrime(var/list/spawned_atoms)
	return

/obj/item/weapon/grenade/spawnergrenade/manhacks
	name = "manhack delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/viscerator
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/grenade/spawnergrenade/manhacks/handle_faction(var/mob/living/spawned, var/mob/living/L)
	if(!spawned || !L)
		return

	spawned.faction = "\ref[L]"

/obj/item/weapon/grenade/spawnergrenade/manhacks/syndicate
	desc = "It is set to detonate in 5 seconds. It will unleash a pair of hostile visceratorrs that will hack at any nearby targets indiscriminately."
	name = "viscerator grenade"
	spawner_type = /mob/living/simple_animal/hostile/viscerator
	deliveryamt = 2
	origin_tech = "materials=3;magnets=4;syndicate=4"
	mob_faction = "syndicate"

/obj/item/weapon/grenade/spawnergrenade/manhacks/syndicate/handle_faction(var/mob/living/spawned, var/mob/living/L)
	if(!spawned || !L)
		return

	if(!isnukeop(L))//"syndicate" faction mobs don't attack nuke ops by default
		spawned.faction = "\ref[L]"

/obj/item/weapon/grenade/spawnergrenade/spesscarp
	name = "carp delivery grenade"
	spawner_type = /mob/living/simple_animal/hostile/carp
	deliveryamt = 5
	origin_tech = "materials=3;magnets=4;syndicate=4"

/obj/item/weapon/grenade/spawnergrenade/beenade
	name = "bee-nade"
	icon_state = "beenade"
	spawner_type = /mob/living/simple_animal/bee
	deliveryamt = 15
	origin_tech = "materials=3;magnets=4;biotech=4"


/obj/item/weapon/grenade/spawnergrenade/beenade/postPrime(var/list/spawned_atoms)
	if(!spawned_atoms || !spawned_atoms.len)
		return
	playsound(get_turf(src), 'sound/effects/bees.ogg', 100, 1)
	for(var/A in spawned_atoms)
		var/mob/living/simple_animal/bee/BEE = A
		if(!istype(BEE))
			continue
		BEE.strength = 1
		BEE.toxic = 5
		BEE.mut = 2
		BEE.feral = 25
		BEE.icon_state = "bees1-feral"
		BEE.newTarget()
