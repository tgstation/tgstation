/// subsystem for the fishing minigame processing.
PROCESSING_SUBSYSTEM_DEF(fishing)
	name = "Fishing"
	dependencies = list(
		/datum/controller/subsystem/atoms,
	)
	flags = SS_BACKGROUND
	wait = 0.05 SECONDS // If you raise it to 0.1 SECONDS, you better also modify [datum/fish_movement/move_fish()]
	///A list of cached fish icons
	var/list/cached_fish_icons
	///A list of cached fish icons turns into outlines with a queston mark in the middle, denoting fish you haven't caught yet.
	var/list/cached_unknown_fish_icons
	///An assoc list of identifier strings and the path of a fish that can be gotten from fish sources.
	var/list/catchable_fish
	///Cached fish properties so we don't have to initalize fish every time
	var/list/fish_properties
	///A cache of fish that can be caught by each type of fishing lure
	var/list/lure_catchables
	///A list of fish types with list of turfs where they can happily hop around without dying as assoc value
	var/list/fish_safe_turfs_by_type = list()

/datum/controller/subsystem/processing/fishing/Initialize()
	..()
	cached_fish_icons = list()
	cached_unknown_fish_icons = list()
	fish_properties = list()
	catchable_fish = list()

	var/icon/questionmark = icon('icons/effects/random_spawners.dmi', "questionmark")
	var/list/mark_dimension = get_icon_dimensions(questionmark)
	var/list/spawned_fish = list()
	var/list/fish_subtypes = sortTim(subtypesof(/obj/item/fish), GLOBAL_PROC_REF(cmp_init_name_asc))
	for(var/obj/item/fish/fish_type as anything in fish_subtypes)
		var/list/fish_dimensions = get_icon_dimensions(fish_type::icon)
		var/icon/fish_icon = icon(fish_type::icon, fish_type::icon_state, frame = 1, moving = FALSE)
		cached_fish_icons[fish_type] = icon2base64(fish_icon)
		var/icon/unknown_icon = icon(fish_icon)
		unknown_icon.Blend("#FFFFFF", ICON_SUBTRACT)
		unknown_icon.Blend("#070707", ICON_ADD)
		var/width = 1 + (fish_dimensions["width"] - mark_dimension["width"]) * 0.5
		var/height = 1 + (fish_dimensions["height"] - mark_dimension["height"]) * 0.5
		unknown_icon.Blend(questionmark, ICON_OVERLAY, x = width, y = height)
		cached_unknown_fish_icons[fish_type] = icon2base64(unknown_icon)

		var/obj/item/fish/fish = new fish_type
		spawned_fish += fish
		var/list/properties = list()
		fish_properties[fish_type] = properties
		properties[FISH_PROPERTIES_FAV_BAIT] = fish.favorite_bait.Copy()
		properties[FISH_PROPERTIES_BAD_BAIT] = fish.disliked_bait.Copy()
		properties[FISH_PROPERTIES_TRAITS] = fish.fish_traits.Copy()

		var/list/evo_types = fish.evolution_types?.Copy()
		properties[FISH_PROPERTIES_EVOLUTIONS] = evo_types
		for(var/type in evo_types)
			LAZYADD(GLOB.fishes_by_fish_evolution[type], fish_type)

		var/beauty_score = "???"
		switch(fish.beauty)
			if(-INFINITY to FISH_BEAUTY_DISGUSTING)
				beauty_score = "OH HELL NAW!"
			if(FISH_BEAUTY_DISGUSTING to FISH_BEAUTY_UGLY)
				beauty_score = "☆☆☆☆☆"
			if(FISH_BEAUTY_UGLY to FISH_BEAUTY_BAD)
				beauty_score = "★☆☆☆☆"
			if(FISH_BEAUTY_BAD to FISH_BEAUTY_NULL)
				beauty_score = "★★☆☆☆"
			if(FISH_BEAUTY_NULL to FISH_BEAUTY_GENERIC)
				beauty_score = "★★★☆☆"
			if(FISH_BEAUTY_GENERIC to FISH_BEAUTY_GOOD)
				beauty_score = "★★★★☆"
			if(FISH_BEAUTY_GOOD to FISH_BEAUTY_GREAT)
				beauty_score = "★★★★★"
			if(FISH_BEAUTY_GREAT to INFINITY)
				beauty_score = "★★★★★★"

		properties[FISH_PROPERTIES_BEAUTY_SCORE] = beauty_score

		var/fish_id
		if(fish.fish_id_redirect_path)
			var/obj/item/fish/other_path = fish.fish_id_redirect_path
			if(!ispath(other_path, /obj/item/fish))
				stack_trace("[fish.type] has a set 'fish_id_redirect_path' variable but it isn't a fish path but [other_path]")
				continue
			fish_id = initial(other_path.fish_id)
		else
			fish_id = fish.fish_id
		if(!fish_id)
			stack_trace("[fish.type] doesn't have a set 'fish_id' variable despite being a catchable fish")
			continue
		if(fish.fish_id_redirect_path)
			continue
		if(catchable_fish[fish_id])
			stack_trace("[fish.type] has a 'fish_id' value already assigned to [catchable_fish[fish_id]]. fish_id: [fish_id]")
			continue
		catchable_fish[fish_id] = fish.type

	///init the list of things lures can catch
	lure_catchables = list()
	for(var/lure_type in typesof(/obj/item/fishing_lure))
		var/obj/item/fishing_lure/lure = new lure_type
		lure_catchables[lure_type] = list()
		for(var/obj/item/fish/fish as anything in spawned_fish)
			if(lure.is_catchable_fish(fish, fish_properties[fish.type]))
				lure_catchables[lure_type] += fish.type
		qdel(lure)

	QDEL_LIST(spawned_fish)

	//Populate the list of safe turfs for several fishes
	for(var/source_path in GLOB.preset_fish_sources)
		var/datum/fish_source/source = GLOB.preset_fish_sources[source_path]
		if(!length(source.associated_safe_turfs))
			continue
		for(var/fish_path in source.fish_table)
			if(!istype(fish_path, /obj/item/fish))
				continue
			LAZYOR(fish_safe_turfs_by_type[fish_path], source.associated_safe_turfs)
	//If a subtype doesn't have set safe turfs, it'll inherit them from the parent type.
	for(var/fish_type as anything in fish_safe_turfs_by_type)
		for(var/fish_subtype in subtypesof(fish_type))
			if(!length(fish_safe_turfs_by_type[fish_subtype]))
				fish_safe_turfs_by_type[fish_subtype] = fish_safe_turfs_by_type[fish_type]

	return SS_INIT_SUCCESS
