SUBSYSTEM_DEF(pathogen_clouds)
	name = "Pathogen Clouds"
	init_order = INIT_ORDER_PATHOGEN
	priority = FIRE_PRIORITY_PATHOGEN
	wait = 1 SECONDS
	flags = SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/current_run_cores = list()
	var/list/current_run_clouds = list()
	var/list/cores = list()
	var/list/clouds = list()
	var/current_run_level = "clouds"


/datum/controller/subsystem/pathogen_clouds/stat_entry(msg)
	msg += "Run Cores:[length(current_run_cores)]"
	msg += "Cores:[length(cores)]"
	msg += "Run Clouds:[length(current_run_clouds)]"
	msg += "Clouds:[length(clouds)]"
	return ..()


/datum/controller/subsystem/pathogen_clouds/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/pathogen_clouds/fire(resumed = FALSE)

	if(!length(cores) && !length(clouds))
		current_run_clouds = list()
		current_run_cores = list()
		return

	if(current_run_level == "clouds")
		for(var/obj/effect/pathogen_cloud/cloud as anything in current_run_clouds)
			if(QDELETED(cloud) || isnull(cloud))
				current_run_clouds -= cloud
				continue
			//If we exist ontop of a core transfer viruses and die unless parent this means something moved back.
			//This should prevent mobs breathing in hundreds of clouds at once
			for(var/obj/effect/pathogen_cloud/core/core in cloud.loc)
				for(var/datum/disease/advanced/V as anything in cloud.viruses)
					if("[V.uniqueID]-[V.subID]" in core.id_list)
						continue
					core.viruses |= V.Copy()
					core.modified = TRUE
				qdel(cloud)
				CHECK_TICK
			current_run_clouds -= cloud
		current_run_level = "cores"
		if(!length(current_run_clouds))
			for(var/obj/effect/pathogen_cloud/cloud as anything in clouds)
				if(QDELETED(cloud))
					clouds -= cloud
			current_run_clouds = clouds.Copy()

	if(current_run_level == "cores")
		for(var/obj/effect/pathogen_cloud/core as anything in current_run_cores)
			if(QDELETED(core) || isnull(core))
				current_run_cores -= core
				continue

			if(!core.moving || core.target == get_turf(core))
				for (var/obj/effect/pathogen_cloud/core/other_C in core.loc)
					if(other_C == core)
						return
					if (!other_C.moving)
						for(var/datum/disease/advanced/V as anything in other_C.viruses)
							if("[V.uniqueID]-[V.subID]" in core.id_list)
								continue
							core.viruses |= V.Copy()
							core.modified = TRUE
						qdel(other_C)
						CHECK_TICK
				core.moving = FALSE
				current_run_cores -= core
		current_run_level = "clouds"
		if(!length(current_run_cores))
			current_run_cores = cores.Copy()
