///very low level antagonist that has objectives to steal items and live, but is not allowed to kill.
/datum/antagonist/thief
	name = "\improper Thief"
	job_rank = ROLE_THIEF
	roundend_category = "thieves"
	antagpanel_category = "Thief"
	show_in_antagpanel = TRUE
	suicide_cry = "FOR THE LION'S SHARE!!"
	preview_outfit = /datum/outfit/thief
	antag_hud_name = "thief"
	ui_name = "AntagInfoThief"
	count_against_dynamic_roll_chance = FALSE
	///assoc list of strings set up for the flavor of the thief.
	var/list/thief_flavor
	///if added by an admin, they can choose a thief flavor
	var/admin_choice_flavor
	///if a special trait needs to be added from the flavor, here it is
	var/special_trait
	///an area marked as the hideout- makes thieves happier to be in, and all thieves of the round know of it. only has a 20% chance of existing in a round.
	var/static/area/hideout
	///bool checked for the first thief in a round to decide if there should be one this round
	var/static/decided_on_hideout = FALSE

/datum/antagonist/thief/on_gain()
	if(!decided_on_hideout)
		decided_on_hideout = TRUE
		if(prob(20))
			create_hideout()
	flavor_and_objectives()
	. = ..() //ui opens here, objectives must exist beforehand

/datum/antagonist/thief/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/thief = mob_override || owner.current
	ADD_TRAIT(thief, TRAIT_VAL_CORRIN_MEMBER, THIEF_TRAIT)
	if(special_trait)
		ADD_TRAIT(thief, special_trait, THIEF_TRAIT)

/datum/antagonist/thief/remove_innate_effects(mob/living/mob_override)
	var/mob/living/thief = mob_override || owner.current
	REMOVE_TRAIT(thief, TRAIT_VAL_CORRIN_MEMBER, THIEF_TRAIT)
	if(special_trait)
		REMOVE_TRAIT(thief, special_trait, THIEF_TRAIT)
	return ..()

/datum/antagonist/thief/admin_add(datum/mind/new_owner, mob/admin)
	load_strings_file(THIEF_FLAVOR_FILE)
	var/list/all_thief_flavors = GLOB.string_cache[THIEF_FLAVOR_FILE]
	var/list/all_thief_names = list("Random")
	for(var/flavorname as anything in all_thief_flavors)
		all_thief_names += flavorname
	var/choice = tgui_input_list(admin, "Pick a thief flavor?", "Rogue's Guild", all_thief_names)
	if(choice && choice != "Random")
		admin_choice_flavor = choice
	. = ..()

/datum/antagonist/thief/proc/create_hideout()
	var/list/possible_hideout_locations = list(
		/area/station/maintenance/space_hut/cabin,
		/area/station/maintenance/space_hut/observatory,
		/area/station/service/kitchen/abandoned,
		/area/station/service/electronic_marketing_den,
		/area/station/service/abandoned_gambling_den,
		/area/station/service/abandoned_gambling_den/gaming,
		/area/station/service/theater/abandoned,
		/area/station/service/library/abandoned,
		/area/station/service/hydroponics/garden/abandoned,
		/area/station/medical/abandoned,
		/area/station/science/research/abandoned,
		/area/station/maintenance/department/crew_quarters/bar,
	)
	//remove every hideout location that isn't on this map
	possible_hideout_locations = special_list_filter(possible_hideout_locations, CALLBACK(src, .proc/filter_nonexistent_areas))
	//for custom maps without any abandoned locations
	if(!possible_hideout_locations.len)
		return
	var/chosen_type = pick(possible_hideout_locations)
	hideout = GLOB.areas_by_type[chosen_type]
	hideout.mood_trait = TRAIT_VAL_CORRIN_MEMBER
	hideout.mood_bonus = 5
	hideout.mood_message = "Feels good, having Val Corrin connections."

///checks if an area exists in the global areas, obviously comes up null (falsey) if say, abandoned cabin is checked on metastation.
/datum/antagonist/thief/proc/filter_nonexistent_areas(area_type)
	return GLOB.areas_by_type[area_type]

/datum/antagonist/thief/proc/flavor_and_objectives()
	//this list has a maximum pickweight of 100.
	//if you're adding a new type of thief, DON'T just add TOTAL pickweight. adjusting the others, numb nuts.
	var/static/list/weighted_flavors = list(
		"Thief" = 50,
		"Black Market Outfitter" = 13,
		"Organ Market Collector" = 13,
		"All Access Fan" = 10,
		"Chronicler" = 7,
		"Deranged" = 7,
		"Hoarder" = 0, //disabled until we have more reasonable nonreplenishable items to hoard- still admin selectable though
	)
	var/chosen_flavor = admin_choice_flavor || pick_weight(weighted_flavors)
	//objective given by flavor
	var/chosen_objective
	//whether objective should call find_target()
	var/objective_needs_target
	//If you add to this switch case, please follow the order of the weighted static list
	switch(chosen_flavor)
		if("Thief")
			chosen_objective = /datum/objective/steal
			objective_needs_target = TRUE
		if("Black Market Outfitter")
			chosen_objective = /datum/objective/steal_n_of_type/summon_guns/thief
			objective_needs_target = FALSE
		if("Organ Market Collector")
			chosen_objective = /datum/objective/steal_n_of_type/organs
			objective_needs_target = FALSE
		if("All Access Fan")
			chosen_objective = /datum/objective/all_access
			objective_needs_target = TRUE
			special_trait = TRAIT_ID_APPRAISER
		if("Chronicler")
			chosen_objective = /datum/objective/chronicle
			objective_needs_target = FALSE
		if("Deranged")
			chosen_objective = /datum/objective/hoarder/bodies
			objective_needs_target = TRUE
		if("Hoarder")
			chosen_objective = /datum/objective/hoarder
			objective_needs_target = TRUE
	thief_flavor = strings(THIEF_FLAVOR_FILE, chosen_flavor)

	//whatever main objective this type of thief needs to accomplish
	var/datum/objective/flavor_objective = new chosen_objective
	flavor_objective.owner = owner
	if(objective_needs_target)
		flavor_objective.find_target(dupe_search_range = list(src))
	flavor_objective.update_explanation_text()
	objectives += flavor_objective

	//all thieves need to escape with their loot (except hoarders, but you know.)
	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = owner
	objectives += escape_objective

/datum/antagonist/thief/ui_static_data(mob/user)
	var/list/data = list()
	data["objectives"] = get_objectives()
	data["goal"] = thief_flavor["goal"]
	data["intro"] = thief_flavor["introduction"]
	data["policy"] = get_policy(ROLE_THIEF)
	data["hideout"] = hideout ? hideout.name : ""
	return data

/datum/outfit/thief
	name = "Thief (Preview only)"
	uniform = /obj/item/clothing/under/color/black
	glasses = /obj/item/clothing/glasses/night
	gloves = /obj/item/clothing/gloves/color/latex
	back = /obj/item/storage/backpack/duffelbag/syndie
	mask = /obj/item/clothing/mask/bandana/red

/datum/outfit/thief/post_equip(mob/living/carbon/human/thief, visualsOnly=FALSE)
	// This outfit is used by the assets SS, which is ran before the atoms SS
	if(SSatoms.initialized == INITIALIZATION_INSSATOMS)
		thief.w_uniform?.update_greyscale()
		thief.update_inv_w_uniform()
	thief.physique = FEMALE //update_body() and gender block or something
	thief.hair_color = "#2A71DC" //hair color dna block
	thief.skin_tone = "caucasian2" //skin tone dna block
	thief.hairstyle = "Bun Head 2" //update_hair()
	thief.dna.update_ui_block(DNA_GENDER_BLOCK)
	thief.dna.update_ui_block(DNA_HAIR_COLOR_BLOCK)
	thief.dna.update_ui_block(DNA_SKIN_TONE_BLOCK)
	thief.update_body(is_creating = TRUE)

	// This outfit is used by the assets SS, which is ran before the atoms SS
	if (SSatoms.initialized == INITIALIZATION_INSSATOMS)
		thief.wear_mask?.update_greyscale()
		thief.update_inv_wear_mask()
