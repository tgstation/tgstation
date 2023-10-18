/// Use this as a template for your own modular map templates.
/datum/lazy_template/virtual_domain/modular_test
	name = "Modular Test"
	desc = "Modular test"
	map_name = "modular_test"
	key = "modular_test"
	mob_modules = list(
		/datum/modular_mob_segment/gondolas,
		/datum/modular_mob_segment/corgis,
	)
	room_modules = list(
		/datum/map_template/modular/test1,
		/datum/map_template/modular/test2,
	)
	modular_unique_mobs = TRUE
	modular_unique_rooms = TRUE

/datum/map_template/modular/test1
	filename = "test1"
	parent_map = "modular_test"

/datum/map_template/modular/test2
	filename = "test2"
	parent_map = "modular_test"
