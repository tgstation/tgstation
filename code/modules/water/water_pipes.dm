obj/machinery/water/pipe
	var/datum/reagents/reagents_temporary //used when reconstructing a pipeline that broke
	var/datum/water/pipeline/parent

	var/max_volume = 0
	var/max_pressure = 3 * ONE_ATMOSPHERE
	var/force = 20

	layer = 2.3 //under water pipes with their 2.4

	var/alert_pressure = 2.5*ONE_ATMOSPHERE
		//minimum pressure before check_pressure(...) should be called

	New()
		..()

	proc/pipeline_expansion()
		return null

	proc/check_pressure(pressure)
		//Return 1 if parent should continue checking other pipes
		//Return null if parent should stop checking other pipes. Recall: del(src) will by default return null

		return 1

	proc/return_reagents()
		if(!parent)
			parent = new /datum/water/pipeline()
			parent.build_pipeline(src)

		return parent.reagents

	build_network()
		if(!parent)
			parent = new /datum/water/pipeline()
			parent.build_pipeline(src)

		return parent.return_network()

	network_expand(datum/water/pipe_network/new_network, obj/machinery/water/pipe/reference)
		if(!parent)
			parent = new /datum/water/pipeline()
			parent.build_pipeline(src)

		return parent.network_expand(new_network, reference)

	return_network(obj/machinery/water/reference)
		if(!parent)
			parent = new /datum/water/pipeline()
			parent.build_pipeline(src)

		return parent.return_network(reference)

	Del()
		var/turf/simulated/target = get_turf(loc)
		if(istype(target) && parent)
			parent.mingle_with_turf(target, \
				parent.reagents.total_volume / parent.reagents.maximum_volume * max_volume)
			del(parent)
		..()

	simple
		icon = 'pipes.dmi'
		icon_state = "intact-f"

		name = "pipe"
		desc = "A one meter section of regular pipe"

		max_volume = 500

		dir = SOUTH
		initialize_directions = SOUTH|NORTH

		var/obj/machinery/water/node1
		var/obj/machinery/water/node2

		var/burst_pressure = 2.8*ONE_ATMOSPHERE
		var/fatigue_pressure = 2.5*ONE_ATMOSPHERE


		level = 1

		New()
			..()
			switch(dir)
				if(SOUTH || NORTH)
					initialize_directions = SOUTH|NORTH
				if(EAST || WEST)
					initialize_directions = EAST|WEST
				if(NORTHEAST)
					initialize_directions = NORTH|EAST
				if(NORTHWEST)
					initialize_directions = NORTH|WEST
				if(SOUTHEAST)
					initialize_directions = SOUTH|EAST
				if(SOUTHWEST)
					initialize_directions = SOUTH|WEST

		hide(var/i)
			if(level == 1 && istype(loc, /turf/simulated))
				invisibility = i ? 101 : 0
			update_icon()

		process()
			if(!parent) //This should cut back on the overhead calling build_network thousands of times per cycle
				..()
			else
				machines.Remove(src)

			/*if(!node1)
				parent.mingle_with_turf(loc, volume)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1

			else if(!node2)
				parent.mingle_with_turf(loc, volume)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1
			else if (nodealert)
				nodealert = 0


			else if(parent)
				var/environment_temperature = 0

				if(istype(loc, /turf/simulated/))
					if(loc:blocks_air)
						environment_temperature = loc:temperature
					else
						var/datum/gas_mixture/environment = loc.return_air()
						environment_temperature = environment.temperature

				else
					environment_temperature = loc:temperature

				var/datum/gas_mixture/pipe_air = return_air()

				if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
					parent.temperature_interact(loc, volume, thermal_conductivity)
			*/  //Screw you heat lag

		check_pressure(pressure)
			var/datum/gas_mixture/environment = loc.return_air()

			var/pressure_difference = pressure - environment.return_pressure()

			if(pressure_difference > burst_pressure)
				burst()

			else if(pressure_difference > fatigue_pressure)
				//TODO: leak to turf, doing pfshhhhh
				if(prob(5))
					burst()

			else return 1

		proc/burst()
			src.visible_message("\red \bold [src] bursts!");
			playsound(src.loc, 'bang.ogg', 25, 1)

			var/obj/effect/effect/water/W = new(get_turf(src))
			W.reagents = reagents
			W.reagents.my_atom = W
			if(!W) return
			W.reagents.reaction(get_turf(W))
			for(var/atom/atm in get_turf(W))
				if(!W) return
				W.reagents.reaction(atm)
			sleep(1)

			del(src)

		proc/normalize_dir()
			if(dir==3)
				dir = 1
			else if(dir==12)
				dir = 4

		Del()
			if(node1)
				node1.disconnect(src)
			if(node2)
				node2.disconnect(src)

			..()

		pipeline_expansion()
			return list(node1, node2)

		update_icon()
			if(node1&&node2)
				var/C = ""
				switch(color)
					if ("red") C = "-r"
					if ("blue") C = "-b"
					if ("cyan") C = "-c"
					if ("green") C = "-g"
					if ("yellow") C = "-y"
					if ("purple") C = "-p"
				icon_state = "intact[C][invisibility ? "-f" : "" ]"

				//var/node1_direction = get_dir(src, node1)
				//var/node2_direction = get_dir(src, node2)

				//dir = node1_direction|node2_direction

			else
				if(!node1&&!node2)
					del(src) //TODO: silent deleting looks weird
				var/have_node1 = node1?1:0
				var/have_node2 = node2?1:0
				icon_state = "exposed[have_node1][have_node2][invisibility ? "-f" : "" ]"


		initialize()
			normalize_dir()
			var/node1_dir
			var/node2_dir

			for(var/direction in cardinal)
				if(direction&initialize_directions)
					if (!node1_dir)
						node1_dir = direction
					else if (!node2_dir)
						node2_dir = direction

			for(var/obj/machinery/water/target in get_step(src,node1_dir))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break
			for(var/obj/machinery/water/target in get_step(src,node2_dir))
				if(target.initialize_directions & get_dir(target,src))
					node2 = target
					break


			var/turf/T = src.loc			// hide if turf is not intact
			hide(T.intact)
			update_icon()
			//update_icon()

		disconnect(obj/machinery/water/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/water/pipe))
					del(parent)
				node1 = null

			if(reference == node2)
				if(istype(node2, /obj/machinery/water/pipe))
					del(parent)
				node2 = null

			update_icon()

			return null

	simple/drainage
		name="Drainage pipe"
		color="yellow"
		icon_state = ""

	simple/drainage_waste
		name="Drainage waste pipe"
		color="green"
		icon_state = ""

	simple/supply
		name="Water supply pipe"
		color="cyan"
		icon_state = ""

		New()
			..()
			reagents_temporary = new(max_volume)
			reagents_temporary.my_atom = src
			reagents_temporary.add_reagent("water", max_volume / 3)

	simple/general
		name="Water pipe"
		color=""
		icon_state = ""

	simple/drainage/visible
		level = 2
		icon_state = "intact-y"

	simple/drainage/hidden
		level = 1
		icon_state = "intact-y-f"

	simple/drainage_waste/visible
		level = 2
		icon_state = "intact-g"

	simple/drainage_waste/hidden
		level = 1
		icon_state = "intact-g-f"

	simple/supply/visible
		level = 2
		icon_state = "intact-c"

	simple/supply/hidden
		level = 1
		icon_state = "intact-c-f"

	simple/general/visible
		level = 2
		icon_state = "intact"

	simple/general/hidden
		level = 1
		icon_state = "intact-f"

	tank
		icon = 'pipe_tank.dmi'
		icon_state = "intact"

		name = "Pressure Tank"
		desc = "A large vessel containing pressurized liquid."

		max_volume = 23000
		max_pressure = 4*ONE_ATMOSPHERE

		dir = SOUTH
		initialize_directions = SOUTH
		density = 1

		var/obj/machinery/water/node1

		New()
			initialize_directions = dir
			reagents_temporary = new(max_volume)
			reagents_temporary.my_atom = src
			..()

		process()
			if(!parent)
				..()
			else
				machines.Remove(src)
/*			if(!node1)
				parent.mingle_with_turf(loc, 200)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1
			else if (nodealert)
				nodealert = 0
*/

		water
			name = "Pressure Tank (Water)"
			icon = 'blue_water_tank.dmi'

			New()
				..()
				reagents_temporary.add_reagent("water", max_volume * 0.95)

		sugar_water
			name = "Pressure Tank (Sugar Water)"

			New()
				..()
				reagents_temporary.add_reagent("water", max_volume * 0.475)
				reagents_temporary.add_reagent("sugar", max_volume * 0.475)

		blue_paint
			name = "Pressure Tank (Blue Paint)"
			icon = 'blue_pipe_tank.dmi'

			New()
				..()
				reagents_temporary.add_reagent("paint_blue", max_volume * 0.95)

		Del()
			if(node1)
				node1.disconnect(src)

			..()

		pipeline_expansion()
			return list(node1)

		update_icon()
			if(node1)
				icon_state = "intact"

				dir = get_dir(src, node1)

			else
				icon_state = "exposed"

		initialize()

			var/connect_direction = dir

			for(var/obj/machinery/water/target in get_step(src,connect_direction))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			update_icon()

		disconnect(obj/machinery/water/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/water/pipe))
					del(parent)
				node1 = null

			update_icon()

			return null

/* currently pointless because reagents can't just sit on a turf (currently)
	drain
		icon = 'pipe_vent.dmi'
		icon_state = "intact"

		name = "Drain"
		desc = "A large drain"

		level = 1

		max_volume = 200

		dir = SOUTH
		initialize_directions = SOUTH

		var/build_killswitch = 1

		var/obj/machinery/water/node1
		New()
			initialize_directions = dir
			..()

		process()
			if(!parent)
				if(build_killswitch <= 0)
					machines.Remove(src)
				else
					build_killswitch--
				..()
				return
			else
				var/pressure = parent.return_pressure()
				var/datum/gas_mixture/env_air = loc.return_air()

				if(env_air.return_pressure() > pressure)
				parent.mingle_with_turf(loc, 200)
/*
			if(!node1)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1
			else if (nodealert)
				nodealert = 0
*/
		Del()
			if(node1)
				node1.disconnect(src)

			..()

		pipeline_expansion()
			return list(node1)

		update_icon()
			if(node1)
				icon_state = "intact"

				dir = get_dir(src, node1)

			else
				icon_state = "exposed"

		initialize()
			var/connect_direction = dir

			for(var/obj/machinery/water/target in get_step(src,connect_direction))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			update_icon()

		disconnect(obj/machinery/water/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/water/pipe))
					del(parent)
				node1 = null

			update_icon()

			return null

		hide(var/i) //to make the little pipe section invisible, the icon changes.
			if(node1)
				icon_state = "[i == 1 && istype(loc, /turf/simulated) ? "h" : "" ]intact"
				dir = get_dir(src, node1)
			else
				icon_state = "exposed"
*/

	manifold
		icon = 'pipe_manifold.dmi'
		icon_state = "manifold-f"

		name = "pipe manifold"
		desc = "A liquid manifold composed of regular pipes"

		max_volume = 750

		dir = SOUTH
		initialize_directions = EAST|NORTH|WEST

		var/obj/machinery/water/node1
		var/obj/machinery/water/node2
		var/obj/machinery/water/node3

		level = 1

		New()
			..()
			switch(dir)
				if(NORTH)
					initialize_directions = EAST|SOUTH|WEST
				if(SOUTH)
					initialize_directions = WEST|NORTH|EAST
				if(EAST)
					initialize_directions = SOUTH|WEST|NORTH
				if(WEST)
					initialize_directions = NORTH|EAST|SOUTH

		hide(var/i)
			if(level == 1 && istype(loc, /turf/simulated))
				invisibility = i ? 101 : 0
			update_icon()

		pipeline_expansion()
			return list(node1, node2, node3)

		process()
			if(!parent)
				..()
			else
				machines.Remove(src)
/*
			if(!node1)
				parent.mingle_with_turf(loc, 70)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1
			else if(!node2)
				parent.mingle_with_turf(loc, 70)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1
			else if(!node3)
				parent.mingle_with_turf(loc, 70)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1
			else if (nodealert)
				nodealert = 0
*/
		Del()
			if(node1)
				node1.disconnect(src)
			if(node2)
				node2.disconnect(src)
			if(node3)
				node3.disconnect(src)

			..()

		disconnect(obj/machinery/water/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/water/pipe))
					del(parent)
				node1 = null

			if(reference == node2)
				if(istype(node2, /obj/machinery/water/pipe))
					del(parent)
				node2 = null

			if(reference == node3)
				if(istype(node3, /obj/machinery/water/pipe))
					del(parent)
				node3 = null

			update_icon()

			..()

		update_icon()
			if(node1&&node2&&node3)
				var/C = ""
				switch(color)
					if ("red") C = "-r"
					if ("blue") C = "-b"
					if ("cyan") C = "-c"
					if ("green") C = "-g"
					if ("yellow") C = "-y"
					if ("purple") C = "-p"
				icon_state = "manifold[C][invisibility ? "-f" : ""]"

			else
				var/connected = 0
				var/unconnected = 0
				var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)

				if(node1)
					connected |= get_dir(src, node1)
				if(node2)
					connected |= get_dir(src, node2)
				if(node3)
					connected |= get_dir(src, node3)

				unconnected = (~connected)&(connect_directions)

				icon_state = "manifold_[connected]_[unconnected]"

				if(!connected)
					del(src)

			return

		initialize()
			var/connect_directions = (NORTH|SOUTH|EAST|WEST)&(~dir)

			for(var/direction in cardinal)
				if(direction&connect_directions)
					for(var/obj/machinery/water/target in get_step(src,direction))
						if(target.initialize_directions & get_dir(target,src))
							node1 = target
							connect_directions &= ~direction
							break
					if (node1)
						break


			for(var/direction in cardinal)
				if(direction&connect_directions)
					for(var/obj/machinery/water/target in get_step(src,direction))
						if(target.initialize_directions & get_dir(target,src))
							node2 = target
							connect_directions &= ~direction
							break
					if (node2)
						break


			for(var/direction in cardinal)
				if(direction&connect_directions)
					for(var/obj/machinery/water/target in get_step(src,direction))
						if(target.initialize_directions & get_dir(target,src))
							node3 = target
							connect_directions &= ~direction
							break
					if (node3)
						break

			var/turf/T = src.loc			// hide if turf is not intact
			hide(T.intact)
			//update_icon()
			update_icon()

	manifold/drainage
		name="Drainage pipe"
		color="yellow"
		icon_state = ""

	manifold/drainage_waste
		name="Drainage waste pipe"
		color="green"
		icon_state = ""

	manifold/supply
		name="Water supply pipe"
		color="cyan"
		icon_state = ""

		New()
			..()
			reagents_temporary = new(max_volume)
			reagents_temporary.my_atom = src
			reagents_temporary.add_reagent("water", max_volume / 3)

	manifold/general
		name="Water pipe"
		color="gray"
		icon_state = ""

	manifold/drainage/visible
		level = 2
		icon_state = "manifold-y"

	manifold/drainage/hidden
		level = 1
		icon_state = "manifold-y-f"

	manifold/drainage_waste/visible
		level = 2
		icon_state = "manifold-g"

	manifold/drainage_waste/hidden
		level = 1
		icon_state = "manifold-g-f"

	manifold/supply/visible
		level = 2
		icon_state = "manifold-c"

	manifold/supply/hidden
		level = 1
		icon_state = "manifold-c-f"

	manifold/general/visible
		level = 2
		icon_state = "manifold"

	manifold/general/hidden
		level = 1
		icon_state = "manifold-f"

	manifold4w
		icon = 'pipe_manifold.dmi'
		icon_state = "manifold4w-f"

		name = "4-way pipe manifold"
		desc = "A liquid manifold composed of regular pipes"

		max_volume = 1000

		dir = SOUTH
		initialize_directions = EAST|NORTH|WEST|SOUTH

		var/obj/machinery/water/node1
		var/obj/machinery/water/node2
		var/obj/machinery/water/node3
		var/obj/machinery/water/node4

		level = 1

		hide(var/i)
			if(level == 1 && istype(loc, /turf/simulated))
				invisibility = i ? 101 : 0
			update_icon()

		pipeline_expansion()
			return list(node1, node2, node3, node4)

		process()
			if(!parent)
				..()
			else
				machines.Remove(src)
/*
			if(!node1)
				parent.mingle_with_turf(loc, 70)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1
			else if(!node2)
				parent.mingle_with_turf(loc, 70)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1
			else if(!node3)
				parent.mingle_with_turf(loc, 70)
				if(!nodealert)
					//world << "Missing node from [src] at [src.x],[src.y],[src.z]"
					nodealert = 1
			else if (nodealert)
				nodealert = 0
*/
		Del()
			if(node1)
				node1.disconnect(src)
			if(node2)
				node2.disconnect(src)
			if(node3)
				node3.disconnect(src)
			if(node4)
				node4.disconnect(src)

			..()

		disconnect(obj/machinery/water/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/water/pipe))
					del(parent)
				node1 = null

			if(reference == node2)
				if(istype(node2, /obj/machinery/water/pipe))
					del(parent)
				node2 = null

			if(reference == node3)
				if(istype(node3, /obj/machinery/water/pipe))
					del(parent)
				node3 = null

			if(reference == node4)
				if(istype(node4, /obj/machinery/water/pipe))
					del(parent)
				node3 = null

			update_icon()

			..()

		update_icon()
			overlays = new()
			if(node1&&node2&&node3&&node4)
				var/C = ""
				switch(color)
					if ("red") C = "-r"
					if ("blue") C = "-b"
					if ("cyan") C = "-c"
					if ("green") C = "-g"
					if ("yellow") C = "-y"
					if ("purple") C = "-p"
				icon_state = "manifold4w[C][invisibility ? "-f" : ""]"

			else
				icon_state = "manifold4w_ex"
				var/icon/con = new/icon('pipe_manifold.dmi',"manifold4w_con")

				if(node1)
					overlays += new/image(con,dir=1)
				if(node2)
					overlays += new/image(con,dir=2)
				if(node3)
					overlays += new/image(con,dir=4)
				if(node4)
					overlays += new/image(con,dir=8)

				if(!node1 && !node2 && !node3 && !node4)
					del(src)
			return

		initialize()
			for(var/obj/machinery/water/target in get_step(src,1))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			for(var/obj/machinery/water/target in get_step(src,2))
				if(target.initialize_directions & get_dir(target,src))
					node2 = target
					break

			for(var/obj/machinery/water/target in get_step(src,4))
				if(target.initialize_directions & get_dir(target,src))
					node3 = target
					break

			for(var/obj/machinery/water/target in get_step(src,8))
				if(target.initialize_directions & get_dir(target,src))
					node4 = target
					break

			var/turf/T = src.loc			// hide if turf is not intact
			hide(T.intact)
			//update_icon()
			update_icon()

	manifold4w/drainage
		name="Drainage pipe"
		color="yellow"
		icon_state = ""

	manifold4w/drainage_waste
		name="Drainage waste pipe"
		color="green"
		icon_state = ""

	manifold4w/supply
		name="Water supply pipe"
		color="cyan"
		icon_state = ""

		New()
			..()
			reagents_temporary = new(max_volume)
			reagents_temporary.my_atom = src
			reagents_temporary.add_reagent("water", max_volume / 3)

	manifold4w/general
		name="Water pipe"
		color="gray"
		icon_state = ""

	manifold4w/drainage/visible
		level = 2
		icon_state = "manifold4w-y"

	manifold4w/drainage/hidden
		level = 1
		icon_state = "manifold4w-y-f"

	manifold4w/drainage_waste/visible
		level = 2
		icon_state = "manifold4w-g"

	manifold4w/drainage_waste/hidden
		level = 1
		icon_state = "manifold4w-g-f"

	manifold4w/supply/visible
		level = 2
		icon_state = "manifold4w-c"

	manifold4w/supply/hidden
		level = 1
		icon_state = "manifold4w-c-f"

	manifold4w/general/visible
		level = 2
		icon_state = "manifold4w"

	manifold4w/general/hidden
		level = 1
		icon_state = "manifold4w-f"

obj/machinery/water/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (istype(src, /obj/machinery/water/pipe/tank))
		return ..()
	if (istype(W, /obj/item/device/pda))	// allow reagent scanner to work
		return
	//if (istype(src, /obj/machinery/water/pipe/drain))
	//	return ..()
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	var/turf/T = src.loc
	if (level==1 && isturf(T) && T.intact)
		user << "\red You must remove the plating first."
		return 1
	var/datum/gas_mixture/env_air = loc.return_air()
	if ((parent.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		user << "\red You cannot unwrench this [src], it too exerted due to internal pressure."
		add_fingerprint(user)
		return 1
	playsound(src.loc, 'Ratchet.ogg', 50, 1)
	user << "\blue You begin to unfasten \the [src]..."
	if (do_after(user, 40))
		user.visible_message( \
			"[user] unfastens \the [src].", \
			"\blue You have unfastened \the [src].", \
			"You hear ratchet.")
		new /obj/item/water_pipe(loc, make_from=src)
		for (var/obj/machinery/water_meter/meter in T)
			if (meter.target == src)
				new /obj/item/water_pipe_meter(T)
				del(meter)
		del(src)
