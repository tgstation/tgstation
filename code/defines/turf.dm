//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:31

/turf
	icon = 'icons/turf/floors.dmi'
	var/intact = 1 //for floors, use is_plating(), is_plasteel_floor() and is_light_floor()

	level = 1.0

		//Properties for open tiles (/floor)
	var/oxygen = 0
	var/carbon_dioxide = 0
	var/nitrogen = 0
	var/toxins = 0

		//Properties for airtight tiles (/wall)
	var/thermal_conductivity = 0.05
	var/heat_capacity = 1

		//Properties for both
	var/temperature = T20C

	var/blocks_air = 0
	var/icon_old = null
	var/pathweight = 1

	proc/is_plating()
		return 0
	proc/is_asteroid_floor()
		return 0
	proc/is_plasteel_floor()
		return 0
	proc/is_light_floor()
		return 0
	proc/is_grass_floor()
		return 0
	proc/is_wood_floor()
		return 0
	proc/return_siding_icon_state()		//used for grass floors, which have siding.
		return 0

/turf/Entered(atom/A as mob|obj)
	..()
	if ((A && A.density && !( istype(A, /obj/effect/beam) )))
		for(var/obj/effect/beam/i_beam/I in src)
			spawn( 0 )
				if (I)
					I.hit()
				return
	return

/turf/space
	icon = 'icons/turf/space.dmi'
	name = "\proper space"
	icon_state = "placeholder"

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

/turf/space/transit
	var/pushdirection // push things that get caught in the transit tile this direction

//Overwrite because we dont want people building rods in space.
/turf/space/transit/attackby(obj/O as obj, mob/user as mob)
	return

/turf/space/transit/north // moving to the north

	pushdirection = SOUTH  // south because the space tile is scrolling south

	//IF ANYONE KNOWS A MORE EFFICIENT WAY OF MANAGING THESE SPRITES, BE MY GUEST.
	shuttlespace_ns1
		icon_state = "speedspace_ns_1"
	shuttlespace_ns2
		icon_state = "speedspace_ns_2"
	shuttlespace_ns3
		icon_state = "speedspace_ns_3"
	shuttlespace_ns4
		icon_state = "speedspace_ns_4"
	shuttlespace_ns5
		icon_state = "speedspace_ns_5"
	shuttlespace_ns6
		icon_state = "speedspace_ns_6"
	shuttlespace_ns7
		icon_state = "speedspace_ns_7"
	shuttlespace_ns8
		icon_state = "speedspace_ns_8"
	shuttlespace_ns9
		icon_state = "speedspace_ns_9"
	shuttlespace_ns10
		icon_state = "speedspace_ns_10"
	shuttlespace_ns11
		icon_state = "speedspace_ns_11"
	shuttlespace_ns12
		icon_state = "speedspace_ns_12"
	shuttlespace_ns13
		icon_state = "speedspace_ns_13"
	shuttlespace_ns14
		icon_state = "speedspace_ns_14"
	shuttlespace_ns15
		icon_state = "speedspace_ns_15"

/turf/space/transit/east // moving to the east

	pushdirection = WEST

	shuttlespace_ew1
		icon_state = "speedspace_ew_1"
	shuttlespace_ew2
		icon_state = "speedspace_ew_2"
	shuttlespace_ew3
		icon_state = "speedspace_ew_3"
	shuttlespace_ew4
		icon_state = "speedspace_ew_4"
	shuttlespace_ew5
		icon_state = "speedspace_ew_5"
	shuttlespace_ew6
		icon_state = "speedspace_ew_6"
	shuttlespace_ew7
		icon_state = "speedspace_ew_7"
	shuttlespace_ew8
		icon_state = "speedspace_ew_8"
	shuttlespace_ew9
		icon_state = "speedspace_ew_9"
	shuttlespace_ew10
		icon_state = "speedspace_ew_10"
	shuttlespace_ew11
		icon_state = "speedspace_ew_11"
	shuttlespace_ew12
		icon_state = "speedspace_ew_12"
	shuttlespace_ew13
		icon_state = "speedspace_ew_13"
	shuttlespace_ew14
		icon_state = "speedspace_ew_14"
	shuttlespace_ew15
		icon_state = "speedspace_ew_15"


/turf/space/New()
//	icon = 'icons/turf/space.dmi'
	if(!istype(src, /turf/space/transit))
		icon_state = "[pick(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25)]"



/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to

/turf/simulated/New()
	..()
	levelupdate()

/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'icons/turf/walls.dmi'
	var/mineral = "metal"
	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/walltype = "metal"

/turf/simulated/wall/r_wall
	name = "r wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon_state = "r_wall"
	opacity = 1
	density = 1

	walltype = "rwall"

	var/d_state = 0

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

/turf/simulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult"
	walltype = "cult"

/turf/simulated/shuttle
	name = "shuttle"
	icon = 'icons/turf/shuttle.dmi'
	thermal_conductivity = 0.05
	heat_capacity = 0
	layer = 2

/turf/simulated/shuttle/wall
	name = "wall"
	icon_state = "wall1"
	opacity = 1
	density = 1
	blocks_air = 1

/turf/simulated/shuttle/floor
	name = "floor"
	icon_state = "floor"

/turf/simulated/shuttle/plating
	name = "plating"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/simulated/shuttle/floor4 // Added this floor tile so that I have a seperate turf to check in the shuttle -- Polymorph
	name = "Brig floor"        // Also added it into the 2x3 brig area of the shuttle.
	icon_state = "floor4"

/turf/unsimulated
	intact = 1
	name = "command"
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD

/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/wall
	name = "wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1

turf/unsimulated/wall/splashscreen
	name = "Space Station 13"
	icon = 'icons/misc/fullscreen.dmi'
	icon_state = "title"
	layer = FLY_LAYER

/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/proc/AdjacentTurfs()
	var/L[] = new()
	for(var/turf/simulated/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L
/turf/proc/Distance(turf/t)
	if(get_dist(src,t) == 1)
		var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
		cost *= (pathweight+t.pathweight)/2
		return cost
	else
		return get_dist(src,t)
/turf/proc/AdjacentTurfsSpace()
	var/L[] = new()
	for(var/turf/t in oview(src,1))
		if(!t.density)
			if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
				L.Add(t)
	return L


/*
/turf/simulated/wall/mineral
	icon = 'icons/turf/mineral_walls.dmi'
	walltype = "iron"

	var/oreAmount = 1
	var/hardness = 1

	New()
		..()
		name = "[walltype] wall"

	dismantle_wall(devastated = 0)
		if(!devastated)
			var/ore = text2path("/obj/item/weapon/ore/[walltype]")
			for(var/i = 1, i <= oreAmount, i++)
				new ore(src)
			ReplaceWithFloor()
		else
			ReplaceWithSpace()

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/pickaxe))
			var/obj/item/weapon/pickaxe/digTool = W
			user << "You start digging the [name]."
			if(do_after(user,digTool.digspeed*hardness) && src)
				user << "You finished digging."
				dismantle_wall()
		else if(istype(W,/obj/item/weapon)) //not sure, can't not just weapons get passed to this proc?
			hardness -= W.force/100
			user << "You hit the [name] with your [W.name]!"
			CheckHardness()
		else
			attack_hand(user)
		return

	proc/CheckHardness()
		if(hardness <= 0)
			dismantle_wall()

/turf/simulated/wall/mineral/iron
	walltype = "iron"
	hardness = 3

/turf/simulated/wall/mineral/silver
	walltype = "silver"
	hardness = 3

/turf/simulated/wall/mineral/uranium
	walltype = "uranium"
	hardness = 3

	New()
		..()
		sd_SetLuminosity(3)

/turf/simulated/wall/mineral/gold
	walltype = "gold"

/turf/simulated/wall/mineral/sand
	walltype = "sand"
	hardness = 0.5

/turf/simulated/wall/mineral/transparent
	opacity = 0

/turf/simulated/wall/mineral/transparent/diamond
	walltype = "diamond"
	hardness = 10

/turf/simulated/wall/mineral/transparent/plasma
	walltype = "plasma"

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(istype(W,/obj/item/weapon/weldingtool))
			var/obj/item/weapon/weldingtool/WT = W
			if(WT.remove_fuel(0, user))
				return TemperatureAct(100)
		..()

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if(exposed_temperature > 300)
			TemperatureAct(exposed_temperature)

	proc/TemperatureAct(temperature)
		for(var/turf/simulated/floor/target_tile in range(2,loc))
			if(target_tile.parent && target_tile.parent.group_processing)
				target_tile.parent.suspend_group_processing()

			var/datum/gas_mixture/napalm = new

			var/toxinsToDeduce = temperature/10

			napalm.toxins = toxinsToDeduce
			napalm.temperature = 400+T0C

			target_tile.assume_air(napalm)
			spawn (0) target_tile.hotspot_expose(temperature, 400)

			hardness -= toxinsToDeduce/100
			CheckHardness()
*/
