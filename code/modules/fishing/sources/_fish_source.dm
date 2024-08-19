GLOBAL_LIST_INIT(preset_fish_sources, init_subtypes_w_path_keys(/datum/fish_source, list()))

/**
 * When adding new fishable rewards to a table/counts, you can specify an icon to show in place of the
 * generic fish icon in the minigame UI should the user have the TRAIT_REVEAL_FISH trait, by adding it to
 * this list.
 *
 * A lot of the icons here may be a tad inaccurate, but since we're limited to the free font awesome icons we
 * have access to, we got to make do.
 */
GLOBAL_LIST_INIT(specific_fish_icons, zebra_typecacheof(list(
	/mob/living/basic/carp = FISH_ICON_DEF,
	/mob/living/basic/mining = FISH_ICON_HOSTILE,
	/obj/effect/decal/remains = FISH_ICON_BONE,
	/obj/effect/mob_spawn/corpse = FISH_ICON_BONE,
	/obj/item/coin = FISH_ICON_COIN,
	/obj/item/fish = FISH_ICON_DEF,
	/obj/item/fish/armorfish = FISH_ICON_CRAB,
	/obj/item/fish/boned = FISH_ICON_BONE,
	/obj/item/fish/chasm_crab = FISH_ICON_CRAB,
	/obj/item/fish/gunner_jellyfish = FISH_ICON_JELLYFISH,
	/obj/item/fish/holo/crab = FISH_ICON_CRAB,
	/obj/item/fish/holo/puffer = FISH_ICON_CHUNKY,
	/obj/item/fish/mastodon = FISH_ICON_BONE,
	/obj/item/fish/pufferfish = FISH_ICON_CHUNKY,
	/obj/item/fish/slimefish = FISH_ICON_SLIME,
	/obj/item/fish/sludgefish = FISH_ICON_SLIME,
	/obj/item/fish/starfish = FISH_ICON_STAR,
	/obj/item/storage/wallet = FISH_ICON_COIN,
	/obj/item/stack/sheet/bone = FISH_ICON_BONE,
	/obj/item/stack/sheet/mineral = FISH_ICON_GEM,
	/obj/item/stack/ore = FISH_ICON_GEM,
	/obj/structure/closet/crate = FISH_ICON_COIN,
)))

/**
 * Where the fish actually come from - every fishing spot has one assigned but multiple fishing holes
 * can share single source, ie single shared one for ocean/lavaland river
 */
/datum/fish_source
	/**
	 * Fish catch weight table - these are relative weights
	 *
	 */
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
	var/background = "background_default"
	/// It true, repeated and large explosions won't be as efficient. This is usually meant for global fish sources.
	var/explosive_malus = FALSE
	/// If explosive_malus is true, this will be used to keep track of the turfs where an explosion happened for when we'll spawn the loot.
	var/list/exploded_turfs
	/// Mindless mobs that can fish will never pull up items on this list
	var/static/list/profound_fisher_blacklist = typecacheof(list(
		/mob/living/basic/mining/lobstrosity,
		/obj/structure/closet/crate/necropolis/tendril,
	))

/datum/fish_source/New()
	if(!PERFORM_ALL_TESTS(focus_only/fish_sources_tables))
		return
	for(var/path in fish_counts)
		if(!(path in fish_table))
			stack_trace("path [path] found in the 'fish_counts' list but not in the fish_table one of [type]")

/datum/fish_source/Destroy()
	exploded_turfs = null
	return ..()

///Called when src is set as the fish source of a fishing spot component
/datum/fish_source/proc/on_fishing_spot_init(/datum/component/fishing_spot/spot)
	return

/// Can we fish in this spot at all. Returns DENIAL_REASON or null if we're good to go
/datum/fish_source/proc/reason_we_cant_fish(obj/item/fishing_rod/rod, mob/fisherman, atom/parent)
	return rod.reason_we_cant_fish(src)

/// Called below above proc, in case the fishing source has anything to do that isn't denial
/datum/fish_source/proc/on_start_fishing(obj/item/fishing_rod/rod, mob/fisherman, atom/parent)
	return

/**
 * Calculates the difficulty of the minigame:
 *
 * This includes the source's fishing difficulty, that of the fish, the rod,
 * favorite and disliked baits, fish traits and the fisherman skill.
 *
 * For non-fish, it's just the source's fishing difficulty minus the fisherman skill.
 */
/datum/fish_source/proc/calculate_difficulty(result, obj/item/fishing_rod/rod, mob/fisherman, datum/fishing_challenge/challenge)
	. = fishing_difficulty

	// Difficulty modifier added by having the Settler quirk
	if(HAS_TRAIT(fisherman, TRAIT_EXPERT_FISHER))
		. += EXPERT_FISHER_DIFFICULTY_MOD

	// Difficulty modifier added by the fisher's skill level
	if(!(challenge?.special_effects & FISHING_MINIGAME_RULE_NO_EXP))
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
/datum/fish_source/proc/pre_challenge_started(obj/item/fishing_rod/rod, mob/user, datum/fishing_challenge/challenge)
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
	if(source.used_rod)
		SEND_SIGNAL(source.used_rod, COMSIG_FISHING_ROD_CAUGHT_FISH, reward, user)
		source.used_rod.consume_bait(reward)

/// Gives out the reward if possible
/datum/fish_source/proc/dispense_reward(reward_path, mob/fisherman, turf/fishing_spot)
	var/atom/movable/reward = simple_dispense_reward(reward_path, get_turf(fisherman), fishing_spot)
	if(!reward) //balloon alert instead
		fisherman.balloon_alert(fisherman, pick(duds))
		return
	if(isitem(reward)) //Try to put it in hand
		INVOKE_ASYNC(fisherman, TYPE_PROC_REF(/mob, put_in_hands), reward)
	else if(istype(reward, /obj/effect/spawner)) // Do not attempt to forceMove() a spawner. It will break things, and the spawned item should already be at the mob's turf by now.
		fisherman.balloon_alert(fisherman, "caught something!")
		return
	else // for fishing things like corpses, move them to the turf of the fisherman
		INVOKE_ASYNC(reward, TYPE_PROC_REF(/atom/movable, forceMove), get_turf(fisherman))
	fisherman.balloon_alert(fisherman, "caught [reward]!")

	return reward

///Simplified version of dispense_reward that doesn't need a fisherman.
/datum/fish_source/proc/simple_dispense_reward(reward_path, atom/spawn_location, turf/fishing_spot)
	if(isnull(reward_path))
		return null
	if((reward_path in fish_counts)) // This is limited count result
		fish_counts[reward_path] -= 1
		if(!fish_counts[reward_path])
			fish_counts -= reward_path //Ran out of these since rolling (multiple fishermen on same source most likely)
			fish_table -= reward_path

	var/atom/movable/reward = spawn_reward(reward_path, spawn_location, fishing_spot)
	SEND_SIGNAL(src, COMSIG_FISH_SOURCE_REWARD_DISPENSED, reward)
	return reward

/// Spawns a reward from a atom path right where the fisherman is. Part of the dispense_reward() logic.
/datum/fish_source/proc/spawn_reward(reward_path, atom/spawn_location, turf/fishing_spot)
	if(reward_path == FISHING_DUD)
		return
	if(ispath(reward_path, /datum/chasm_detritus))
		return GLOB.chasm_detritus_types[reward_path].dispense_detritus(spawn_location, fishing_spot)
	if(!ispath(reward_path, /atom/movable))
		CRASH("Unsupported /datum path [reward_path] passed to fish_source/proc/spawn_reward()")
	var/atom/movable/reward = new reward_path(spawn_location)
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
	///An exponent used to level out the difference in probabilities between fishes/mobs on the table depending on bait quality.
	var/leveling_exponent = 0
	///Multiplier used to make fishes more common compared to everything else.
	var/result_multiplier = 1


	var/list/final_table = fish_table.Copy()

	if(bait)
		if(HAS_TRAIT(bait, TRAIT_GREAT_QUALITY_BAIT))
			result_multiplier = 9
			leveling_exponent = 0.5
		else if(HAS_TRAIT(bait, TRAIT_GOOD_QUALITY_BAIT))
			result_multiplier = 3.5
			leveling_exponent = 0.25
		else if(HAS_TRAIT(bait, TRAIT_BASIC_QUALITY_BAIT))
			result_multiplier = 2
			leveling_exponent = 0.1
		final_table -= FISHING_DUD

	var/list/fish_list_properties = collect_fish_properties()


	if(HAS_TRAIT(fisherman, TRAIT_PROFOUND_FISHER) && !fisherman.client)
		final_table -= profound_fisher_blacklist
	for(var/result in final_table)
		final_table[result] *= rod.hook?.get_hook_bonus_multiplicative(result)
		final_table[result] += rod.hook?.get_hook_bonus_additive(result)//Decide on order here so it can be multiplicative

		if(ispath(result, /obj/item/fish))
			//Modify fish roll chance
			var/obj/item/fish/caught_fish = result

			if(bait)
				final_table[result] = round(final_table[result] * result_multiplier, 1)
				if(!HAS_TRAIT(bait, TRAIT_OMNI_BAIT))
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

	///here we even out the chances of fishie based on bait quality: better baits lead rarer fishes being more common.
	if(leveling_exponent)
		var/highest_fish_weight
		var/list/collected_fish_weights = list()
		for(var/fishable in final_table)
			if(ispath(fishable, /obj/item/fish))
				var/fish_weight = fish_table[fishable]
				collected_fish_weights[fishable] = fish_weight
				if(fish_weight > highest_fish_weight)
					highest_fish_weight = fish_weight

		for(var/fish in collected_fish_weights)
			var/difference = highest_fish_weight - collected_fish_weights[fish]
			if(!difference)
				continue
			final_table[fish] += round(difference**leveling_exponent, 1)

	return final_table

/datum/fish_source/proc/spawn_reward_from_explosion(atom/location, severity)
	if(!explosive_malus)
		explosive_spawn(location, severity)
		return
	if(isnull(exploded_turfs))
		exploded_turfs = list()
		addtimer(CALLBACK(src, PROC_REF(post_explosion_spawn)), 1) //run this the next tick.
	var/turf/turf = get_turf(location)
	var/peak_severity = max(exploded_turfs[turf], severity)
	exploded_turfs[turf] = peak_severity

/datum/fish_source/proc/post_explosion_spawn()
	var/multiplier = 1/(length(exploded_turfs)**0.5)
	for(var/turf/turf as anything in exploded_turfs)
		explosive_spawn(turf, exploded_turfs[turf], multiplier)
	exploded_turfs = null

/datum/fish_source/proc/explosive_spawn(location, severity, multiplier = 1)
	for(var/i in 1 to (severity + 2))
		if(!prob((100 + 100 * severity)/i * multiplier))
			continue
		var/reward_loot = pick_weight(fish_table)
		var/atom/movable/reward = simple_dispense_reward(reward_loot, location, location)
		if(isnull(reward))
			continue
		if(isfish(reward))
			var/obj/item/fish/fish = reward
			fish.set_status(FISH_DEAD)
		if(isitem(reward))
			reward.pixel_x = rand(-9, 9)
			reward.pixel_y = rand(-9, 9)
		if(severity >= EXPLODE_DEVASTATE)
			reward.ex_act(EXPLODE_LIGHT)
