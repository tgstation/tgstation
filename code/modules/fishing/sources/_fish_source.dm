GLOBAL_LIST_INIT(preset_fish_sources, init_subtypes_w_path_keys(/datum/fish_source, list()))

/**
 * When adding new fishable rewards to a table/counts, you can specify an icon to show in place of the
 * generic fish icon in the minigame UI should the user have the TRAIT_REVEAL_FISH trait, by adding it to
 * this list.
 *
 * A lot of the icons here may be a tad inaccurate, but since we're limited to the free font awesome icons we
 * have access to, we got to make do.
 */
GLOBAL_LIST_INIT(specific_fish_icons, generate_specific_fish_icons())

/proc/generate_specific_fish_icons()
	var/list/return_list = zebra_typecacheof(list(
		/mob/living/basic/axolotl = FISH_ICON_CRITTER,
		/mob/living/basic/frog = FISH_ICON_CRITTER,
		/mob/living/basic/carp = FISH_ICON_DEF,
		/mob/living/basic/mining = FISH_ICON_HOSTILE,
		/obj/effect/decal/remains = FISH_ICON_BONE,
		/obj/effect/mob_spawn/corpse = FISH_ICON_BONE,
		/obj/effect/spawner/message_in_a_bottle = FISH_ICON_BOTTLE,
		/obj/item/coin = FISH_ICON_COIN,
		/obj/item/fish = FISH_ICON_DEF,
		/obj/item/fish/armorfish = FISH_ICON_CRAB,
		/obj/item/fish/boned = FISH_ICON_BONE,
		/obj/item/fish/chainsawfish = FISH_ICON_WEAPON,
		/obj/item/fish/chasm_crab = FISH_ICON_CRAB,
		/obj/item/fish/gunner_jellyfish = FISH_ICON_JELLYFISH,
		/obj/item/fish/holo/crab = FISH_ICON_CRAB,
		/obj/item/fish/holo/puffer = FISH_ICON_CHUNKY,
		/obj/item/fish/jumpercable = FISH_ICON_ELECTRIC,
		/obj/item/fish/lavaloop = FISH_ICON_WEAPON,
		/obj/item/fish/mastodon = FISH_ICON_BONE,
		/obj/item/fish/pike/armored = FISH_ICON_WEAPON,
		/obj/item/fish/pufferfish = FISH_ICON_CHUNKY,
		/obj/item/fish/sand_crab = FISH_ICON_CRAB,
		/obj/item/fish/skin_crab = FISH_ICON_CRAB,
		/obj/item/fish/slimefish = FISH_ICON_SLIME,
		/obj/item/fish/sludgefish = FISH_ICON_SLIME,
		/obj/item/fish/starfish = FISH_ICON_STAR,
		/obj/item/fish/stingray = FISH_ICON_WEAPON,
		/obj/item/fish/swordfish = FISH_ICON_WEAPON,
		/obj/item/fish/zipzap = FISH_ICON_ELECTRIC,
		/obj/item/seeds/grass = FISH_ICON_SEED,
		/obj/item/seeds/random = FISH_ICON_SEED,
		/obj/item/storage/wallet = FISH_ICON_COIN,
		/obj/item/stack/sheet/bone = FISH_ICON_BONE,
		/obj/item/stack/sheet/mineral = FISH_ICON_GEM,
		/obj/item/stack/ore = FISH_ICON_GEM,
		/obj/structure/closet/crate = FISH_ICON_COIN,
		/obj/structure/mystery_box = FISH_ICON_COIN,
	))

	return_list[FISHING_RANDOM_SEED] = FISH_ICON_SEED
	return return_list

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
	/// Any limited quantity stuff in this list will be readded to the counts after a while
	var/list/fish_count_regen
	/// A list of stuff that's currently waiting to be readded to fish_counts
	var/list/currently_on_regen
	/// Text shown as baloon alert when you roll a dud in the table
	var/duds = list("it was nothing", "the hook is empty")
	/// Baseline difficulty for fishing in this spot. THIS IS ADDED TO THE DEFAULT DIFFICULTY OF THE MINIGAME (15)
	var/fishing_difficulty = FISHING_DEFAULT_DIFFICULTY
	/// How the spot type is described in fish catalog section about fish sources, will be skipped if null
	var/catalog_description
	/// Background image name from /datum/asset/simple/fishing_minigame
	var/background = "background_default"
	/// It true, repeated and large explosions won't be as efficient. This is usually for fish sources that cover multiple turfs (i.e. rivers, oceans).
	var/explosive_malus = FALSE
	/// If explosive_malus is true, this will be used to keep track of the turfs where an explosion happened for when we'll spawn the loot.
	var/list/exploded_turfs
	///When linked to a fishing portal, this will be the icon_state of this option in the radial menu
	var/radial_state = "default"
	///When selected by the fishing portal, this will be the icon_state of the overlay shown on the machine.
	var/overlay_state = "portal_aquarium"
	/// Mindless mobs that can fish will never pull up items on this list
	var/static/list/profound_fisher_blacklist = typecacheof(list(
		/mob/living/basic/mining/lobstrosity,
		/obj/structure/closet/crate/necropolis/tendril,
	))


	///List of multipliers used to make fishes more common compared to everything else depending on bait quality, indexed from best to worst.
	var/static/weight_result_multiplier = list(
		TRAIT_GREAT_QUALITY_BAIT = 9,
		TRAIT_GOOD_QUALITY_BAIT = 3.5,
		TRAIT_BASIC_QUALITY_BAIT = 2,
	)
	///List of exponents used to level out the table weight differences between fish depending on bait quality.
	var/static/weight_leveling_exponents = list(
		TRAIT_GREAT_QUALITY_BAIT = 0.7,
		TRAIT_GOOD_QUALITY_BAIT = 0.55,
		TRAIT_BASIC_QUALITY_BAIT = 0.4,
	)

/datum/fish_source/New()
	if(!PERFORM_ALL_TESTS(focus_only/fish_sources_tables))
		return
	for(var/path in fish_counts)
		if(!(path in fish_table))
			stack_trace("path [path] found in the 'fish_counts' list but not in the 'fish_table'")

/datum/fish_source/Destroy()
	exploded_turfs = null
	return ..()

///Called when src is set as the fish source of a fishing spot component
/datum/fish_source/proc/on_fishing_spot_init(datum/component/fishing_spot/spot)
	return

///Called whenever a fishing spot with this fish source attached is deleted
/datum/fish_source/proc/on_fishing_spot_del(datum/component/fishing_spot/spot)

/// Can we fish in this spot at all. Returns DENIAL_REASON or null if we're good to go
/datum/fish_source/proc/reason_we_cant_fish(obj/item/fishing_rod/rod, mob/fisherman, atom/parent)
	return rod.reason_we_cant_fish(src)

/// Called below above proc, in case the fishing source has anything to do that isn't denial
/datum/fish_source/proc/on_start_fishing(obj/item/fishing_rod/rod, mob/fisherman, atom/parent)
	return

///Comsig proc from the fishing minigame for 'calculate_difficulty'
/datum/fish_source/proc/calculate_difficulty_minigame(datum/fishing_challenge/challenge, reward_path, obj/item/fishing_rod/rod, mob/fisherman, list/difficulty_holder)
	SIGNAL_HANDLER
	SHOULD_NOT_OVERRIDE(TRUE)
	difficulty_holder[1] += calculate_difficulty(reward_path, rod, fisherman)

	// Difficulty modifier added by the fisher's skill level
	if(!(challenge.special_effects & FISHING_MINIGAME_RULE_NO_EXP))
		difficulty_holder[1] += fisherman.mind?.get_skill_modifier(/datum/skill/fishing, SKILL_VALUE_MODIFIER)

	if(challenge.special_effects & FISHING_MINIGAME_RULE_KILL)
		challenge.RegisterSignal(src, COMSIG_FISH_SOURCE_REWARD_DISPENSED, TYPE_PROC_REF(/datum/fishing_challenge, hurt_fish))

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

	var/obj/item/fish/caught_fish = result
	var/list/fish_properties = SSfishing.fish_properties[caught_fish]
	// Baseline fish difficulty
	. += initial(caught_fish.fishing_difficulty_modifier)


	if(rod.bait)
		var/obj/item/bait = rod.bait
		//Fav bait makes it easier
		var/list/fav_bait = fish_properties[FISH_PROPERTIES_FAV_BAIT]
		for(var/bait_identifer in fav_bait)
			if(is_matching_bait(bait, bait_identifer))
				. += FAV_BAIT_DIFFICULTY_MOD
		//Disliked bait makes it harder
		var/list/disliked_bait = fish_properties[FISH_PROPERTIES_BAD_BAIT]
		for(var/bait_identifer in disliked_bait)
			if(is_matching_bait(bait, bait_identifer))
				. += DISLIKED_BAIT_DIFFICULTY_MOD

	// Matching/not matching fish traits and equipment
	var/list/fish_traits = fish_properties[FISH_PROPERTIES_TRAITS]

	var/additive_mod = 0
	var/multiplicative_mod = 1
	for(var/fish_trait in fish_traits)
		var/datum/fish_trait/trait = GLOB.fish_traits[fish_trait]
		var/list/mod = trait.difficulty_mod(rod, fisherman)
		additive_mod += mod[ADDITIVE_FISHING_MOD]
		multiplicative_mod *= mod[MULTIPLICATIVE_FISHING_MOD]

	. += additive_mod
	. *= multiplicative_mod

///Comsig proc from the fishing minigame for 'roll_reward'
/datum/fish_source/proc/roll_reward_minigame(datum/source, obj/item/fishing_rod/rod, mob/fisherman, atom/location, list/rewards)
	SIGNAL_HANDLER
	SHOULD_NOT_OVERRIDE(TRUE)
	rewards += roll_reward(rod, fisherman, location)

/// Returns a typepath or a special value which we use for spawning dispensing a reward later.
/datum/fish_source/proc/roll_reward(obj/item/fishing_rod/rod, mob/fisherman, atom/location)
	return pick_weight(get_modified_fish_table(rod, fisherman, location)) || FISHING_DUD

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
 * Proc called when the COMSIG_MOB_COMPLETE_FISHING signal is sent.
 * Check if we've succeeded. If so, write into memory and dispense the reward.
 */
/datum/fish_source/proc/on_challenge_completed(mob/user, datum/fishing_challenge/challenge, success)
	SIGNAL_HANDLER
	SHOULD_CALL_PARENT(TRUE)
	UnregisterSignal(user, COMSIG_MOB_COMPLETE_FISHING)
	if(!success)
		return
	var/turf/fishing_spot = get_turf(challenge.float)
	var/atom/movable/reward = dispense_reward(challenge.reward_path, user, fishing_spot)
	if(reward)
		user.add_mob_memory(/datum/memory/caught_fish, protagonist = user, deuteragonist = reward.name)
	SEND_SIGNAL(challenge.used_rod, COMSIG_FISHING_ROD_CAUGHT_FISH, reward, user)
	challenge.used_rod.consume_bait(reward)

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
	var/area/area = get_area(fishing_spot)
	if(!(area.area_flags & UNLIMITED_FISHING) && !isnull(fish_counts[reward_path])) // This is limited count result
		//Somehow, we're trying to spawn an expended reward.
		if(fish_counts[reward_path] <= 0)
			return null
		fish_counts[reward_path] -= 1
		var/regen_time = fish_count_regen?[reward_path]
		if(regen_time)
			LAZYADDASSOC(currently_on_regen, reward_path, 1)
			if(currently_on_regen[reward_path] == 1)
				addtimer(CALLBACK(src, PROC_REF(regen_count), reward_path), regen_time)

	var/atom/movable/reward = spawn_reward(reward_path, spawn_location, fishing_spot)
	SEND_SIGNAL(src, COMSIG_FISH_SOURCE_REWARD_DISPENSED, reward)
	return reward

/datum/fish_source/proc/regen_count(reward_path)
	if(!LAZYACCESS(currently_on_regen, reward_path))
		return
	fish_counts[reward_path] += 1
	currently_on_regen[reward_path] -= 1
	if(currently_on_regen[reward_path] <= 0)
		LAZYREMOVE(currently_on_regen, reward_path)
		return
	var/regen_time = fish_count_regen[reward_path]
	addtimer(CALLBACK(src, PROC_REF(regen_count), reward_path), regen_time)

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

/// Returns the fish table, with with the unavailable items from fish_counts removed.
/datum/fish_source/proc/get_fish_table()
	var/list/table = fish_table.Copy()
	for(var/result in table)
		if(!isnull(fish_counts[result]) && fish_counts[result] <= 0)
			table -= result
	return table

/// Builds a fish weights table modified by bait/rod/user properties
/datum/fish_source/proc/get_modified_fish_table(obj/item/fishing_rod/rod, mob/fisherman, atom/location)
	var/obj/item/bait = rod.bait
	///An exponent used to level out the table weight differences between fish depending on bait quality.
	var/leveling_exponent = 0
	///Multiplier used to make fishes more common compared to everything else.
	var/result_multiplier = 1


	var/list/final_table = get_fish_table()

	if(bait)
		for(var/trait in weight_result_multiplier)
			if(HAS_TRAIT(bait, trait))
				result_multiplier = weight_result_multiplier[trait]
				leveling_exponent = weight_leveling_exponents[trait]
				break


	if(HAS_TRAIT(rod, TRAIT_ROD_REMOVE_FISHING_DUD))
		final_table -= FISHING_DUD


	if(HAS_TRAIT(fisherman, TRAIT_PROFOUND_FISHER) && !fisherman.client)
		final_table -= profound_fisher_blacklist
	for(var/result in final_table)
		final_table[result] *= rod.hook?.get_hook_bonus_multiplicative(result)
		final_table[result] += rod.hook?.get_hook_bonus_additive(result)//Decide on order here so it can be multiplicative

		if(ispath(result, /obj/item/fish))
			if(bait)
				final_table[result] = round(final_table[result] * result_multiplier, 1)
				var/mult = bait.check_bait(result)
				final_table[result] = round(final_table[result] * mult, 1)
				if(mult > 1 && HAS_TRAIT(bait, TRAIT_BAIT_ALLOW_FISHING_DUD))
					final_table -= FISHING_DUD
			else
				final_table[result] = round(final_table[result] * FISH_WEIGHT_MULT_WITHOUT_BAIT, 1) //Fishing without bait is not going to be easy

			// Apply fish trait modifiers
			final_table[result] = get_fish_trait_catch_mods(final_table[result], result, rod, fisherman, location)

		if(final_table[result] <= 0)
			final_table -= result


	if(leveling_exponent)
		level_out_fish(final_table, leveling_exponent)

	return final_table

///A proc that levels out the weights of various fish, leading to rarer fishes being more common.
/datum/fish_source/proc/level_out_fish(list/table, exponent)
	var/highest_fish_weight
	var/list/collected_fish_weights = list()
	for(var/fishable in table)
		if(ispath(fishable, /obj/item/fish))
			var/fish_weight = table[fishable]
			collected_fish_weights[fishable] = fish_weight
			if(fish_weight > highest_fish_weight)
				highest_fish_weight = fish_weight

	for(var/fish in collected_fish_weights)
		var/difference = highest_fish_weight - collected_fish_weights[fish]
		if(!difference)
			continue
		table[fish] += round(difference**exponent, 1)

/datum/fish_source/proc/get_fish_trait_catch_mods(weight, obj/item/fish/fish, obj/item/fishing_rod/rod, mob/user, atom/location)
	if(!ispath(fish, /obj/item/fish))
		return weight
	var/multiplier = 1
	for(var/fish_trait in SSfishing.fish_properties[fish][FISH_PROPERTIES_TRAITS])
		var/datum/fish_trait/trait = GLOB.fish_traits[fish_trait]
		var/list/mod = trait.catch_weight_mod(rod, user, location, fish)
		weight += mod[ADDITIVE_FISHING_MOD]
		multiplier *= mod[MULTIPLICATIVE_FISHING_MOD]

	return round(weight * multiplier, 1)

///returns true if this fishing spot has fish that are shown in the catalog.
/datum/fish_source/proc/has_known_fishes()
	for(var/reward in fish_table)
		if(!ispath(reward, /obj/item/fish))
			continue
		var/obj/item/fish/prototype = reward
		if(initial(prototype.fish_flags) & FISH_FLAG_SHOW_IN_CATALOG)
			return TRUE
	return FALSE

///Add a string with the names of catchable fishes to the examine text.
/datum/fish_source/proc/get_catchable_fish_names(mob/user, atom/location, list/examine_text)
	var/list/known_fishes = list()

	var/obj/item/fishing_rod/rod = user.get_active_held_item()
	if(!istype(rod))
		rod = null

	for(var/reward in fish_table)
		if(!ispath(reward, /obj/item/fish))
			continue
		var/obj/item/fish/prototype = reward
		if(initial(prototype.fish_flags) & FISH_FLAG_SHOW_IN_CATALOG)
			var/init_name = initial(prototype.name)
			if(rod)
				var/init_weight = fish_table[reward]
				var/weight = (rod.bait ? rod.bait.check_bait(prototype) : 1)
				weight = get_fish_trait_catch_mods(weight, reward, rod, user, location)
				if(weight > init_weight)
					init_name = span_bold(init_name)
					if(weight/init_weight >= 3.5)
						init_name = "<u>init_name</u>"
				else if(weight < init_weight)
					init_name = span_small(init_name)
			known_fishes += init_name

	if(!length(known_fishes))
		return

	var/info = "You can catch the following fish here"

	if(rod)
		info = span_tooltip("boldened are the fish you're more likely to catch with your current setup. The opposite is true for smaller names", info)
	examine_text += span_info("[info]: [english_list(known_fishes)].")

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

/datum/fish_source/proc/explosive_spawn(atom/location, severity, multiplier = 1)
	for(var/i in 1 to (severity + 2))
		if(!prob((100 + 100 * severity)/i * multiplier))
			continue
		var/reward_loot = pick_weight(get_fish_table())
		var/atom/movable/reward = simple_dispense_reward(reward_loot, location, location)
		if(isnull(reward))
			continue
		if(isfish(reward))
			var/obj/item/fish/fish = reward
			fish.set_status(FISH_DEAD, silent = TRUE)
		if(isitem(reward))
			reward.pixel_x = rand(-9, 9)
			reward.pixel_y = rand(-9, 9)
		if(severity >= EXPLODE_DEVASTATE)
			reward.ex_act(EXPLODE_LIGHT)

///Called when releasing a fish in a fishing spot with the TRAIT_CATCH_AND_RELEASE trait.
/datum/fish_source/proc/readd_fish(obj/item/fish/fish, mob/living/releaser)
	var/is_morbid = HAS_MIND_TRAIT(releaser, TRAIT_MORBID)
	var/is_naive = HAS_MIND_TRAIT(releaser, TRAIT_NAIVE)
	if(fish.status == FISH_DEAD) //ded fish won't repopulate the sea.
		if(is_naive || is_morbid)
			releaser.add_mood_event("fish_released", /datum/mood_event/fish_released, is_morbid && !is_naive, fish)
		return
	if(((fish.type in fish_table) != is_morbid) || is_naive)
		releaser.add_mood_event("fish_released", /datum/mood_event/fish_released, is_morbid && !is_naive, fish)
	if(isnull(fish_counts[fish.type])) //This fish can be caught indefinitely so it won't matter.
		return
	//If this fish population isn't recovering from recent losses, we just increase it.
	if(!LAZYACCESS(currently_on_regen, fish.type))
		fish_counts[fish.type] += 1
	else
		regen_count(fish.type)

/**
 * Called by /datum/autowiki/fish_sources unless the catalog entry for this fish source is null.
 * It should Return a list of entries with keys named "name", "icon", "weight" and "notes"
 * detailing the contents of this fish source.
 */
/datum/fish_source/proc/generate_wiki_contents(datum/autowiki/fish_sources/wiki)
	var/list/data = list()
	var/list/only_fish = list()

	var/total_weight = 0
	var/total_weight_without_bait = 0
	var/total_weight_no_fish = 0

	var/list/tables_by_quality = list()
	var/list/total_weight_by_quality = list()
	var/list/total_weight_by_quality_no_fish = list()

	for(var/obj/item/fish/fish as anything in fish_table)
		var/weight = fish_table[fish]
		if(fish != FISHING_DUD)
			total_weight += weight
		if(!ispath(fish, /obj/item/fish))
			total_weight_without_bait += weight
			total_weight_no_fish += weight
			continue
		if(initial(fish.fish_flags) & FISH_FLAG_SHOW_IN_CATALOG)
			only_fish += fish
		total_weight_without_bait += round(fish_table[fish] * FISH_WEIGHT_MULT_WITHOUT_BAIT, 1)

	for(var/trait in weight_result_multiplier)
		var/list/table_copy = fish_table.Copy()
		table_copy -= FISHING_DUD
		var/exponent = weight_leveling_exponents[trait]
		var/multiplier = weight_result_multiplier[trait]
		for(var/fish as anything in table_copy)
			if(!ispath(fish, /obj/item/fish))
				continue
			table_copy[fish] = round(table_copy[fish] * multiplier, 1)

		level_out_fish(table_copy, exponent)
		tables_by_quality[trait] = table_copy

		var/tot_weight = 0
		var/tot_weight_no_fish = 0
		for(var/result in table_copy)
			var/weight = table_copy[result]
			tot_weight += weight
			if(!ispath(result, /obj/item/fish))
				tot_weight_no_fish += weight
		total_weight_by_quality[trait] = tot_weight
		total_weight_by_quality_no_fish[trait] = tot_weight_no_fish

	//show the improved weights in ascending orders for fish.
	tables_by_quality = reverseList(tables_by_quality)

	if(FISHING_DUD in fish_table)
		data += LIST_VALUE_WRAP_LISTS(list(
			FISH_SOURCE_AUTOWIKI_NAME = FISH_SOURCE_AUTOWIKI_DUD,
			FISH_SOURCE_AUTOWIKI_ICON = "",
			FISH_SOURCE_AUTOWIKI_WEIGHT = PERCENT(fish_table[FISHING_DUD]/total_weight_without_bait),
			FISH_SOURCE_AUTOWIKI_WEIGHT_SUFFIX = "WITHOUT A BAIT",
			FISH_SOURCE_AUTOWIKI_NOTES = "Unless you have a magnet or rescue hook or you know what you're doing, always use a bait",
		))

	for(var/obj/item/fish/fish as anything in only_fish)
		var/weight = fish_table[fish]
		var/deets = "Can be caught indefinitely"
		if(fish in fish_counts)
			deets = "It's quite rare and can only be caught up to [fish_counts[fish]] times"
			if(fish in fish_count_regen)
				deets += " every [DisplayTimeText(fish::breeding_timeout)]"
		var/list/weight_deets = list()
		for(var/trait in tables_by_quality)
			weight_deets += "[round(PERCENT(tables_by_quality[trait][fish]/total_weight_by_quality[trait]), 0.1)]%"
		var/weight_suffix = "([english_list(weight_deets, and_text = ", ")])"
		data += LIST_VALUE_WRAP_LISTS(list(
			FISH_SOURCE_AUTOWIKI_NAME = wiki.escape_value(full_capitalize(initial(fish.name))),
			FISH_SOURCE_AUTOWIKI_ICON = FISH_AUTOWIKI_FILENAME(fish),
			FISH_SOURCE_AUTOWIKI_WEIGHT = PERCENT(weight/total_weight),
			FISH_SOURCE_AUTOWIKI_WEIGHT_SUFFIX = weight_suffix,
			FISH_SOURCE_AUTOWIKI_NOTES = deets,
		))

	if(total_weight_no_fish) //There are things beside fish that we can catch.
		var/list/weight_deets = list()
		for(var/trait in tables_by_quality)
			weight_deets += "[round(PERCENT(total_weight_by_quality_no_fish[trait]/total_weight_by_quality[trait]), 0.1)]%"
		var/weight_suffix = "([english_list(weight_deets, and_text = ", ")])"
		data += LIST_VALUE_WRAP_LISTS(list(
			FISH_SOURCE_AUTOWIKI_NAME = FISH_SOURCE_AUTOWIKI_OTHER,
			FISH_SOURCE_AUTOWIKI_ICON = FISH_SOURCE_AUTOWIKI_QUESTIONMARK,
			FISH_SOURCE_AUTOWIKI_WEIGHT = PERCENT(total_weight_no_fish/total_weight),
			FISH_SOURCE_AUTOWIKI_WEIGHT_SUFFIX = weight_suffix,
			FISH_SOURCE_AUTOWIKI_NOTES = "Who knows what it may be. Try and find out",
		))

	return data
