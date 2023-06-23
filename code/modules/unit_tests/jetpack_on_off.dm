/// Test if jetpacks properly turn on and off!

/datum/unit_test/jetpacks_on_off

// test
/datum/unit_test/jetpacks_on_off/Run()
	// Fun fact, I broke ion jetpacks for like a week because I didn't think to test modsuit ion jetpacks when fixing
	// a bug related to gas jetpacks -stonetear
	// Modsuits.  Is there a better way to do this?
	var/list/paths = typesof(/obj/item/mod/module/jetpack)
	for(var/obj/item/mod/module/jetpack/jetpack in paths)
		var/obj/item/mod/control/pre_equipped/mod = allocate(/obj/item/mod/control/pre_equipped) // create modsuit
		var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human) // create human
		mod.modules += jetpack // add this to the modsuit
		mod.activation_step_time = 0 // Instant?  Unit tests run faster?
		human.equip_to_slot_if_possible(mod, ITEM_SLOT_BACK) // Put modsuit on back
		mod.quick_deploy(human) // deploy modsuit
		mod.toggle_activate(human) // activate modsuit
		jetpack.on_activation() // activate the module
		var/list/sigprocs = jetpack.GetComponent(/datum/component/jetpack)._signal_procs // get the signal procs list
		var/list/sighuman = locate(/mob/living/carbon/human) in sigprocs
		TEST_ASSERT(locate(/datum/component/jetpack/proc/spacemove_react) in sighuman, "There was no spacemove_react proc inside [jetpack], this probably means you broke jetpacks.")

