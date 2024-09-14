///thats amoreeeeee
/datum/shuttle_event/simple_spawner/italian
	name = "Italian Storm! (Mama Mia!)"
	event_probability = 0.05

	spawns_per_spawn = 5
	spawning_flags = SHUTTLE_EVENT_MISS_SHUTTLE | SHUTTLE_EVENT_HIT_SHUTTLE
	spawn_probability_per_process = 100
	spawning_list = list(/obj/item/food/spaghetti/boiledspaghetti = 5, /obj/item/food/meatball = 1, /obj/item/food/spaghetti/pastatomato = 2,
		/obj/item/food/spaghetti/meatballspaghetti = 2, /obj/item/food/pizza/margherita = 1)

///We do a little bit of tomfoolery
/datum/shuttle_event/simple_spawner/fake_ttv
	name = "Fake TTV (Harmless!)"
	event_probability = 0.5
	activation_fraction = 0.1

	spawning_list = list(/obj/item/transfer_valve/fake = 1)
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE
	spawn_probability_per_process = 5

	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

///Just spawn random maint garbage
/datum/shuttle_event/simple_spawner/maintenance
	name = "Maintenance Debris (Harmless!)"
	event_probability = 3
	activation_fraction = 0.1

	spawning_list = list()
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE | SHUTTLE_EVENT_MISS_SHUTTLE
	spawn_probability_per_process = 100
	spawns_per_spawn = 2

/datum/shuttle_event/simple_spawner/maintenance/get_type_to_spawn()
	var/list/spawn_list = GLOB.maintenance_loot
	while(islist(spawn_list))
		spawn_list = pick_weight(spawn_list)
	return spawn_list

///Sensors indicate that a black hole's gravitational field is affecting the region of space we were headed through
/datum/shuttle_event/simple_spawner/black_hole
	name = "Black Hole (Oh no! Just one though!)"
	event_probability = 0 // only admin spawnable
	spawn_probability_per_process = 10
	activation_fraction = 0.35
	spawning_flags = SHUTTLE_EVENT_HIT_SHUTTLE
	spawning_list = list(/obj/singularity/shuttle_event = 1)
	// only spawn it once
	remove_from_list_when_spawned = TRUE
	self_destruct_when_empty = TRUE

///Kobayashi Maru version
/datum/shuttle_event/simple_spawner/black_hole/adminbus
	name = "Black Holes (OH GOD! Will literally kill everyone!)"
	event_probability = 0
	spawn_probability_per_process = 50
	activation_fraction = 0.2
	spawning_list = list(/obj/singularity/shuttle_event = 10)
	remove_from_list_when_spawned = TRUE

