/// Checks all pre-equipped MODsuit paths to see if they have something set wrong.
/datum/unit_test/modsuit_checks

/datum/unit_test/modsuit_checks/Run()
	var/list/paths = typesof(/obj/item/mod/control/pre_equipped)

	for(var/modpath in paths)
		var/obj/item/mod/control/pre_equipped/mod = new modpath()
		TEST_ASSERT(mod.theme, "[modpath] spawned without a theme.")
		var/list/modules = list()
		var/complexity_max = mod.complexity_max
		var/complexity = 0
		for(var/obj/item/mod/module/module as anything in mod.applied_modules + mod.theme.inbuilt_modules)
			module = new module()
			complexity += module.complexity
			TEST_ASSERT(complexity <= complexity_max, "[modpath] starting modules reach above max complexity.")
			TEST_ASSERT(module.has_required_parts(mod.mod_parts), "[modpath] initial module [module.type] is not supported by its parts.")
			for(var/obj/item/mod/module/module_to_check as anything in modules)
				TEST_ASSERT(!is_type_in_list(module, module_to_check.incompatible_modules), "[modpath] initial module [module.type] is incompatible with initial module [module_to_check.type]")
				TEST_ASSERT(!is_type_in_list(module_to_check, module.incompatible_modules), "[modpath] initial module [module.type] is incompatible with initial module [module_to_check.type]")
			modules += module

/datum/unit_test/mod_storage

/datum/unit_test/mod_storage/Run()
	var/mob/living/carbon/human/consistent/dummy = allocate(__IMPLIED_TYPE__)
	dummy.equipOutfit(/datum/outfit/admin)
	TEST_ASSERT(istype(dummy.back, /obj/item/mod/control/pre_equipped), "Admin outfit did not equip a MODsuit.")
	// mod storage is owned by the modsuit but the actual items are stored in the module itseslf
	var/obj/item/mod/module/storage/storage = locate() in dummy.back
	TEST_ASSERT_NOTNULL(storage, "Admin outfit MODsuit did not have a storage module.")
	TEST_ASSERT(length(storage.contents) > 0, "Admin outfit's storage module was empty.")
