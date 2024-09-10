/// subsystem for the fishing minigame processing.
PROCESSING_SUBSYSTEM_DEF(fishing)
	name = "Fishing"
	flags = SS_BACKGROUND|SS_POST_FIRE_TIMING
	wait = 0.05 SECONDS // If you raise it to 0.1 SECONDS, you better also modify [datum/fish_movement/move_fish()]
	///Cached fish properties so we don't have to initalize fish every time
	var/list/fish_properties
	///A cache of fish that can be caught by each type of fishing lure
	var/list/lure_catchables

/datum/controller/subsystem/processing/fishing/Initialize()
	///init the properties
	fish_properties = list()
	for(var/fish_type in subtypesof(/obj/item/fish))
		var/obj/item/fish/fish = new fish_type(null, FALSE)
		fish_properties[fish_type] = list()
		fish_properties[fish_type][FISH_PROPERTIES_FAV_BAIT] = fish.favorite_bait.Copy()
		fish_properties[fish_type][FISH_PROPERTIES_BAD_BAIT] = fish.disliked_bait.Copy()
		fish_properties[fish_type][FISH_PROPERTIES_TRAITS] = fish.fish_traits.Copy()
		qdel(fish)

	///init the list of things lures can catch
	lure_catchables = list()
	var/list/fish_types = subtypesof(/obj/item/fish)
	for(var/lure_type in typesof(/obj/item/fishing_lure))
		var/obj/item/fishing_lure/lure = new lure_type
		lure_catchables[lure_type] = list()
		for(var/obj/item/fish/fish_type as anything in fish_types)
			if(lure.is_catchable_fish(fish_type, fish_properties[fish_type]))
				lure_catchables[lure_type] += fish_type
		qdel(lure)

	return SS_INIT_SUCCESS
