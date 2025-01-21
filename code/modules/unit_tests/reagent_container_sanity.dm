/// Test to ensure that all possible reagent containers have enough space to hold any reagents they spawn in with.
/// A drink can with only 30 units of space should not be able to hold 50 units of drink, as an example.
/datum/unit_test/reagent_container_sanity

/datum/unit_test/reagent_container_sanity/Run()
	for(var/entry in subtypesof(/obj/item/reagent_containers))
		var/obj/item/reagent_containers/container = allocate(entry)
		var/initialized_volume = 0
		if(!length(container.list_reagents))
			continue

		// Get the volume of the reagents in the container that we initialize with, must tally up all of the values in the associated list because checking it through
		// the reagents datum will only ever return the maximum volume of the container when "overfull" (adding 120 units to a 100 unit beaker means you only get 100 units of stuff contained).
		for(var/reagent in container.list_reagents)
			initialized_volume += container.list_reagents[reagent]

		if(initialized_volume > container.volume)
			// include the path as well here since there's up to like five "hypospray" or "beaker" or "soda water" types that aren't distinct enough to be differentiated by name alone.
			TEST_FAIL("[container] ([container.type]) has [initialized_volume] units of reagents, but only [container.volume] units of space.")
