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
			for(var/obj/obstacle in target)
				if(!obstacle.CanPass(mover, src, height, air_group))
					return 0

			return 1


var/global/datum/controller/air_system/air_master

datum
	controller
		air_system
			//Geoemetry lists
			var/list/datum/air_group/air_groups = list()
			var/list/turf/simulated/active_singletons = list()

			//Special functions lists
			var/list/turf/simulated/active_super_conductivity = list()
			var/list/turf/simulated/high_pressure_delta = list()

			//Geometry updates lists
			var/list/turf/simulated/tiles_to_update = list()
			var/list/turf/simulated/groups_to_rebuild = list()

			var/current_cycle = 0
			var/update_delay = 5 //How long between check should it try to process atmos again.


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
					if(!S.blocks_air && !S.parent && S.z < 5) // Added last check to force skipping asteroid z-levels -- TLE
						assemble_group_turf(S)
				for(var/turf/simulated/S in world) //Update all pathing and border information as well
					if(S.z > 4) // Skipping asteroids -- TLE
						continue
					S.update_air_properties()

				world << "\red \b Geometry processed in [time2text(world.timeofday-start_time, "mm:ss")] minutes!"
				spawn start()

			proc/assemble_group_turf(turf/simulated/base)
				//Purpose: Call this to try to construct a group starting from base and merging with neighboring unparented tiles
				//    (Expands the group until all valid borders explored)
				//Called by: setup()
				//Inputs: turf to flood fill from.
				//Outputs: resulting group, or null if no group is formed.

				var/list/turf/simulated/members = list(base) //Confirmed group members
				var/list/turf/simulated/possible_members = list(base) //Possible places for group expansion
				var/list/turf/simulated/possible_borders = list()
				var/list/turf/simulated/possible_space_borders = list()
				var/possible_space_length = 0

				while(possible_members.len>0) //Keep expanding, looking for new members
					for(var/turf/simulated/test in possible_members)
						test.length_space_border = 0
						for(var/direction in cardinal)
							var/turf/T = get_step(test,direction)
							if(T && !members.Find(T) && test.CanPass(null, T, null,1))
								if(istype(T,/turf/simulated) && !T:parent)
									possible_members += T
									members += T
								else if(istype(T,/turf/space))
									possible_space_borders -= test
									possible_space_borders += test
									test.length_space_border++
								else
									possible_borders -= test
									possible_borders += test
						if(test.length_space_border > 0)
							possible_space_length += test.length_space_border
						possible_members -= test

				if(members.len > 1)
					var/datum/air_group/group = new
					if(possible_borders.len>0)
						group.borders = possible_borders
					if(possible_space_borders.len>0)
						group.space_borders = possible_space_borders
						group.length_space_border = possible_space_length

					for(var/turf/simulated/test in members)
						test.parent = group
						test.processing = 0
						active_singletons -= test

					group.members = members
					air_groups += group

					group.update_group_from_tiles() //Initialize air group variables
					return group
				else
					base.processing = 0 //singletons at startup are technically unconnected anyway
					base.parent = null

					if(base.air && base.air.check_tile_graphic())
						base.update_visuals(base.air)

				return null

			proc/start()
				//Purpose: This is kicked off by the master controller, and controls the processing of all atmosphere.
				//Called by: Master controller
				//Inputs: None.
				//Outputs: None.

				set background = 1
				while(1)
					if(kill_air)
						return 1
					current_cycle++
					if(groups_to_rebuild.len > 0) //If there are groups to rebuild, do so.
						spawn process_rebuild_select_groups()

					if(tiles_to_update.len > 0) //If there are tiles to update, do so.
						for(var/turf/simulated/T in tiles_to_update)
							spawn T.update_air_properties()
						tiles_to_update = list()

					for(var/datum/air_group/AG in air_groups) //Processing groups
						spawn AG.process_group()
					for(var/turf/simulated/T in active_singletons) //Processing Singletons
						spawn T.process_cell()

					for(var/turf/simulated/hot_potato in active_super_conductivity) //Process superconduction
						spawn hot_potato.super_conduct()

					if(high_pressure_delta.len)	//Process high pressure delta (airflow)
						for(var/turf/pressurized in high_pressure_delta)
							spawn pressurized.high_pressure_movements()
						high_pressure_delta = list()

					if(current_cycle%10==5) //Check for groups of tiles to resume group processing every 10 cycles
						for(var/datum/air_group/AG in air_groups)
							spawn AG.check_regroup()
					sleep(max(5,update_delay*tick_multiplier))

			proc/process_rebuild_select_groups()
				//Purpose: This gets called to recalculate and rebuild group geometry
				//Called by: process()
				//Inputs: None.
				//Outputs: None.
				var/turf/list/turfs = list()

				for(var/datum/air_group/AG in groups_to_rebuild) //Deconstruct groups, gathering their old members
					for(var/turf/simulated/T in AG.members)
						T.parent = null
						turfs += T
					del(AG)

				for(var/turf/simulated/S in turfs) //Have old members try to form new groups
					if(!S.parent)
						assemble_group_turf(S)
				for(var/turf/simulated/S in turfs)
					S.update_air_properties()

				groups_to_rebuild = list()
