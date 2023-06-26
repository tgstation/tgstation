SUBSYSTEM_DEF(ore_generation)
	name = "Ore_generation"
	wait = 5 MINUTES
	init_order = INIT_ORDER_DEFAULT
	runlevels = RUNLEVEL_GAME
	flags = SS_NO_INIT

	var/list/processed_vents = list()



/datum/controller/subsystem/ore_generation/fire(resumed)
	for(var/vent in processed_vents)
		var/obj/structure/ore_vent/current_vent = vent
		var/obj/item/boulder/new_rock = new (current_vent.loc)
		var/list/mats_list = current_vent.create_mineral_contents()
		current_vent.Shake(duration = 1.5 SECONDS)
		new_rock.set_custom_materials(mats_list)
