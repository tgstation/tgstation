/datum/unit_test/modsuit_checks/Run()
	var/list/paths = typesof(/obj/item/mod/control/pre_equipped)

	for(var/modpath in paths)
		var/obj/item/mod/control/mod = new modpath()
		TEST_ASSERT(mod.theme, "[modpath] spawned without a theme.")
		TEST_ASSERT(mod.helmet, "[modpath] spawned without a helmet.")
		TEST_ASSERT(mod.chestplate, "[modpath] spawned without a chestplate.")
		TEST_ASSERT(mod.gauntlets, "[modpath] spawned without gauntlets.")
		TEST_ASSERT(mod.boots, "[modpath] spawned without boots.")
		var/list/modules = list()
		var/complexity_max = mod.complexity_max
		var/complexity = 0
		for(var/obj/item/mod/module/module as anything in mod.initial_modules)
			module = new module()
			modules += module
			complexity += module.complexity
			TEST_ASSERT(!is_type_in_list(module, mod.theme.module_blacklist), "[modpath] starting modules are in [mod.theme.type] blacklist.")
			TEST_ASSERT(complexity <= complexity_max, "[modpath] starting modules reach above max complexity.")
			for(var/obj/item/mod/module/module_to_check as anything in modules)
				TEST_ASSERT(!(is_type_in_list(module, module_to_check.incompatible_modules) || is_type_in_list(module_to_check, module.incompatible_modules)), "[modpath] initial module [module.type] is incompatible with initial module [module_to_check.type]")

