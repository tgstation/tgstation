/obj/loop_spawner
	name = "testing loop spawner"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "unloader"
	anchored = TRUE
	color = COLOR_PURPLE
	/// directions we can output to right now
	var/to_spawn = /obj/item/screwdriver
	/// the subsystem to process us
	var/subsystem_to_process_us = /datum/controller/subsystem/processing/obj

/obj/loop_spawner/Initialize(mapload)
	. = ..()
	var/datum/controller/subsystem/processing/subsystem = locate(subsystem_to_process_us) in Master.subsystems
	START_PROCESSING(subsystem, src)

/obj/loop_spawner/process(seconds_per_tick)
	new to_spawn(get_step(src, dir))
