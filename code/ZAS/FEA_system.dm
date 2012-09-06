/*
Overview:
	The air_master global variable is the workhorse for the system.

Why are you archiving data before modifying it?
	The general concept with archiving data and having each tile keep track of when they were last updated is to keep everything symmetric
		and totally independent of the order they are read in an update cycle.
	This prevents abnormalities like air/fire spreading rapidly in one direction and super slowly in the other.

Why not just archive everything and then calculate?
	Efficiency. While a for-loop that goes through all tils and groups to archive their information before doing any calculations seems simple, it is
		slightly less efficient than the archive-before-modify/read method.

Why is there a cycle check for calculating data as well?
	This ensures that every connection between group-tile, tile-tile, and group-group is only evaluated once per loop.




Important variables:
	air_master.groups_to_rebuild (list)
		A list of air groups that have had their geometry occluded and thus may need to be split in half.
		A set of adjacent groups put in here will join together if validly connected.
		This is done before air system calculations for a cycle.
	air_master.tiles_to_update (list)
		Turfs that are in this list have their border data updated before the next air calculations for a cycle.
		Place turfs in this list rather than call the proc directly to prevent race conditions

	turf/simulated.archive() and datum/air_group.archive()
		This stores all data for.
		If you modify, make sure to update the archived_cycle to prevent race conditions and maintain symmetry

	atom/CanPass(atom/movable/mover, turf/target, height, air_group)
		returns 1 for allow pass and 0 for deny pass
		Turfs automatically call this for all objects/mobs in its turf.
		This is called both as source.CanPass(target, height, air_group)
			and  target.CanPass(source, height, air_group)

		Cases for the parameters
		1. This is called with args (mover, location, height>0, air_group=0) for normal objects.
		2. This is called with args (null, location, height=0, air_group=0) for flowing air.
		3. This is called with args (null, location, height=?, air_group=1) for determining group boundaries.

		Cases 2 and 3 would be different for doors or other objects open and close fairly often.
			(Case 3 would return 0 always while Case 2 would return 0 only when the door is open)
			This prevents the necessity of re-evaluating group geometry every time a door opens/closes.


Important Procedures
	air_master.process()
		This first processes the air_master update/rebuild lists then processes all groups and tiles for air calculations


*/

var/kill_air = 0
var/tick_multiplier = 2

atom/proc/CanPass(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	//Purpose: Determines if the object (or airflow) can pass this atom.
	//Called by: Movement, airflow.
	//Inputs: The moving atom (optional), target turf, "height" and air group
	//Outputs: Boolean if can pass.

	return (!density || !height || air_group)

turf
	CanPass(atom/movable/mover, turf/target, height=1.5,air_group=0)
		if(!target) return 0

		if(istype(mover)) // turf/Enter(...) will perform more advanced checks
			return !density

		else // Now, doing more detailed checks for air movement and air group formation
			if(target.blocks_air||blocks_air)
				return 0

			for(var/obj/obstacle in src)
				if(!obstacle.CanPass(mover, target, height, air_group))
					return 0
			if(target != src)
				for(var/obj/obstacle in target)
					if(!obstacle.CanPass(mover, src, height, air_group))
						return 0

			return 1


var/global/datum/controller/air_system/air_master

datum
	controller
		air_system
			//Geoemetry lists
			var/list/turfs_with_connections = list()
			var/list/active_hotspots = list()

			//Special functions lists
			var/list/tiles_to_reconsider_zones = list()

			//Geometry updates lists
			var/list/tiles_to_update = list()
			var/list/connections_to_check = list()
			var/list/rebuilds_to_consider = list()

			var/current_cycle = 0
			var/update_delay = 5 //How long between check should it try to process atmos again.
			var/failed_ticks = 0 //How many ticks have runtimed?
			var/next_stat_check = 10

			var/tick_progress = 0


/*				process()
					//Call this to process air movements for a cycle

				process_rebuild_select_groups()
					//Used by process()
					//Warning: Do not call this

				rebuild_group(datum/air_group)
					//Used by process_rebuild_select_groups()
					//Warning: Do not call this, add the group to air_master.groups_to_rebuild instead
					*/


			proc/setup()
				//Purpose: Call this at the start to setup air groups geometry
				//    (Warning: Very processor intensive but only must be done once per round)
				//Called by: Gameticker/Master controller
				//Inputs: None.
				//Outputs: None.

				set background = 1
				world << "\red \b Processing Geometry..."
				sleep(-1)

				var/start_time = world.timeofday

				for(var/turf/simulated/S in world)
					if(!S.zone && !S.blocks_air)
						if(S.CanPass(null, S, 0, 0))
							new/zone(S)

				for(var/turf/simulated/S in world)
					S.update_air_properties()

				world << "\red \b Geometry processed in [time2text(world.timeofday-start_time, "mm:ss")] minutes!"
//				spawn start()

			proc/start()
				//Purpose: This is kicked off by the master controller, and controls the processing of all atmosphere.
				//Called by: Master controller
				//Inputs: None.
				//Outputs: None.

				/*
				set background = 1

				while(1)
					if(!kill_air)
						current_cycle++
						var/success = tick() //Changed so that a runtime does not crash the ticker.
						if(!success) //Runtimed.
							failed_ticks++
							if(failed_ticks > 20)
								world << "<font color='red'><b>ERROR IN ATMOS TICKER.  Killing air simulation!</font></b>"
								kill_air = 1
					sleep(max(5,update_delay*tick_multiplier))
				*/

			proc/tick()
				. = 1 //Set the default return value, for runtime detection.

				tick_progress = "next_stat_check (atmos statistics)"
				if(current_cycle >= next_stat_check)
					var/zone/z = pick(zones)
					var/log_file = file("[time2text(world.timeofday, "statistics/DD-MM-YYYY-air.txt")]")
					log_file << "\"\The [get_area(pick(z.contents))]\",[z.air.oxygen],[z.air.nitrogen],[z.air.carbon_dioxide],[z.air.toxins],[z.air.temperature],[z.air.group_multiplier * z.air.volume]"
					next_stat_check = current_cycle + (rand(5,7)*60)

				tick_progress = "update_air_properties"
				if(tiles_to_update.len) //If there are tiles to update, do so.
					for(var/turf/simulated/T in tiles_to_update)
						var/output = T.update_air_properties()
						if(. && T && !output)
							. = 0 //If a runtime occured, make sure we can sense it.
							//message_admins("ZASALERT: Unable run turf/simualted/update_air_properties()")
					tiles_to_update = list()

				tick_progress = "reconsider_zones"
				if(rebuilds_to_consider.len)
					for(var/turf/T in rebuilds_to_consider)
						if(istype(T, /turf/simulated) && T.zone && !T.zone.rebuild)
							var/turf/simulated/other_turf = rebuilds_to_consider[T]
							if(istype(other_turf))
								ConsiderRebuild(T,other_turf)
							else if(istype(other_turf, /list))
								var/list/temp_turfs = other_turf
								for(var/turf/NT in temp_turfs)
									ConsiderRebuild(T,NT)
						else if (istype(T))
							var/turf/simulated/other_turf = rebuilds_to_consider[T]
							if(istype(other_turf))
								ConsiderRebuild(other_turf,T)
							else if(istype(other_turf, /list))
								var/list/temp_turfs = other_turf
								for(var/turf/simulated/NT in temp_turfs)
									ConsiderRebuild(NT,T)
					rebuilds_to_consider = list()

				tick_progress = "connections_to_check"
				if(connections_to_check.len)
					for(var/connection/C in connections_to_check)
						C.CheckPassSanity()
					connections_to_check = list()

				tick_progress = "tiles_to_reconsider_zones"
				if(tiles_to_reconsider_zones.len)
					for(var/turf/simulated/T in tiles_to_reconsider_zones)
						if(!T.zone)
							new /zone(T)

				tick_progress = "zone/process()"
				for(var/zone/Z in zones)
					if(Z.last_update < current_cycle)
						var/output = Z.process()
						if(Z)
							Z.last_update = current_cycle
						if(. && Z && !output)
							. = 0
							log_admin("ZASALERT: unable run zone/process(), [Z.progress]")
							message_admins("ZASALERT. ZASALERT: unable run zone/proc/process(), [Z.progress], tell someone about this!")

				tick_progress = "active_hotspots (fire)"
				for(var/obj/fire/F in active_hotspots)
					var/output = F.process()
					if(. && F && !output)
						. = 0
						//message_admins("ZASALERT: Unable run obj/fire/process()")

				tick_progress = "success"

			proc/AddToConsiderRebuild(var/turf/simulated/T, var/turf/NT)
				var/turf/existing_test = rebuilds_to_consider[T]
				var/turf/existing_test_alternate = rebuilds_to_consider[NT]

				if(existing_test)
					if(NT == existing_test)
						return
					else if(islist(existing_test) && existing_test[NT])
						return

				else if(existing_test_alternate)
					if(T == existing_test_alternate)
						return
					else if(islist(existing_test_alternate) && existing_test_alternate[T])
						return

				if(istype(T))
					if(istype(existing_test))
						var/list/temp_list = list(NT = 1, existing_test = 1)
						rebuilds_to_consider[T] = temp_list
					else if(istype(existing_test, /list))
						existing_test[NT] = 1
					else
						rebuilds_to_consider[T] = NT

				else if(istype(NT, /turf/simulated))
					if(istype(existing_test_alternate))
						var/list/temp_list = list(T = 1, existing_test_alternate = 1)
						rebuilds_to_consider[NT] = temp_list
					else if(istype(existing_test_alternate, /list))
						existing_test_alternate[T] = 1
					else
						rebuilds_to_consider[NT] = T

			proc/ConsiderRebuild(var/turf/simulated/T, var/turf/NT)

				if(istype(NT, /turf/simulated) && NT.zone != T.zone)
					T.zone.RemoveTurf(NT)
					if(NT.zone)
						NT.zone.RemoveTurf(T)
					return
				if(T.zone.rebuild)
					return

				var/zone/zone = T.zone

				var/target_dir = get_dir(T, NT)
				if(target_dir in list(NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST))
					T.zone.rebuild = 1
					return
				var/test_dir = turn(target_dir, 90)

				var/turf/simulated/current = T
				var/turf/simulated/next
				var/stepped_back = 0

				if( !(T.air_check_directions&test_dir || T.air_check_directions&turn(target_dir, 270)) )
						//Step back, then try to connect.
					if(!(T.air_check_directions&get_dir(NT, T)))
						zone.rebuild = 1
						return
					current = get_step(T, get_dir(NT, T))
					if(!istype(current) || !(current.air_check_directions&test_dir || current.air_check_directions&turn(target_dir, 270)) )
						zone.rebuild = 1
						return
					stepped_back = 1

				if ( !(current.air_check_directions&test_dir) && current.air_check_directions&turn(target_dir, 270) )
						//Try to connect to the right hand side.
					var/flipped = 0
					test_dir = turn(target_dir, 270)

					for(var/i = 1, i <= 10, i++)
						if(get_dir(current, NT) in cardinal)
							target_dir = get_dir(current, NT)

						if(!istype(current) || !(current.air_check_directions&target_dir || current.air_check_directions&test_dir))
							if(flipped)
								zone.rebuild = 1
								return
							current = T
							test_dir = turn(target_dir, 180)
							i = 0
							target_dir = get_dir(current, NT)
							flipped = 1
							continue

						if(current.air_check_directions&target_dir && !stepped_back)
							next = get_step(current, target_dir)
							if(!next.HasDoor())
								current = next

						if(current.air_check_directions&test_dir && current != next)
							next = get_step(current, test_dir)
							if(!next.HasDoor())
								current = next

						if(current == NT)
							return //We made it, yaaay~
						stepped_back = 0
						zone.rebuild = 1

				else if ( current.air_check_directions&test_dir )
						//Try to connect to the left hand side.
					for(var/i = 1, i <= 10, i++)
						if(get_dir(current, NT) in cardinal)
							target_dir = get_dir(current, NT)

						if(!istype(current) || !(current.air_check_directions&target_dir || current.air_check_directions&test_dir))
							zone.rebuild = 1
							return

						if(current.air_check_directions&target_dir && !stepped_back)
							next = get_step(current, target_dir)
							if(!next.HasDoor())
								current = next

						if(current.air_check_directions&test_dir && current != next)
							next = get_step(current, test_dir)
							if(!next.HasDoor())
								current = next

						if(current == NT)
							return //We made it, yaaay~
						stepped_back = 0
					zone.rebuild = 1

				else
					//FUCK IT
					zone.rebuild = 1