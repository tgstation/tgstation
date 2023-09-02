GLOBAL_LIST_INIT(preset_fish_sources, init_subtypes_w_path_keys(/datum/fish_source, list()))

/**
 * Where the fish actually come from - every fishing spot has one assigned but multiple fishing holes
 * can share single source, ie single shared one for ocean/lavaland river
 */
/datum/fish_source
	/// Fish catch weight table - these are relative weights
	var/list/fish_table = list()
	/// If a key from fish_table is present here, that fish is availible in limited quantity and is reduced by one on successful fishing
	var/list/fish_counts = list()
	/// Text shown as baloon alert when you roll a dud in the table
	var/duds = list("it was nothing", "the hook is empty")
	/// Baseline difficulty for fishing in this spot
	var/fishing_difficulty = FISHING_DEFAULT_DIFFICULTY
	/// How the spot type is described in fish catalog section about fish sources, will be skipped if null
	var/catalog_description
	/// Background image name from /datum/asset/simple/fishing_minigame
	var/background = "fishing_background_default"

/// Can we fish in this spot at all. Returns DENIAL_REASON or null if we're good to go
/datum/fish_source/proc/reason_we_cant_fish(obj/item/fishing_rod/rod, mob/fisherman)
	return rod.reason_we_cant_fish(src)

/**
 * Calculates the difficulty of the minigame:
 *
 * This includes the source's fishing difficulty, that of the fish, the rod,
 * favorite and disliked baits, fish traits and the fisherman skill.
 *
 * For non-fish, it's just the source's fishing difficulty minus the fisherman skill, rod and settler modifiers.
 */
/datum/fish_source/proc/calculate_difficulty(result, obj/item/fishing_rod/rod, mob/fisherman, datum/fishing_challenge/challenge)
	. = fishing_difficulty

	// Difficulty modifier added by having the Settler quirk
	if(HAS_TRAIT(fisherman, TRAIT_SETTLER))
		. += SETTLER_DIFFICULTY_MOD

	// Difficulty modifier added by the fisher's skill level
	if(!challenge || !(FISHING_MINIGAME_RULE_NO_EXP in challenge.special_effects))
		. += fisherman.mind?.get_skill_modifier(/datum/skill/fishing, SKILL_VALUE_MODIFIER)

	// Difficulty modifier added by the rod
	. += rod.difficulty_modifier

	if(!ispath(result,/obj/item/fish))
		// In the future non-fish rewards can have variable difficulty calculated here
		return

	var/list/fish_list_properties = collect_fish_properties()
	var/obj/item/fish/caught_fish = result
	// Baseline fish difficulty
	. += initial(caught_fish.fishing_difficulty_modifier)


	if(rod.bait)
		var/obj/item/bait = rod.bait
		//Fav bait makes it easier
		var/list/fav_bait = fish_list_properties[caught_fish][NAMEOF(caught_fish, favorite_bait)]
		for(var/bait_identifer in fav_bait)
			if(is_matching_bait(bait, bait_identifer))
				. += FAV_BAIT_DIFFICULTY_MOD
		//Disliked bait makes it harder
		var/list/disliked_bait = fish_list_properties[caught_fish][NAMEOF(caught_fish, disliked_bait)]
		for(var/bait_identifer in disliked_bait)
			if(is_matching_bait(bait, bait_identifer))
				. += DISLIKED_BAIT_DIFFICULTY_MOD

	// Matching/not matching fish traits and equipment
	var/list/fish_traits = fish_list_properties[caught_fish][NAMEOF(caught_fish, fish_traits)]

	var/additive_mod = 0
	var/multiplicative_mod = 1
	for(var/fish_trait in fish_traits)
		var/datum/fish_trait/trait = GLOB.fish_traits[fish_trait]
		var/list/mod = trait.difficulty_mod(rod, fisherman)
		additive_mod += mod[ADDITIVE_FISHING_MOD]
		multiplicative_mod *= mod[MULTIPLICATIVE_FISHING_MOD]

	. += additive_mod
	. *= multiplicative_mod

/// In case you want more complex rules for specific spots
/datum/fish_source/proc/roll_reward(obj/item/fishing_rod/rod, mob/fisherman)
	return pick_weight(get_modified_fish_table(rod,fisherman))

/**
 * Used to register signals or add traits and the such right after conditions have been cleared
 * and before the minigame starts.
 */
/datum/fish_source/proc/pre_challenge_started(obj/item/fishing_rod/rod, mob/user)
	return

///Proc called when the challenge is interrupted within the fish source code.
/datum/fish_source/proc/interrupt_challenge(reason)
	SEND_SIGNAL(src, COMSIG_FISHING_SOURCE_INTERRUPT_CHALLENGE, reason)

/**
 * Proc called when the COMSIG_FISHING_CHALLENGE_COMPLETED signal is sent.
 * Check if we've succeeded. If so, write into memory and dispense the reward.
 */
/datum/fish_source/proc/on_challenge_completed(datum/fishing_challenge/source, mob/user, success)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	if(!success)
		return
	var/obj/item/fish/caught = source.reward_path
	user.add_mob_memory(/datum/memory/caught_fish, protagonist = user, deuteragonist = initial(caught.name))
	var/turf/fishing_spot = get_turf(source.lure)
	var/atom/movable/reward = dispense_reward(source.reward_path, user, fishing_spot)
	source.used_rod?.consume_bait(reward)

/// Gives out the reward if possible
/datum/fish_source/proc/dispense_reward(reward_path, mob/fisherman, turf/fishing_spot)
	if((reward_path in fish_counts)) // This is limited count result
		fish_counts[reward_path] -= 1
		if(!fish_counts[reward_path])
			fish_counts -= reward_path //Ran out of these since rolling (multiple fishermen on same source most likely)ù

	var/atom/movable/reward = spawn_reward(reward_path, fisherman, fishing_spot)
	if(!reward) //baloon alert instead
		fisherman.balloon_alert(fisherman,pick(duds))
		return
	if(isitem(reward)) //Try to put it in hand
		INVOKE_ASYNC(fisherman, TYPE_PROC_REF(/mob, put_in_hands), reward)
	fisherman.balloon_alert(fisherman, "caught [reward]!")
	SEND_SIGNAL(fisherman, COMSIG_MOB_FISHING_REWARD_DISPENSED, reward)
	return reward

/// Spawns a reward from a atom path right where the fisherman is. Part of the dispense_reward() logic.
/datum/fish_source/proc/spawn_reward(reward_path, mob/fisherman,  turf/fishing_spot)
	if(reward_path == FISHING_DUD)
		return
	if(ispath(reward_path, /datum/chasm_detritus))
		return GLOB.chasm_detritus_types[reward_path].dispense_reward(fishing_spot)
	if(!ispath(reward_path, /atom/movable))
		CRASH("Unsupported /datum path [reward_path] passed to fish_source/proc/spawn_reward()")
	var/atom/movable/reward = new reward_path(get_turf(fisherman))
	if(isfish(reward))
		var/obj/item/fish/caught_fish = reward
		caught_fish.randomize_size_and_weight()
	return reward

/// Cached fish list properties so we don't have to initalize fish every time, init deffered
GLOBAL_LIST(fishing_property_cache)

/// Awful workaround around initial(x.list_variable) not being a thing while trying to keep some semblance of being structured
/proc/collect_fish_properties()
	if(GLOB.fishing_property_cache == null)
		var/list/fish_property_table = list()
		for(var/fish_type in subtypesof(/obj/item/fish))
			var/obj/item/fish/fish = new fish_type(null, FALSE)
			fish_property_table[fish_type] = list()
			fish_property_table[fish_type][NAMEOF(fish, favorite_bait)] = fish.favorite_bait.Copy()
			fish_property_table[fish_type][NAMEOF(fish, disliked_bait)] = fish.disliked_bait.Copy()
			fish_property_table[fish_type][NAMEOF(fish, fish_traits)] = fish.fish_traits.Copy()
			QDEL_NULL(fish)
		GLOB.fishing_property_cache = fish_property_table
	return GLOB.fishing_property_cache

/// Checks if bait matches identifier from fav/disliked bait list
/datum/fish_source/proc/is_matching_bait(obj/item/bait, identifier)
	if(ispath(identifier)) //Just a path
		return istype(bait, identifier)
	if(islist(identifier))
		var/list/special_identifier = identifier
		switch(special_identifier["Type"])
			if("Foodtype")
				var/obj/item/food/food_bait = bait
				return istype(food_bait) && food_bait.foodtypes & special_identifier["Value"]
			if("Reagent")
				return bait.reagents?.has_reagent(special_identifier["Value"], special_identifier["Amount"], check_subtypes = TRUE)
			else
				CRASH("Unknown bait identifier in fish favourite/disliked list")
	else
		return HAS_TRAIT(bait, identifier)

/// Builds a fish weights table modified by bait/rod/user properties
/datum/fish_source/proc/get_modified_fish_table(obj/item/fishing_rod/rod, mob/fisherman)
	var/obj/item/bait = rod.bait

	var/list/fish_list_properties = collect_fish_properties()

	var/list/final_table = fish_table.Copy()
	for(var/result in final_table)
		if((result in fish_counts) && fish_counts[result] <= 0) //ran out of these, ignore
			final_table -= result
			continue

		final_table[result] *= rod.multiplicative_fish_bonus(result, src)
		final_table[result] += rod.additive_fish_bonus(result, src) //Decide on order here so it can be multiplicative
		if(ispath(result, /obj/item/fish))
			//Modify fish roll chance
			var/obj/item/fish/caught_fish = result

			if(bait)
				if(HAS_TRAIT(bait, TRAIT_GREAT_QUALITY_BAIT))
					final_table[result] *= 10
				else if(HAS_TRAIT(bait, TRAIT_GOOD_QUALITY_BAIT))
					final_table[result] = round(final_table[result] * 3.5, 1)
				else if(HAS_TRAIT(bait, TRAIT_BASIC_QUALITY_BAIT))
					final_table[result] *= 2
				if(!HAS_TRAIT(bait, OMNI_BAIT_TRAIT))
					//Bait matching likes doubles the chance
					var/list/fav_bait = fish_list_properties[result][NAMEOF(caught_fish, favorite_bait)]
					for(var/bait_identifer in fav_bait)
						if(is_matching_bait(bait, bait_identifer))
							final_table[result] *= 2
					//Bait matching dislikes
					var/list/disliked_bait = fish_list_properties[result][NAMEOF(caught_fish, disliked_bait)]
					for(var/bait_identifer in disliked_bait)
						if(is_matching_bait(bait, bait_identifer))
							final_table[result] = round(final_table[result] * 0.5, 1)
			else
				final_table[result] = round(final_table[result] * 0.15, 1) //Fishing without bait is not going to be easy

			// Apply fish trait modifiers
			var/list/fish_traits = fish_list_properties[caught_fish][NAMEOF(caught_fish, fish_traits)]
			var/additive_mod = 0
			var/multiplicative_mod = 1
			for(var/fish_trait in fish_traits)
				var/datum/fish_trait/trait = GLOB.fish_traits[fish_trait]
				var/list/mod = trait.catch_weight_mod(rod, fisherman)
				additive_mod += mod[ADDITIVE_FISHING_MOD]
				multiplicative_mod *= mod[MULTIPLICATIVE_FISHING_MOD]

			final_table[result] += additive_mod
			final_table[result] = round(final_table[result] * multiplicative_mod, 1)

		if(final_table[result] <= 0)
			final_table -= result
	return final_table
