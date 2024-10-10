/datum/autowiki/fish
	page = "Template:Autowiki/Content/Fish"

/datum/autowiki/fish/generate()
	var/output = ""

	var/datum/reagent/def_food = /obj/item/fish::food
	var/def_food_name = initial(def_food.name)
	var/def_feeding = /obj/item/fish::feeding_frequency
	var/def_feeding_text = DisplayTimeText(def_feeding)
	var/def_breeding = /obj/item/fish::breeding_timeout
	var/def_breeding_text = DisplayTimeText(def_breeding)

	var/list/generated_icons = list()
	var/list/fish_types = subtypesof(/obj/item/fish)
	sortTim(fish_types, GLOBAL_PROC_REF(cmp_fish_fluid))

	for (var/obj/item/fish/fish as anything in fish_types)

		var/filename = FISH_AUTOWIKI_FILENAME(fish)

		if(!generated_icons[filename])
			upload_icon(icon(fish:icon, fish::icon_state, frame = 1), filename)
		generated_icons[filename] = TRUE

		if(!(fish::fish_flags & FISH_FLAG_SHOW_IN_CATALOG))
			continue

		var/list/properties = SSfishing.fish_properties[fish]

		var/description = escape_value(fish::desc)
		var/list/extra_info = list()
		if(fish::fillet_type != /obj/item/food/fishmeat)
			var/obj/item/fillet = fish::fillet_type
			if(!fillet)
				extra_info += "Cannot be butchered."
			else
				extra_info += "When butchered, it'll yield [initial(fillet.name)]."
		var/datum/reagent/food = fish::food
		if(food != def_food)
			extra_info += "It has to be fed <b>[initial(food.name)]</b> instead of [def_food_name]"
		if(fish::feeding_frequency != def_feeding)
			extra_info += "It has to be fed every <b>[DisplayTimeText(fish::feeding_frequency)]</b> instead of [def_feeding_text]"
		if(fish::breeding_timeout != def_breeding)
			extra_info += "It takes <b>[DisplayTimeText(fish::breeding_timeout)]</b> to reproduce instead of [def_breeding_text]"
		if(length(extra_info))
			description += "<br>[extra_info.Join(extra_info,"<br>")]"

		var/list/output_list = list(
			"name" = full_capitalize(escape_value(fish::name)),
			"icon" = filename,
			"description" = description,
			"size_weight" = "[fish::average_size]cm / [fish::average_weight]g",
			"fluid" = escape_value(fish::required_fluid_type),
			"temperature" = "Doesn't matter",
			"stable_population" = fish::stable_population,
			"traits" = generate_traits(properties[FISH_PROPERTIES_TRAITS]),
			"favorite_baits" = generate_baits(properties[FISH_PROPERTIES_FAV_BAIT]),
			"disliked_baits" = generate_baits(properties[FISH_PROPERTIES_BAD_BAIT], TRUE),
			"beauty_score" = properties[FISH_PROPERTIES_BEAUTY_SCORE],
		)
		var/not_infinity = fish::required_temperature_max < INFINITY
		if(fish::required_temperature_min > 0 || not_infinity)
			var/max_temp = not_infinity ? fish::required_temperature_max : "∞"
			output_list["temperature"] = "[fish::required_temperature_min] - [max_temp] K"

		output += "\n\n" + include_template("Autowiki/FishEntry", output_list)

	return output

/datum/autowiki/fish/proc/generate_baits(list/baits, bad = FALSE)
	var/list/list = list()
	if(!length(baits))
		return list("None")

	for (var/identifier in baits)
		if(ispath(identifier)) //Just a path
			var/obj/item/item = identifier
			list += initial(item.name)
			continue
		var/list/special_identifier = identifier
		switch(special_identifier["Type"])
			if("Foodtype")
				list += english_list(bitfield_to_list(special_identifier["Value"], FOOD_FLAGS_IC))
			if("Reagent")
				var/datum/reagent/reagent = special_identifier["Value"]
				list += "[reagent::name][bad ? "" : "(At least [special_identifier["Amount"]] units)"]"

	return list

/datum/autowiki/fish/proc/generate_traits(list/traits)
	var/output = ""

	for(var/trait_type in traits)
		var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
		output += include_template("Autowiki/FishTypeTraits", list(
			"name" = escape_value(trait.name),
			"description" = escape_value(trait.catalog_description),
		))

	return output

/datum/autowiki/fish_trait
	page = "Template:Autowiki/Content/Fish/Trait"

/datum/autowiki/fish_trait/generate()
	var/output = ""

	for(var/trait_type in GLOB.fish_traits)
		var/datum/fish_trait/trait = GLOB.fish_traits[trait_type]
		var/desc = escape_value(trait.catalog_description)
		if(length(trait.incompatible_traits))
			var/incompatible = list()
			for(var/datum/fish_trait/bad as anything in trait.incompatible_traits)
				incompatible += span_bold(initial(bad.name))
			desc += "<br>Incompatible with [english_list(incompatible)]."
		output += include_template("Autowiki/FishAllTraits", list(
			"name" = escape_value(trait.name),
			"description" = escape_value(trait.catalog_description),
			"inheritability" = trait.inheritability,
			"inheritability_diff" = trait.diff_traits_inheritability,

		))

	return output

/datum/autowiki/fish_bait
	page = "Template:Autowiki/Content/Fish/Bait"

/datum/autowiki/fish_bait/generate()
	var/output = ""

	var/list/generated_icons = list()
	for (var/obj/item/food/bait/bait as anything in subtypesof(/obj/item/food/bait))
		if(!bait::show_on_wiki)
			continue

		var/filename = SANITIZE_FILENAME("[bait::icon_state]_wiki_bait")

		var/quality = "Bland"

		var/list/foodtypes
		if(ispath(bait, /obj/item/food/bait/doughball/synthetic))
			foodtypes = list("Don't worry about it")
		else
			foodtypes = bitfield_to_list(bait::foodtypes, FOOD_FLAGS_IC) || list("None")

		switch(bait::bait_quality)
			if(TRAIT_BASIC_QUALITY_BAIT)
				quality = "Basic"
			if(TRAIT_GOOD_QUALITY_BAIT)
				quality = "Good"
			if(TRAIT_GREAT_QUALITY_BAIT)
				quality = "Great"

		output += "\n\n" + include_template("Autowiki/FishBait", list(
			"name" = full_capitalize(escape_value(bait::name)),
			"icon" = filename,
			"description" = escape_value(bait::desc),
			"foodtypes" = foodtypes,
			"quality" = quality,
		))

		if(!generated_icons[filename])
			upload_icon(icon(bait:icon, bait::icon_state, frame = 1), filename)
		generated_icons[filename] = TRUE

	var/filename = SANITIZE_FILENAME(/obj/item/stock_parts/power_store/cell/lead::icon_state)

	var/lead_desc = /obj/item/stock_parts/power_store/cell/lead::desc
	lead_desc += " You probably shouldn't use it unless you're trying to catch a zipzap."
	output += "\n\n" + include_template("Autowiki/FishBait", list(
		"name" = full_capitalize(escape_value(/obj/item/stock_parts/power_store/cell/lead::name)),
		"icon" = filename,
		"description" = lead_desc,
		"foodtypes" = "None",
		"quality" = "Poisonous",
	))

	upload_icon(icon(/obj/item/stock_parts/power_store/cell/lead::icon, /obj/item/stock_parts/power_store/cell/lead::icon_state), filename)

	var/obj/needletype = /obj/item/fish/needlefish
	output += "\n\n" + include_template("Autowiki/FishBait", list(
		"name" = "Baitfish",
		"icon" = FISH_AUTOWIKI_FILENAME(needletype),
		"description" = "Smaller fish such as goldfish, needlefish, armorfish and lavaloops can also be used as bait, It's a fish eat fish world.",
		"foodtypes" = "Seafood?",
		"quality" = "Good",
	))

	output += "\n\n" + include_template("Autowiki/FishBait", list(
		"name" = "Food",
		"icon" = "plain_bread",
		"description" = "In absence of baits, food can be used as a substitute.",
		"foodtypes" = "Depends",
		"quality" = "Bland most of the times",
	))

	upload_icon(icon(/obj/item/food/bread/plain::icon, /obj/item/food/bread/plain::icon_state), "plain_bread")

	return output

/datum/autowiki/fishing_line
	page = "Template:Autowiki/Content/Fish/Line"

/datum/autowiki/fishing_line/generate()
	var/output = ""

	var/list/generated_icons = list()
	for (var/obj/item/fishing_line/line as anything in typesof(/obj/item/fishing_line))
		var/filename = SANITIZE_FILENAME("[line::icon_state]_wiki_line")

		output += "\n\n" + include_template("Autowiki/FishLine", list(
			"name" = full_capitalize(escape_value(line::name)),
			"icon" = filename,
			"description" = escape_value(line::wiki_desc),
		))

		if(!generated_icons[filename])
			upload_icon(icon(line:icon, line::icon_state), filename)
		generated_icons[filename] = TRUE

	return output

/datum/autowiki/fishing_hook
	page = "Template:Autowiki/Content/Fish/Hook"

/datum/autowiki/fishing_hook/generate()
	var/output = ""

	var/list/generated_icons = list()
	for (var/obj/item/fishing_hook/hook as anything in typesof(/obj/item/fishing_hook))
		var/filename = SANITIZE_FILENAME("[hook::icon_state]_wiki_hook")

		output += "\n\n" + include_template("Autowiki/FishHook", list(
			"name" = full_capitalize(escape_value(hook::name)),
			"icon" = filename,
			"description" = escape_value(hook::wiki_desc),
		))

		if(!generated_icons[filename])
			upload_icon(icon(hook:icon, hook::icon_state), filename)
		generated_icons[filename] = TRUE

	return output

/datum/autowiki/fishing_rod
	page = "Template:Autowiki/Content/Fish/Rod"

/datum/autowiki/fishing_rod/generate()
	var/output = ""

	var/list/generated_icons = list()
	for (var/obj/item/fishing_rod/rod as anything in typesof(/obj/item/fishing_rod))
		if(!rod::show_in_wiki)
			continue

		var/filename = SANITIZE_FILENAME("[rod::icon_state]_wiki_rod")

		var/desc = escape_value(rod::ui_description)
		if(rod::wiki_description)
			desc += "<br>[escape_value(rod::wiki_description)]"
		output += "\n\n" + include_template("Autowiki/FishingRod", list(
			"name" = full_capitalize(escape_value(rod::name)),
			"icon" = filename,
			"description" = desc,
		))

		if(!generated_icons[filename])
			var/icon/rod_icon = icon(rod:icon, rod::icon_state)
			if(rod::reel_overlay)
				var/icon/line = icon(rod::icon, rod::reel_overlay)
				line.Blend(rod::default_line_color, ICON_MULTIPLY)
				rod_icon.Blend(line, ICON_OVERLAY)
			upload_icon(rod_icon, filename)
		generated_icons[filename] = TRUE

	return output

/datum/autowiki/fish_sources
	page = "Template:Autowiki/Content/Fish/Source"

/datum/autowiki/fish_sources/generate()
	var/output = ""

	for(var/source_type in GLOB.preset_fish_sources)
		var/datum/fish_source/source = GLOB.preset_fish_sources[source_type]
		if(!source.catalog_description)
			continue

		output += "\n\n" + include_template("Autowiki/FishSource", list(
			"name" = full_capitalize(source.catalog_description),
			"difficulty" = source.fishing_difficulty,
			"contents" = get_contents(source),
		))

	///Used for stuff that isn't fish by default
	upload_icon(icon('icons/effects/random_spawners.dmi', "questionmark"), FISH_SOURCE_AUTOWIKI_QUESTIONMARK)

	return output

/datum/autowiki/fish_sources/proc/get_contents(datum/fish_source/source)
	var/output = ""
	var/list/data = source.generate_wiki_contents(src)
	sortTim(data, GLOBAL_PROC_REF(cmp_autowiki_fish_sources_content))
	for(var/list/entry in data)
		entry[FISH_SOURCE_AUTOWIKI_WEIGHT] = "[round(entry[FISH_SOURCE_AUTOWIKI_WEIGHT], 0.1)]%"
		var/weight_suffix = entry[FISH_SOURCE_AUTOWIKI_WEIGHT_SUFFIX]
		if(weight_suffix)
			entry[FISH_SOURCE_AUTOWIKI_WEIGHT] += " [weight_suffix]"
		entry -= FISH_SOURCE_AUTOWIKI_WEIGHT
		output += include_template("Autowiki/FishSourceContents", entry)

	return output

///Sort the autowiki fish entries by their weight. However, duds always come first.
/proc/cmp_autowiki_fish_sources_content(list/A, list/B)
	if(A[FISH_SOURCE_AUTOWIKI_NAME] == FISH_SOURCE_AUTOWIKI_DUD)
		return -1
	if(B[FISH_SOURCE_AUTOWIKI_NAME] == FISH_SOURCE_AUTOWIKI_DUD)
		return 1
	if(A[FISH_SOURCE_AUTOWIKI_NAME] == FISH_SOURCE_AUTOWIKI_OTHER)
		return 1
	if(B[FISH_SOURCE_AUTOWIKI_NAME] == FISH_SOURCE_AUTOWIKI_OTHER)
		return -1
	return B[FISH_SOURCE_AUTOWIKI_WEIGHT] - A[FISH_SOURCE_AUTOWIKI_WEIGHT]

/datum/autowiki/fish_scan
	page = "Template:Autowiki/Content/Fish/Scan"

/datum/autowiki/fish_scan/generate()
	var/output = ""

	var/list/generated_icons = list()
	var/datum/techweb/techweb = locate(/datum/techweb/admin) in SSresearch.techwebs
	for(var/scan_type in typesof(/datum/experiment/scanning/fish))
		techweb.add_experiment(scan_type) //Make sure each followup experiment is available
		var/datum/experiment/scanning/fish/scan = locate(scan_type) in techweb.available_experiments
		if(!scan) //Just to be sure, if the scan was already completed.
			scan = locate(scan_type) in techweb.completed_experiments

		output += "\n\n" + include_template("Autowiki/FishScan", list(
			"name" = full_capitalize(escape_value(scan.name)),
			"description" = escape_value(scan.description),
			"requirements" = build_requirements(scan),
			"rewards" = build_rewards(scan, generated_icons),

		))

	return output

/datum/autowiki/fish_scan/proc/build_requirements(datum/experiment/scanning/fish/scan)
	var/output = ""
	for(var/obj/item/type as anything in scan.required_atoms)
		var/name = initial(type.name)
		//snowflake case because the default holographic fish is called goldfish but we don't want to confuse readers.
		if(type == /obj/item/fish/holo)
			name = "holographic Fish"
		output += include_template("Autowiki/FishScanRequirements", list(
			"name" = full_capitalize(escape_value(name)),
			"amount" = scan.required_atoms[type],
		))
	return output

/datum/autowiki/fish_scan/proc/build_rewards(datum/experiment/scanning/fish/scan, list/generated_icons)
	var/output = ""
	var/datum/fish_source/portal/reward = GLOB.preset_fish_sources[scan.fish_source_reward]
	var/filename = SANITIZE_FILENAME("fishing_portal_[reward.radial_state]")

	var/list/unlocks = list()
	for(var/datum/experiment/unlock as anything in scan.next_experiments)
		unlocks += initial(unlock.name)
	output += include_template("Autowiki/FishScanRewards", list(
		"name" = full_capitalize(escape_value("[reward.radial_name] Dimension")),
		"icon" = filename,
		"points" = scan.get_points_reward_text(),
		"unlock" = english_list(unlocks, nothing_text = "Nothing"),
	))

	if(!generated_icons[filename])
		upload_icon(icon(icon = 'icons/hud/radial_fishing.dmi', icon_state = reward.radial_state), filename)
	generated_icons[filename] = TRUE

	return output

/datum/autowiki/fish_evolution
	page = "Template:Autowiki/Content/Fish/Evolution"

/datum/autowiki/fish_evolution/generate()
	var/output = ""

	for(var/evo_type in GLOB.fish_evolutions)
		var/datum/fish_evolution/evolution = GLOB.fish_evolutions[evo_type]
		if(!evolution.show_on_wiki)
			continue

		output += "\n\n" + include_template("Autowiki/FishEvolution", list(
			"name" = escape_value(evolution.name),
			"fish" = get_fish(evo_type),
			"min_max_temp" = "[evolution.required_temperature_min] - [evolution.required_temperature_max] K",
			"notes" = escape_value(evolution.conditions_note),
			"result_icon" = evolution.show_result_on_wiki ? FISH_AUTOWIKI_FILENAME(evolution.new_fish_type) : FISH_SOURCE_AUTOWIKI_QUESTIONMARK,
		))

	return output

/datum/autowiki/fish_evolution/proc/get_fish(evo_type)
	var/output = ""

	for(var/obj/item/fish/fish as anything in GLOB.fishes_by_fish_evolution[evo_type])
		if(!(initial(fish.fish_flags) & FISH_FLAG_SHOW_IN_CATALOG))
			continue
		output += include_template("Autowiki/FishEvolutionCandidate", list(
			"name" = escape_value(full_capitalize(initial(fish.name))),
			"icon" = FISH_AUTOWIKI_FILENAME(fish),
		))

	return output

/datum/autowiki/fish_lure
	page = "Template:Autowiki/Content/Fish/Lure"

/datum/autowiki/fish_lure/generate()
	var/output = ""

	for(var/obj/item/fishing_lure/lure as anything in SSfishing.lure_catchables)
		var/state = initial(lure.icon_state)
		var/filename = SANITIZE_FILENAME("[state]_wiki_lure")
		output += "\n\n" + include_template("Autowiki/FishLure", list(
			"name" = escape_value(full_capitalize(initial(lure.name))),
			"desc" = escape_value(initial(lure.name)),
			"icon" = filename,
			"catchables" = build_catchables(SSfishing.lure_catchables[lure]),
		))

		upload_icon(icon(icon = initial(lure.icon), icon_state = state), filename)

	return output

/datum/autowiki/fish_lure/proc/build_catchables(list/catchables)
	var/output = ""

	for(var/obj/item/fish/fish as anything in catchables)
		if(!(initial(fish.fish_flags) & FISH_FLAG_SHOW_IN_CATALOG))
			continue
		output += include_template("Autowiki/FishLureCatchables", list(
			"name" = escape_value(full_capitalize(initial(fish.name))),
			"icon" = FISH_AUTOWIKI_FILENAME(fish),
		))

	return output
