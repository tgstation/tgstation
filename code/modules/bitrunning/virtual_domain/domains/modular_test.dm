/// Use this as a template for your own modular map templates.
/datum/lazy_template/virtual_domain/modular_test
	name = "Modular Test"
	desc = "Modular test"
	map_name = "modular_test"
	key = "modular_test"
	is_modular = TRUE
	mob_modules = list(
		/datum/modular_mob_segment/gondolas,
		/datum/modular_mob_segment/corgis,
	)
	modular_unique_mobs = TRUE
	// test_only = TRUE
