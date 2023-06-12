///Geysers listen to reagent signals to know when to start processing, which is very cool, smart, optimized and fragile
///Tests:
///	Check for reagent datum
/// Check if our geyser starts with the right reagent
/// Check if our geyser refills (by clearing the reagents, setting refresh rate to max and manually firing the subsystem)
/// Check if our geyser refilled with the right reagent
/datum/unit_test/geyser

/datum/unit_test/geyser/Run()
	//While we're at it just check em all
	var/list/geysers = subtypesof(/obj/structure/geyser)
	for(var/geyser_type as anything in geysers)
		var/obj/structure/geyser/wittel/geyser = allocate(geyser_type)
		geyser.potency = geyser.max_volume //make it recharge in 1 tick

		TEST_ASSERT(geyser.reagents, "Geyser does not have a reagent datum! Source: [geyser.type]")
		TEST_ASSERT(geyser.reagents.has_reagent(geyser.reagent_id), "Geyser should start with [geyser.reagent_id], but started with [geyser.reagents.get_reagent_log_string()] instead. Source: [geyser.type]")

		geyser.reagents.clear_reagents() //this should awaken the geyser to start refilling

		SSplumbing.fire() //fire the subsystem, which calls process on the geyser which should refill it

		TEST_ASSERT(geyser.reagents.total_volume == geyser.max_volume, "Geyser is not refilling! Current volume: [geyser.reagents.total_volume]. Target volume: [geyser.max_volume]. Source: [geyser.type]")
		TEST_ASSERT(geyser.reagents.has_reagent(geyser.reagent_id), "Geyser should produce [geyser.reagent_id], produced [geyser.reagents.get_reagent_log_string()] instead. Source: [geyser.type]")
