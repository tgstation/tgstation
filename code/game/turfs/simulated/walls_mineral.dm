/turf/simulated/wall/mineral
	name = "mineral wall"
	desc = "This shouldn't exist"
	icon_state = ""
	var/last_event = 0
	var/active = null

/turf/simulated/wall/mineral/New()
	switch(mineral)
		if("gold")
			name = "gold wall"
			desc = "A wall with gold plating. Swag!"
			icon_state = "gold0"
			walltype = "gold"
//			var/electro = 1
//			var/shocked = null
		if("silver")
			name = "silver wall"
			desc = "A wall with silver plating. Shiny!"
			icon_state = "silver0"
			walltype = "silver"
//			var/electro = 0.75
//			var/shocked = null
		if("diamond")
			name = "diamond wall"
			desc = "A wall with diamond plating. You monster."
			icon_state = "diamond0"
			walltype = "diamond"
		if("uranium")
			name = "uranium wall"
			desc = "A wall with uranium plating. This is probably a bad idea."
			icon_state = "uranium0"
			walltype = "uranium"
		if("plasma")
			name = "plasma wall"
			desc = "A wall with plasma plating. This is definately a bad idea."
			icon_state = "plasma0"
			walltype = "plasma"
		if("clown")
			name = "bananium wall"
			desc = "A wall with bananium plating. Honk!"
			icon_state = "clown0"
			walltype = "clown"
		if("sandstone")
			name = "sandstone wall"
			desc = "A wall with sandstone plating."
			icon_state = "sandstone0"
			walltype = "sandstone"
	..()

/turf/simulated/wall/mineral/proc/radiate()
	if(!active)
		if(world.time > last_event+15)
			active = 1
			for(var/mob/living/L in range(3,src))
				L.apply_effect(12,IRRADIATE,0)
			for(var/turf/simulated/wall/mineral/T in range(3,src))
				if(T.mineral == "uranium")
					T.radiate()
			last_event = world.time
			active = null
			return
	return

/*/turf/simulated/wall/mineral/proc/shock()
	if (electrocute_mob(user, C, src))
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(5, 1, src)
		s.start()
		return 1
	else
		return 0
		*/

/turf/simulated/wall/mineral/attack_hand(mob/user as mob)
	if(mineral == "uranium")
		radiate()
	..()

/turf/simulated/wall/mineral/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if((mineral == "plasma") && W)
		if(is_hot(W) > 300)//If the temperature of the object is over 300, then ignite
			ignite(is_hot(W))
			return
	if(mineral == "uranium")
		radiate()
//	if((mineral == "gold") || (mineral == "silver"))
//		if(shocked)
//			shock()
	..()

/turf/simulated/wall/mineral/proc/PlasmaBurn(temperature)
	spawn(2)
	new /obj/structure/girder(src)
	src.ReplaceWithFloor()
	for(var/turf/simulated/floor/target_tile in range(0,src))
		/*if(target_tile.parent && target_tile.parent.group_processing)
			target_tile.parent.suspend_group_processing()*/
		var/datum/gas_mixture/napalm = new
		var/toxinsToDeduce = 20
		napalm.toxins = toxinsToDeduce
		napalm.temperature = 400+T0C
		target_tile.assume_air(napalm)
		spawn (0) target_tile.hotspot_expose(temperature, 400)
	for(var/obj/structure/falsewall/plasma/F in range(3,src))//Hackish as fuck, but until temperature_expose works, there is nothing I can do -Sieve
		var/turf/T = get_turf(F)
		T.ReplaceWithMineralWall("plasma")
		del (F)
	for(var/turf/simulated/wall/mineral/W in range(3,src))
		if(mineral == "plasma")
			W.ignite((temperature/4))//Added so that you can't set off a massive chain reaction with a small flame
	for(var/obj/machinery/door/airlock/plasma/D in range(3,src))
		D.ignite(temperature/4)

/turf/simulated/wall/mineral/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)//Doesn't fucking work because walls don't interact with air :(
	if(mineral == "plasma")
		if(exposed_temperature > 300)
			PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/proc/ignite(exposed_temperature)
	if(mineral == "plasma")
		if(exposed_temperature > 300)
			PlasmaBurn(exposed_temperature)

/turf/simulated/wall/mineral/Bumped(AM as mob|obj)
	if(mineral == "uranium")
		radiate()
	..()

/turf/simulated/wall/mineral/bullet_act(var/obj/item/projectile/Proj)
	if(mineral == "plasma")
		if(istype(Proj,/obj/item/projectile/beam))
			PlasmaBurn(2500)
		else if(istype(Proj,/obj/item/projectile/ion))
			PlasmaBurn(500)
	..()