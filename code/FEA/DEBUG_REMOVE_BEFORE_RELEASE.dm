#define DEBUG

datum/air_group/var/marker
datum/air_group/var/debugging = 0
datum/pipe_network/var/marker

datum/gas_mixture
	var/turf/parent

/*
turf/simulated
	New()
		..()

		if(air)
			air.parent = src
*/
obj/machinery/door
	verb
		toggle_door()
			set src in world
			if(density)
				open()
			else
				close()

turf/space
	verb
		create_floor()
			set src in world
			new /turf/simulated/floor(src)

		create_meteor(direction as num)
			set src in world

			var/obj/effect/meteor/M = new( src )
			walk(M, direction,10)


turf/simulated/wall
	verb
		create_floor()
			set src in world
			new /turf/simulated/floor(src)

obj/item/weapon/tank
	verb
		adjust_mixture(temperature as num, target_toxin_pressure as num, target_oxygen_pressure as num)
			set src in world
			if(!air_contents)
				usr << "\red ERROR: no gas_mixture associated with this tank"
				return null

			air_contents.temperature = temperature
			air_contents.oxygen = target_oxygen_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)
			air_contents.toxins = target_toxin_pressure*air_contents.volume/(R_IDEAL_GAS_EQUATION*air_contents.temperature)

turf/simulated/floor
	verb
		parent_info()
			set src in world
			if(parent)
				usr << "<B>[x],[y] parent:</B> Processing: [parent.group_processing]"
				if(parent.members)
					usr << "Members: [parent.members.len]"
				else
					usr << "Members: None?"
				if(parent.borders)
					usr << "Borders: [parent.borders.len]"
				else
					usr << "Borders: None"
				if(parent.length_space_border)
					usr << "Space Borders: [parent.space_borders.len], Space Length: [parent.length_space_border]"
				else
					usr << "Space Borders: None"
			else
				usr << "\blue [x],[y] has no parent air group."

	verb
		create_wall()
			set src in world
			new /turf/simulated/wall(src)
	verb
		adjust_mixture(temp as num, tox as num, oxy as num)
			set src in world
			var/datum/gas_mixture/stuff = return_air()
			stuff.temperature = temp
			stuff.toxins = tox
			stuff.oxygen = oxy

	verb
		boom(inner_range as num, middle_range as num, outer_range as num)
			set src in world
			explosion(src,inner_range,middle_range,outer_range,outer_range)

	verb
		flag_parent()
			set src in world
			if(parent)
				parent.debugging = !parent.debugging
				usr << "[parent.members.len] set to [parent.debugging]"
	verb
		small_explosion()
			set src in world
			explosion(src, 1, 2, 3, 3)

	verb
		large_explosion()
			set src in world
			explosion(src, 3, 5, 7, 5)

obj/machinery/portable_atmospherics/canister
	verb/test_release()
		set src in world
		set category = "Minor"

		valve_open = 1
		release_pressure = 1000

obj/machinery/atmospherics
	unary
		heat_reservoir
			verb
				toggle_power()
					set src in world
					set category = "Minor"

					on = !on

					update_icon()
				adjust_temp(temp as num)
					set src in world
					set category = "Minor"

					current_temperature = temp
		cold_sink
			verb
				toggle_power()
					set src in world
					set category = "Minor"

					on = !on

					update_icon()
				adjust_temp(temp as num)
					set src in world
					set category = "Minor"

					current_temperature = temp
		vent_pump
			verb
				toggle_power()
					set src in world
					set category = "Minor"

					on = !on

					update_icon()

				toggle_direction()
					set src in world
					set category = "Minor"

					pump_direction = !pump_direction

					update_icon()

				change_pressure_parameters()
					set src in world
					set category = "Minor"

					usr << "current settings: PC=[pressure_checks], EB=[external_pressure_bound], IB=[internal_pressure_bound]"

					var/mode = input(usr, "Select an option:") in list("Bound External", "Bound Internal", "Bound Both")

					switch(mode)
						if("Bound External")
							pressure_checks = 1
							external_pressure_bound = input(usr, "External Pressure Bound?") as num
						if("Bound Internal")
							pressure_checks = 2
							internal_pressure_bound = input(usr, "Internal Pressure Bound?") as num
						else
							pressure_checks = 3
							external_pressure_bound = input(usr, "External Pressure Bound?") as num
							internal_pressure_bound = input(usr, "Internal Pressure Bound?") as num

		outlet_injector
			verb
				toggle_power()
					set src in world
					set category = "Minor"

					on = !on

					update_icon()
			verb
				trigger_inject()
					set src in world
					set category = "Minor"

					inject()

		vent_scrubber
			verb
				toggle_power()
					set src in world
					set category = "Minor"

					on = !on

					update_icon()

				toggle_scrubbing()
					set src in world
					set category = "Minor"

					scrubbing = !scrubbing

					update_icon()

				change_rate(amount as num)
					set src in world
					set category = "Minor"

					volume_rate = amount

	mixer
		verb
			toggle()
				set src in world
				set category = "Minor"

				on = !on

				update_icon()

			change_pressure(amount as num)
				set src in world
				set category = "Minor"

				target_pressure = amount

			change_ratios()
				set src in world
				set category = "Minor"

				if(node_in1)
					var/node_ratio = input(usr, "Node 1 Ratio? ([dir2text(get_dir(src, node_in1))])") as num
					node_ratio = min(max(0,node_ratio),1)

					node1_concentration = node_ratio
					node2_concentration = 1-node_ratio
				else
					node2_concentration = 1
					node1_concentration = 0

				usr << "Node 1: [node1_concentration], Node 2: [node2_concentration]"


	filter
		verb
			toggle()
				set src in world
				set category = "Minor"

				on = !on

				update_icon()

			change_pressure(amount as num)
				set src in world
				set category = "Minor"

				target_pressure = amount

	unary/oxygen_generator
		verb
			toggle()
				set src in world
				set category = "Minor"

				on = !on

				update_icon()

			change_rate(amount as num)
				set src in world
				set category = "Minor"

				oxygen_content = amount
	binary/pump
		verb
			debug()
				set src in world
				set category = "Minor"

				world << "Debugging: [x],[y]"

				if(node1)
					world << "Input node: [node1.x],[node1.y] [network1]"
				if(node2)
					world << "Output node: [node2.x],[node2.y] [network2]"

			toggle()
				set src in world
				set category = "Minor"

				on = !on

				update_icon()
			change_pressure(amount as num)
				set src in world
				set category = "Minor"

				target_pressure = amount

	valve
		verb
			toggle()
				set src in world
				set category = "Minor"

				if(open)
					close()
				else
					open()
			network_data()
				set src in world
				set category = "Minor"

				world << "\blue [x],[y]"
				world << "network 1: [network_node1.normal_members.len], [network_node1.line_members.len]"
				for(var/obj/O in network_node1.normal_members)
					world << "member: [O.x], [O.y]"
				world << "network 2: [network_node2.normal_members.len], [network_node2.line_members.len]"
				for(var/obj/O in network_node2.normal_members)
					world << "member: [O.x], [O.y]"
	pipe
		verb
			destroy()
				set src in world
				set category = "Minor"

				del(src)

			pipeline_data()
				set src in world
				set category = "Minor"

				if(parent)
					usr << "[x],[y] is in a pipeline with [parent.members.len] members ([parent.edges.len] edges)! Volume: [parent.air.volume]"
					usr << "Pressure: [parent.air.return_pressure()], Temperature: [parent.air.temperature]"
					usr << "[parent.air.oxygen], [parent.air.toxins], [parent.air.nitrogen], [parent.air.carbon_dioxide] .. [parent.alert_pressure]"
mob
	verb
		flag_all_pipe_networks()
			set category = "Debug"

			for(var/datum/pipe_network/network in pipe_networks)
				network.update = 1

		mark_pipe_networks()
			set category = "Debug"

			for(var/datum/pipe_network/network in pipe_networks)
				network.marker = rand(1,4)

			for(var/obj/machinery/atmospherics/pipe/P in world)
				P.overlays = null

				var/datum/pipe_network/master = P.return_network()
				if(master)
					P.overlays += icon('atmos_testing.dmi',"marker[master.marker]")
				else
					world << "error"
					P.overlays += icon('atmos_testing.dmi',"marker0")

			for(var/obj/machinery/atmospherics/valve/V in world)
				V.overlays = null

				if(V.network_node1)
					V.overlays += icon('atmos_testing.dmi',"marker[V.network_node1.marker]")
				else
					V.overlays += icon('atmos_testing.dmi',"marker0")

				if(V.network_node2)
					V.overlays += icon('atmos_testing.dmi',"marker[V.network_node2.marker]")
				else
					V.overlays += icon('atmos_testing.dmi',"marker0")

turf/simulated
	var/fire_verbose = 0

	verb
		mark_direction()
			set src in world
			overlays = null
			for(var/direction in list(NORTH,SOUTH,EAST,WEST))
				if(group_border&direction)
					overlays += icon('turf_analysis.dmi',"red_arrow",direction)
				else if(air_check_directions&direction)
					overlays += icon('turf_analysis.dmi',"arrow",direction)
		air_status()
			set src in world
			set category = "Minor"
			var/datum/gas_mixture/GM = return_air()
			usr << "\blue @[x],[y] ([GM.group_multiplier]): O:[GM.oxygen] T:[GM.toxins] N:[GM.nitrogen] C:[GM.carbon_dioxide] w [GM.temperature] Kelvin, [GM.return_pressure()] kPa [(active_hotspot)?("\red BURNING"):(null)]"
			for(var/datum/gas/trace_gas in GM.trace_gases)
				usr << "[trace_gas.type]: [trace_gas.moles]"

		force_temperature(temp as num)
			set src in world
			set category = "Minor"
			if(parent&&parent.group_processing)
				parent.suspend_group_processing()

			air.temperature = temp

		spark_temperature(temp as num, volume as num)
			set src in world
			set category = "Minor"

			hotspot_expose(temp, volume)

		fire_verbose()
			set src in world
			set category = "Minor"

			fire_verbose = !fire_verbose
			usr << "[x],[y] now [fire_verbose]"

		add_sleeping_agent(amount as num)
			set src in world
			set category = "Minor"

			if(amount>1)
				var/datum/gas_mixture/adding = new
				var/datum/gas/sleeping_agent/trace_gas = new

				trace_gas.moles = amount
				adding.trace_gases += trace_gas
				adding.temperature = T20C

				assume_air(adding)

obj/indicator
	icon = 'air_meter.dmi'
	var/measure = "temperature"
	anchored = 1

	process()
		icon_state = measurement()

	proc/measurement()
		var/turf/T = loc
		if(!isturf(T)) return
		var/datum/gas_mixture/GM = T.return_air()
		switch(measure)
			if("temperature")
				if(GM.temperature < 0)
					return "error"
				return "[round(GM.temperature/100+0.5)]"
			if("oxygen")
				if(GM.oxygen < 0)
					return "error"
				return "[round(GM.oxygen/MOLES_CELLSTANDARD*10+0.5)]"
			if("plasma")
				if(GM.toxins < 0)
					return "error"
				return "[round(GM.toxins/MOLES_CELLSTANDARD*10+0.5)]"
			if("nitrogen")
				if(GM.nitrogen < 0)
					return "error"
				return "[round(GM.nitrogen/MOLES_CELLSTANDARD*10+0.5)]"
			else
				return "[round((GM.total_moles())/MOLES_CELLSTANDARD*10+0.5)]"


	Click()
		process()


obj/window
	verb
		destroy()
			set category = "Minor"
			set src in world
			del(src)

mob
	sight = SEE_OBJS|SEE_TURFS

	verb
		update_indicators()
			set category = "Debug"
			if(!air_master)
				usr << "Cannot find air_system"
				return

			for(var/obj/indicator/T in world)
				T.process()
		change_indicators()
			set category = "Debug"
			if(!air_master)
				usr << "Cannot find air_system"
				return

			var/str = input("Select") in list("oxygen", "nitrogen","plasma","all","temperature")

			for(var/obj/indicator/T in world)
				T.measure = str
				T.process()

		fire_report()
			set category = "Debug"
			usr << "\b \red Fire Report"
			for(var/obj/effect/hotspot/flame in world)
				usr << "[flame.x],[flame.y]: [flame.temperature]K, [flame.volume] L - [flame.loc:air:temperature]"

		process_cycle()
			set category = "Debug"
			if(!master_controller)
				usr << "Cannot find master_controller"
				return

			master_controller.process()
			update_indicators()

		process_cycles(amount as num)
			set category = "Debug"
			if(!master_controller)
				usr << "Cannot find master_controller"
				return

			var/start_time = world.timeofday

			for(var/i=1; i<=amount; i++)
				master_controller.process()

			world << "Ended [amount] cycles in [(world.timeofday-start_time)/10] seconds. [(world.timeofday-start_time)/10-amount] calculation lag"

			update_indicators()

		process_updates_early()
			set category = "Debug"
			if(!air_master)
				usr << "Cannot find air_system"
				return

			air_master.process_update_tiles()
			air_master.process_rebuild_select_groups()

		mark_group_delay()
			set category = "Debug"
			if(!air_master)
				usr << "Cannot find air_system"
				return

			for(var/datum/air_group/group in air_master.air_groups)
				group.marker = 0

			for(var/turf/simulated/floor/S in world)
				S.icon = 'turf_analysis.dmi'
				if(S.parent)
					if(S.parent.group_processing)
						if (S.parent.check_delay < 2)
							S.parent.marker=1
						else if (S.parent.check_delay < 5)
							S.parent.marker=2
						else if (S.parent.check_delay < 15)
							S.parent.marker=3
						else if (S.parent.check_delay < 30)
							S.parent.marker=4
						else
							S.parent.marker=5
						if(S.parent.borders && S.parent.borders.Find(S))
							S.icon_state = "on[S.parent.marker]_border"
						else
							S.icon_state = "on[S.parent.marker]"

					else
						if (S.check_delay < 2)
							S.icon_state= "on1_border"
						else if (S.check_delay < 5)
							S.icon_state= "on2_border"
						else if (S.check_delay < 15)
							S.icon_state= "on3_border"
						else if (S.check_delay < 30)
							S.icon_state= "on4_border"
						else
							S.icon_state = "suspended"
				else
					if(S.processing)
						S.icon_state = "individual_on"
					else
						S.icon_state = "individual_off"


		mark_groups()
			set category = "Debug"
			if(!air_master)
				usr << "Cannot find air_system"
				return

			for(var/datum/air_group/group in air_master.air_groups)
				group.marker = 0

			for(var/turf/simulated/floor/S in world)
				S.icon = 'turf_analysis.dmi'
				if(S.parent)
					if(S.parent.group_processing)
						if(S.parent.marker == 0)
							S.parent.marker = rand(1,5)
						if(S.parent.borders && S.parent.borders.Find(S))
							S.icon_state = "on[S.parent.marker]_border"
						else
							S.icon_state = "on[S.parent.marker]"

					else
						S.icon_state = "suspended"
				else
					if(S.processing)
						S.icon_state = "individual_on"
					else
						S.icon_state = "individual_off"

		get_broken_icons()
			set category = "Debug"
			getbrokeninhands()


/*		jump_to_dead_group() Currently in the normal admin commands but fits here
			set category = "Debug"
			if(!air_master)
				usr << "Cannot find air_system"
				return

			var/datum/air_group/dead_groups = list()
			for(var/datum/air_group/group in air_master.air_groups)
				if (!group.group_processing)
					dead_groups += group
			var/datum/air_group/dest_group = pick(dead_groups)
			usr.loc = pick(dest_group.members)*/
