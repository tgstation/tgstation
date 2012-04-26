obj/machinery/atmospherics/pipe

	var/datum/gas_mixture/air_temporary //used when reconstructing a pipeline that broke
	var/datum/pipeline/parent

	var/volume = 0
	var/force = 20

	layer = 2.4 //under wires with their 2.44

	var/alert_pressure = 80*ONE_ATMOSPHERE
		//minimum pressure before check_pressure(...) should be called

	proc/pipeline_expansion()
		return null

	proc/check_pressure(pressure)
		//Return 1 if parent should continue checking other pipes
		//Return null if parent should stop checking other pipes. Recall: del(src) will by default return null

		return 1

	return_air()
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.air

	build_network()
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.return_network()

	network_expand(datum/pipe_network/new_network, obj/machinery/atmospherics/pipe/reference)
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.network_expand(new_network, reference)

	return_network(obj/machinery/atmospherics/reference)
		if(!parent)
			parent = new /datum/pipeline()
			parent.build_pipeline(src)

		return parent.return_network(reference)

	Del()
		del(parent)
		if(air_temporary)
			loc.assume_air(air_temporary)

		..()

	simple
		icon = 'pipes.dmi'
		icon_state = "intact-f"

		name = "pipe"
		desc = "A one meter section of regular pipe"

		volume = 70

		dir = SOUTH
		initialize_directions = SOUTH|NORTH

		var/obj/machinery/atmospherics/node1
		var/obj/machinery/atmospherics/node2

		var/minimum_temperature_difference = 300
		var/thermal_conductivity = 0 //WALL_HEAT_TRANSFER_COEFFICIENT No

		var/maximum_pressure = 70*ONE_ATMOSPHERE
		var/fatigue_pressure = 55*ONE_ATMOSPHERE
		alert_pressure = 55*ONE_ATMOSPHERE


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

			if(pressure_difference > maximum_pressure)
				burst()

			else if(pressure_difference > fatigue_pressure)
				//TODO: leak to turf, doing pfshhhhh
				if(prob(5))
					burst()

			else return 1

		proc/burst()
			src.visible_message("\red \bold [src] bursts!");
			playsound(src.loc, 'bang.ogg', 25, 1)
			var/datum/effect/effect/system/harmless_smoke_spread/smoke = new
			smoke.set_up(1,0, src.loc, 0)
			smoke.start()
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

			for(var/obj/machinery/atmospherics/target in get_step(src,node1_dir))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break
			for(var/obj/machinery/atmospherics/target in get_step(src,node2_dir))
				if(target.initialize_directions & get_dir(target,src))
					node2 = target
					break


			var/turf/T = src.loc			// hide if turf is not intact
			hide(T.intact)
			update_icon()
			//update_icon()

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/atmospherics/pipe))
					del(parent)
				node1 = null

			if(reference == node2)
				if(istype(node2, /obj/machinery/atmospherics/pipe))
					del(parent)
				node2 = null

			update_icon()

			return null

	simple/scrubbers
		name="Scrubbers pipe"
		color="red"
		icon_state = ""
		initialize()
			..()
			if(istype(node1, /obj/machinery/atmospherics/pipe/simple/supply) || istype(node1, /obj/machinery/atmospherics/pipe/simple/supply))
				log_admin("Warning, scrubber pipeline connected to supply pipeline at [x], [y], [z]!")

	simple/supply
		name="Air supply pipe"
		color="blue"
		icon_state = ""
		initialize()
			..()
			if(istype(node1, /obj/machinery/atmospherics/pipe/simple/scrubbers) || istype(node1, /obj/machinery/atmospherics/pipe/simple/scrubbers))
				log_admin("Warning, supply  pipeline connected to scrubber pipeline at [x], [y], [z]!")

	simple/supplymain
		name="Main air supply pipe"
		color="purple"
		icon_state = ""

	simple/general
		name="Pipe"
		color=""
		icon_state = ""

	simple/scrubbers/visible
		level = 2
		icon_state = "intact-r"

	simple/scrubbers/hidden
		level = 1
		icon_state = "intact-r-f"

	simple/supply/visible
		level = 2
		icon_state = "intact-b"

	simple/supply/hidden
		level = 1
		icon_state = "intact-b-f"

	simple/supplymain/visible
		level = 2
		icon_state = "intact-p"

	simple/supplymain/hidden
		level = 1
		icon_state = "intact-p-f"

	simple/general/visible
		level = 2
		icon_state = "intact"

	simple/general/hidden
		level = 1
		icon_state = "intact-f"



	simple/insulated
		icon = 'red_pipe.dmi'
		icon_state = "intact"

		minimum_temperature_difference = 10000
		thermal_conductivity = 0
		maximum_pressure = 1000*ONE_ATMOSPHERE
		fatigue_pressure = 900*ONE_ATMOSPHERE
		alert_pressure = 900*ONE_ATMOSPHERE

		level = 2


	tank
		icon = 'pipe_tank.dmi'
		icon_state = "intact"

		name = "Pressure Tank"
		desc = "A large vessel containing pressurized gas."

		volume = 1620 //in liters, 0.9 meters by 0.9 meters by 2 meters

		dir = SOUTH
		initialize_directions = SOUTH
		density = 1

		var/obj/machinery/atmospherics/node1

		New()
			initialize_directions = dir
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
		carbon_dioxide
			name = "Pressure Tank (Carbon Dioxide)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.carbon_dioxide = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		toxins
			icon = 'orange_pipe_tank.dmi'
			name = "Pressure Tank (Plasma)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.toxins = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		oxygen
			icon = 'blue_pipe_tank.dmi'
			name = "Pressure Tank (Oxygen)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.oxygen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		nitrogen
			icon = 'red_pipe_tank.dmi'
			name = "Pressure Tank (Nitrogen)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.nitrogen = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		air
			icon = 'red_pipe_tank.dmi'
			name = "Pressure Tank (Air)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T20C

				air_temporary.oxygen = (25*ONE_ATMOSPHERE*O2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
				air_temporary.nitrogen = (25*ONE_ATMOSPHERE*N2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				..()

		n2o
			icon = 'n2o_pipe_tank.dmi'
			name = "Pressure Tank (N2O)"

			New()
				air_temporary = new
				air_temporary.volume = volume
				air_temporary.temperature = T0C

				var/datum/gas/sleeping_agent/trace_gas = new
				trace_gas.moles = (25*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

				air_temporary.trace_gases += trace_gas

				..()


		highcap
			carbon_dioxide
				name = "High Capacity Pressure Tank (Carbon Dioxide)"

				New()
					air_temporary = new
					air_temporary.volume = volume
					air_temporary.temperature = T20C

					air_temporary.carbon_dioxide = (160*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

					..()

			toxins
				icon = 'orange_pipe_tank.dmi'
				name = "High Capacity Pressure Tank (Plasma)"

				New()
					air_temporary = new
					air_temporary.volume = volume
					air_temporary.temperature = T20C

					air_temporary.toxins = (160*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

					..()

			oxygen_agent_b
				icon = 'red_orange_pipe_tank.dmi'
				name = "High Capacity Pressure Tank (Oxygen + Plasma)"

				New()
					air_temporary = new
					air_temporary.volume = volume
					air_temporary.temperature = T0C

					var/datum/gas/oxygen_agent_b/trace_gas = new
					trace_gas.moles = (160*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

					air_temporary.trace_gases += trace_gas

					..()

			oxygen
				icon = 'blue_pipe_tank.dmi'
				name = "High Capacity Pressure Tank (Oxygen)"

				New()
					air_temporary = new
					air_temporary.volume = volume
					air_temporary.temperature = T20C

					air_temporary.oxygen = (160*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

					..()

			nitrogen
				icon = 'red_pipe_tank.dmi'
				name = "High Capacity Pressure Tank (Nitrogen)"

				New()
					air_temporary = new
					air_temporary.volume = volume
					air_temporary.temperature = T20C

					air_temporary.nitrogen = (160*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

					..()

			air
				icon = 'red_pipe_tank.dmi'
				name = "High Capacity Pressure Tank (Air)"

				New()
					air_temporary = new
					air_temporary.volume = volume
					air_temporary.temperature = T20C

					air_temporary.oxygen = (160*ONE_ATMOSPHERE*O2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)
					air_temporary.nitrogen = (160*ONE_ATMOSPHERE*N2STANDARD)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

					..()

			n2o
				icon = 'n2o_pipe_tank.dmi'
				name = "High Capacity Pressure Tank (N2O)"

				New()
					air_temporary = new
					air_temporary.volume = volume
					air_temporary.temperature = T0C

					var/datum/gas/sleeping_agent/trace_gas = new
					trace_gas.moles = (160*ONE_ATMOSPHERE)*(air_temporary.volume)/(R_IDEAL_GAS_EQUATION*air_temporary.temperature)

					air_temporary.trace_gases += trace_gas

					..()



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

			for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			update_icon()

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/atmospherics/pipe))
					del(parent)
				node1 = null

			update_icon()

			return null

		attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
			if (istype(W, /obj/item/device/analyzer) && get_dist(user, src) <= 1)
				for (var/mob/O in viewers(user, null))
					O << "\red [user] has used the analyzer on \icon[icon]"

				var/pressure = parent.air.return_pressure()
				var/total_moles = parent.air.total_moles

				user << "\blue Results of analysis of \icon[icon]"
				if (total_moles>0)
					var/o2_concentration = parent.air.oxygen/total_moles
					var/n2_concentration = parent.air.nitrogen/total_moles
					var/co2_concentration = parent.air.carbon_dioxide/total_moles
					var/plasma_concentration = parent.air.toxins/total_moles

					var/unknown_concentration =  1-(o2_concentration+n2_concentration+co2_concentration+plasma_concentration)

					user << "\blue Pressure: [round(pressure,0.1)] kPa"
					user << "\blue Nitrogen: [round(n2_concentration*100)]%"
					user << "\blue Oxygen: [round(o2_concentration*100)]%"
					user << "\blue CO2: [round(co2_concentration*100)]%"
					user << "\blue Plasma: [round(plasma_concentration*100)]%"
					if(unknown_concentration>0.01)
						user << "\red Unknown: [round(unknown_concentration*100)]%"
					user << "\blue Temperature: [round(parent.air.temperature-T0C)]&deg;C"
				else
					user << "\blue Tank is empty!"

	vent
		icon = 'pipe_vent.dmi'
		icon_state = "intact"

		name = "Vent"
		desc = "A large air vent"

		level = 1

		volume = 250

		dir = SOUTH
		initialize_directions = SOUTH

		var/build_killswitch = 1

		var/obj/machinery/atmospherics/node1
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
				parent.mingle_with_turf(loc, 250)
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

			for(var/obj/machinery/atmospherics/target in get_step(src,connect_direction))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			update_icon()

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/atmospherics/pipe))
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

	manifold
		icon = 'pipe_manifold.dmi'
		icon_state = "manifold-f"

		name = "pipe manifold"
		desc = "A manifold composed of regular pipes"

		volume = 105

		dir = SOUTH
		initialize_directions = EAST|NORTH|WEST

		var/obj/machinery/atmospherics/node1
		var/obj/machinery/atmospherics/node2
		var/obj/machinery/atmospherics/node3

		level = 1
		layer = 2.4 //under wires with their 2.44

		New()
			switch(dir)
				if(NORTH)
					initialize_directions = EAST|SOUTH|WEST
				if(SOUTH)
					initialize_directions = WEST|NORTH|EAST
				if(EAST)
					initialize_directions = SOUTH|WEST|NORTH
				if(WEST)
					initialize_directions = NORTH|EAST|SOUTH

			..()



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

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/atmospherics/pipe))
					del(parent)
				node1 = null

			if(reference == node2)
				if(istype(node2, /obj/machinery/atmospherics/pipe))
					del(parent)
				node2 = null

			if(reference == node3)
				if(istype(node3, /obj/machinery/atmospherics/pipe))
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
					for(var/obj/machinery/atmospherics/target in get_step(src,direction))
						if(target.initialize_directions & get_dir(target,src))
							node1 = target
							connect_directions &= ~direction
							break
					if (node1)
						break


			for(var/direction in cardinal)
				if(direction&connect_directions)
					for(var/obj/machinery/atmospherics/target in get_step(src,direction))
						if(target.initialize_directions & get_dir(target,src))
							node2 = target
							connect_directions &= ~direction
							break
					if (node2)
						break


			for(var/direction in cardinal)
				if(direction&connect_directions)
					for(var/obj/machinery/atmospherics/target in get_step(src,direction))
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

	manifold/scrubbers
		name="Scrubbers pipe"
		color="red"
		icon_state = ""

	manifold/supply
		name="Air supply pipe"
		color="blue"
		icon_state = ""

	manifold/supplymain
		name="Main air supply pipe"
		color="purple"
		icon_state = ""

	manifold/general
		name="Air supply pipe"
		color="gray"
		icon_state = ""

	manifold/scrubbers/visible
		level = 2
		icon_state = "manifold-r"

	manifold/scrubbers/hidden
		level = 1
		icon_state = "manifold-r-f"

	manifold/supply/visible
		level = 2
		icon_state = "manifold-b"

	manifold/supply/hidden
		level = 1
		icon_state = "manifold-b-f"

	manifold/supplymain/visible
		level = 2
		icon_state = "manifold-p"

	manifold/supplymain/hidden
		level = 1
		icon_state = "manifold-p-f"

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
		desc = "A manifold composed of regular pipes"

		volume = 140

		dir = SOUTH
		initialize_directions = EAST|NORTH|WEST|SOUTH

		var/obj/machinery/atmospherics/node1
		var/obj/machinery/atmospherics/node2
		var/obj/machinery/atmospherics/node3
		var/obj/machinery/atmospherics/node4

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

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node1)
				if(istype(node1, /obj/machinery/atmospherics/pipe))
					del(parent)
				node1 = null

			if(reference == node2)
				if(istype(node2, /obj/machinery/atmospherics/pipe))
					del(parent)
				node2 = null

			if(reference == node3)
				if(istype(node3, /obj/machinery/atmospherics/pipe))
					del(parent)
				node3 = null

			if(reference == node4)
				if(istype(node4, /obj/machinery/atmospherics/pipe))
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
			for(var/obj/machinery/atmospherics/target in get_step(src,1))
				if(target.initialize_directions & get_dir(target,src))
					node1 = target
					break

			for(var/obj/machinery/atmospherics/target in get_step(src,2))
				if(target.initialize_directions & get_dir(target,src))
					node2 = target
					break

			for(var/obj/machinery/atmospherics/target in get_step(src,4))
				if(target.initialize_directions & get_dir(target,src))
					node3 = target
					break

			for(var/obj/machinery/atmospherics/target in get_step(src,8))
				if(target.initialize_directions & get_dir(target,src))
					node4 = target
					break

			var/turf/T = src.loc			// hide if turf is not intact
			hide(T.intact)
			//update_icon()
			update_icon()

	manifold4w/scrubbers
		name="Scrubbers pipe"
		color="red"
		icon_state = ""

	manifold4w/supply
		name="Air supply pipe"
		color="blue"
		icon_state = ""

	manifold4w/supplymain
		name="Main air supply pipe"
		color="purple"
		icon_state = ""

	manifold4w/general
		name="Air supply pipe"
		color="gray"
		icon_state = ""

	manifold4w/scrubbers/visible
		level = 2
		icon_state = "manifold4w-r"

	manifold4w/scrubbers/hidden
		level = 1
		icon_state = "manifold4w-r-f"

	manifold4w/supply/visible
		level = 2
		icon_state = "manifold4w-b"

	manifold4w/supply/hidden
		level = 1
		icon_state = "manifold4w-b-f"

	manifold4w/supplymain/visible
		level = 2
		icon_state = "manifold4w-p"

	manifold4w/supplymain/hidden
		level = 1
		icon_state = "manifold4w-p-f"

	manifold4w/general/visible
		level = 2
		icon_state = "manifold4w"

	manifold4w/general/hidden
		level = 1
		icon_state = "manifold4w-f"

	cap
		name = "pipe endcap"
		desc = "An endcap for pipes"
		icon = 'pipes.dmi'
		icon_state = "cap"
		level = 2

		volume = 35

		dir = SOUTH
		initialize_directions = NORTH

		var/obj/machinery/atmospherics/node

		New()
			..()
			switch(dir)
				if(SOUTH)
				 initialize_directions = NORTH
				if(NORTH)
				 initialize_directions = SOUTH
				if(WEST)
				 initialize_directions = EAST
				if(EAST)
				 initialize_directions = WEST

		hide(var/i)
			if(level == 1 && istype(loc, /turf/simulated))
				invisibility = i ? 101 : 0
			update_icon()

		pipeline_expansion()
			return list(node)

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
			if(node)
				node.disconnect(src)

			..()

		disconnect(obj/machinery/atmospherics/reference)
			if(reference == node)
				if(istype(node, /obj/machinery/atmospherics/pipe))
					del(parent)
				node = null

			update_icon()

			..()

		update_icon()
			overlays = new()

			icon_state = "cap[invisibility ? "-f" : ""]"
			return

		initialize()
			for(var/obj/machinery/atmospherics/target in get_step(src, dir))
				if(target.initialize_directions & get_dir(target,src))
					node = target
					break

			var/turf/T = src.loc			// hide if turf is not intact
			hide(T.intact)
			//update_icon()
			update_icon()

		visible
			level = 2
			icon_state = "cap"

		hidden
			level = 1
			icon_state = "cap-f"

obj/machinery/atmospherics/pipe/attackby(var/obj/item/weapon/W as obj, var/mob/user as mob)
	if (istype(src, /obj/machinery/atmospherics/pipe/tank))
		return ..()
	if (istype(src, /obj/machinery/atmospherics/pipe/vent))
		return ..()
	if (!istype(W, /obj/item/weapon/wrench))
		return ..()
	var/turf/T = src.loc
	if (level==1 && isturf(T) && T.intact)
		user << "\red You must remove the plating first."
		return 1
	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()
	if ((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
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
		new /obj/item/pipe(loc, make_from=src)
		for (var/obj/machinery/meter/meter in T)
			if (meter.target == src)
				new /obj/item/pipe_meter(T)
				del(meter)
		del(src)