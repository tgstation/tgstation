/turf
	icon = 'floors.dmi'
	var/intact = 1 //for floors, use is_plating(), is_plasteel_floor() and is_light_floor()

	level = 1.0

	var
		//Properties for open tiles (/floor)
		oxygen = 0
		carbon_dioxide = 0
		nitrogen = 0
		toxins = 0

		//Properties for airtight tiles (/wall)
		thermal_conductivity = 0.05
		heat_capacity = 1

		//Properties for both
		temperature = T20C

		blocks_air = 0
		icon_old = null
		pathweight = 1

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
	proc/return_siding_icon_state()
		return 0

/turf/space
	icon = 'space.dmi'
	name = "\proper space"
	icon_state = "placeholder"

	temperature = TCMB
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 700000

	transit

		var/pushdirection // push things that get caught in the transit tile this direction

		north // moving to the north

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

		east // moving to the east

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
//	icon = 'space.dmi'
	if(!istype(src, /turf/space/transit))
		..()
		icon_state = "[rand(1,25)]"

/turf/simulated
	name = "station"
	var/wet = 0
	var/image/wet_overlay = null

	var/thermite = 0
	oxygen = MOLES_O2STANDARD
	nitrogen = MOLES_N2STANDARD
	var/to_be_destroyed = 0 //Used for fire, if a melting temperature was reached, it will be destroyed
	var/max_fire_temperature_sustained = 0 //The max temperature of the fire which it was subjected to



/turf/simulated/wall/r_wall
	name = "r wall"
	desc = "A huge chunk of reinforced metal used to seperate rooms."
	icon_state = "r_wall"
	opacity = 1
	density = 1

	walltype = "rwall"

	var/d_state = 0

/turf/simulated/wall
	name = "wall"
	desc = "A huge chunk of metal used to seperate rooms."
	icon = 'walls.dmi'
	opacity = 1
	density = 1
	blocks_air = 1

	thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
	heat_capacity = 312500 //a little over 5 cm thick , 312500 for 1 m by 2.5 m by 0.25 m plasteel wall

	var/walltype = "wall"

/turf/simulated/wall/heatshield
	thermal_conductivity = 0
	opacity = 0
	name = "Heat Shielding"
	icon_state = "thermal"
	heat_capacity = 625000 //twice the cap of a normal wall
	walltype = "thermal"
	blocks_air = 1

/turf/simulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult"
	walltype = "cult"

/turf/simulated/shuttle
	name = "shuttle"
	icon = 'shuttle.dmi'
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
	icon = 'floors.dmi'
	icon_state = "Floor3"

/turf/unsimulated/wall
	name = "wall"
	icon = 'walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1

/turf/unsimulated/wall/other
	icon_state = "r_wall"

/turf/proc
	AdjacentTurfs()
		var/L[] = new()
		for(var/turf/simulated/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					L.Add(t)
		return L
	Distance(turf/t)
		if(get_dist(src,t) == 1)
			var/cost = (src.x - t.x) * (src.x - t.x) + (src.y - t.y) * (src.y - t.y)
			cost *= (pathweight+t.pathweight)/2
			return cost
		else
			return get_dist(src,t)

	Distance_ortho(turf/t)
		if(t != null && src != null)
			return abs(src.x - t.x) + abs(src.y - t.y)

		else
			return 99999

	AdjacentTurfsSpace()
		var/L[] = new()
		for(var/turf/t in oview(src,1))
			if(!t.density)
				if(!LinkBlocked(src, t) && !TurfBlockedNonWindow(t))
					L.Add(t)
		return L



/turf/simulated/wall/mineral
	icon = 'mineral_walls.dmi'
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
			if(W:welding)
				return TemperatureAct(100)
		..()

	temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
		if(exposed_temperature > 300)
			TemperatureAct(exposed_temperature)

	proc/TemperatureAct(temperature)
		for(var/turf/simulated/floor/target_tile in range(2,loc))

			var/datum/gas_mixture/napalm = new

			var/toxinsToDeduce = temperature/10

			napalm.toxins = toxinsToDeduce
			napalm.temperature = 400+T0C
			napalm.update_values()

			target_tile.assume_air(napalm)
			spawn (0) target_tile.hotspot_expose(temperature, 400)

			hardness -= toxinsToDeduce/100
			CheckHardness()
