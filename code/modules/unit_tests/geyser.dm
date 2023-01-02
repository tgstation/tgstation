///Geysers listen to reagent signals to know when to start processing, which is very cool, smart, optimized and fragile
/datum/unit_test/geyser/Run()
	//While we're at it just check em all
	var/list/geysers = subtypesof(/obj/structure/geyser)
	for(var/geyser_type as anything in geysers)
		var/obj/structure/geyser/wittel/geyser = allocate(geyser_type)
		geyser.potency = geyser.max_volume //make it recharge in 1 tick

		TEST_ASSERT(geyser.reagents, "Geyser does not have a reagent datum! Source: [geyser.type]")
		TEST_ASSERT(geyser.reagents.has_reagent(geyser.reagent_id), "Geyser should start with [geyser.reagent_id], but started with [geyser.reagents.get_reagent_log_string()] instead. Source: [geyser.type]")

		geyser.reagents.clear_reagents() //this should awaken the geyser to start refilling

		var/do_we_do_autorefill = FALSE
		var/time_passed = 0 SECONDS
		//shit can be delayed due to laggines or something, so check every 2 seconds. if it lasts longer than 30 somethings definitely fucking wrong
		while(time_passed < 30 SECONDS)
			sleep(2 SECONDS)

			time_passed += 2 SECONDS

			if(geyser.reagents.total_volume == geyser.max_volume)
				do_we_do_autorefill = TRUE
				break

		TEST_ASSERT(do_we_do_autorefill, "Geyser is not refilling! Current volume: [geyser.reagents.total_volume]. Target volume: [geyser.max_volume]. Source: [geyser.type]")
		TEST_ASSERT(geyser.reagents.has_reagent(geyser.reagent_id), "Geyser should produce [geyser.reagent_id], produced [geyser.reagents.get_reagent_log_string()] instead. Source: [geyser.type]")
