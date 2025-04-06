//Fish sources that're usually related to rifts or anomalies go here.

/datum/fish_source/carp_rift
	background = "background_carp_rift"
	catalog_description = "Space Dragon Rifts"
	radial_state = "carp"
	overlay_state = "portal_rift"
	fish_table = list(
		FISHING_DUD = 3,
		/obj/item/fish/baby_carp = 5,
		/mob/living/basic/carp = 1,
		/mob/living/basic/carp/passive = 1,
		/mob/living/basic/carp/mega = 1,
		/obj/item/clothing/head/fedora/carpskin = 1,
		/obj/item/toy/plush/carpplushie = 1,
		/obj/item/toy/plush/carpplushie/dehy_carp/peaceful = 1,
		/obj/item/knife/carp = 1,
	)
	fish_counts = list(
		/mob/living/basic/carp/mega = 2,
	)
	fish_count_regen = list(
		/mob/living/basic/carp/mega = 9 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 28
	associated_safe_turfs = list(/turf/open/space)

/datum/fish_source/dimensional_rift
	background = "background_mansus"
	catalog_description = null // it's a secret (sorta, I know you're reading this)
	radial_state = "cursed" // placeholder
	overlay_state = "portal_mansus"
	fish_table = list(
		FISHING_INFLUENCE = 6,
		FISHING_RANDOM_ARM = 3,
		/obj/item/fish/starfish/chrystarfish = 7,
		/obj/item/fish/dolphish = 7,
		/obj/item/fish/flumpulus = 7,
		/obj/item/fish/gullion = 7,
		/obj/item/fish/mossglob = 3,
		/obj/item/fish/babbelfish = 1,
		/mob/living/basic/heretic_summon/fire_shark/wild = 3,
		/obj/item/eldritch_potion/crucible_soul = 1,
		/obj/item/eldritch_potion/duskndawn = 1,
		/obj/item/eldritch_potion/wounded = 1,
		/obj/item/reagent_containers/cup/beaker/eldritch = 2,
	)
	fish_counts = list(
		/obj/item/fish/mossglob = 3,
		/obj/item/fish/babbelfish = 1,
		/mob/living/basic/heretic_summon/fire_shark/wild = 3,
		/obj/item/eldritch_potion/crucible_soul = 1,
		/obj/item/eldritch_potion/duskndawn = 1,
		/obj/item/eldritch_potion/wounded = 1,
		/obj/item/reagent_containers/cup/beaker/eldritch = 2,
	)
	fish_count_regen = list(
		/obj/item/fish/mossglob = 3 MINUTES,
		/obj/item/fish/babbelfish = 5 MINUTES,
		/mob/living/basic/heretic_summon/fire_shark/wild = 6 MINUTES,
		/obj/item/eldritch_potion/crucible_soul = 5 MINUTES,
		/obj/item/eldritch_potion/duskndawn = 5 MINUTES,
		/obj/item/eldritch_potion/wounded = 5 MINUTES,
		/obj/item/reagent_containers/cup/beaker/eldritch = 2.5 MINUTES,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 35
	fish_source_flags = FISH_SOURCE_FLAG_EXPLOSIVE_NONE

/**
 * You can fish up random arms, but you can also fish up arms (or heads, from TK) that were eaten at some point by a rift.
 * No need to check for what the location is, just get its limbs from its contents. It should always be a visible heretic rift. Should.
 */
/datum/fish_source/dimensional_rift/get_fish_table(atom/location, from_explosion = FALSE)
	. = ..()
	if(istype(location, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = location
		location = portal.current_linked_atom

	for(var/obj/item/eaten_thing in location.get_all_contents())
		.[eaten_thing] = 6

/datum/fish_source/dimensional_rift/on_challenge_completed(mob/user, datum/fishing_challenge/challenge, success)
	. = ..()

	if(!success)
		if(IS_HERETIC(user))
			return
		if(!user.get_active_hand())
			return influence_fished(user, challenge)
		on_epic_fail(user, challenge, success)
		return


	if(challenge.reward_path == FISHING_INFLUENCE)
		influence_fished(user, challenge)
		return

	return

/**
 * Override for influences and arms.
 */
/datum/fish_source/dimensional_rift/spawn_reward(reward_path, atom/spawn_location, atom/fishing_spot)
	switch(reward_path)
		if(FISHING_INFLUENCE)
			return
		if(FISHING_RANDOM_ARM)
			return arm_fished(spawn_location)
	return ..()

/**
 * This happens when a non-heretic fails the minigame. Their arm is ripped straight off and thrown into the rift.
 */
/datum/fish_source/dimensional_rift/proc/on_epic_fail(mob/user, datum/fishing_challenge/challenge, success)
	challenge.location.visible_message(span_danger("[challenge.location]'s tendrils lash out and pull on [user]'s [user.get_active_hand()], ripping it clean off and throwing it towards itself!"))
	var/obj/item/bodypart/random_arm = user.get_active_hand()
	random_arm.dismember(BRUTE, FALSE)
	random_arm.forceMove(user.drop_location())
	random_arm.throw_at(challenge.location, 7, 1, null, TRUE)
	// Abstract items shouldn't be thrown in!
	if(!(challenge.used_rod.item_flags & ABSTRACT))
		challenge.used_rod.forceMove(user.drop_location())
		challenge.used_rod.throw_at(challenge.location, 7, 1, null, TRUE)
	addtimer(CALLBACK(src, PROC_REF(check_item_location), challenge.location, random_arm, challenge.used_rod), 1 SECONDS)

/datum/fish_source/dimensional_rift/proc/check_item_location(atom/location, obj/item/bodypart/random_arm, obj/item/used_rod)
	for(var/obj/item/thingy in get_turf(location))
		// If it's not in the list and it's not what we know as the used rod, skip.
		// This lets fishing gloves be dragged in as well. I mean honestly if you try fishing in here with those you should just Fucking Die but that's for later.
		if(!is_type_in_list(thingy, list(/obj/item/bodypart, /obj/item/fishing_rod)) && (thingy != used_rod))
			continue
		thingy.forceMove(location)
		location.visible_message(span_danger("Tendrils lash out from [location] and greedily drag [thingy] inwards. You're probably never seeing [thingy] again."))

/datum/fish_source/dimensional_rift/proc/arm_fished(atom/spawn_location)
	var/obj/item/bodypart/arm/random_arm = pick(subtypesof(/obj/item/bodypart/arm))
	random_arm = new random_arm(spawn_location)
	spawn_location.visible_message(span_notice("A [random_arm] is snatched up from beneath the eldritch depths of [spawn_location]!"))
	return random_arm

/datum/fish_source/dimensional_rift/proc/influence_fished(mob/user, datum/fishing_challenge/challenge)
	if(challenge.reward_path != FISHING_INFLUENCE)
		return
	var/mob/living/carbon/human/human_user
	if(ishuman(user))
		human_user = user

	user.visible_message(span_danger("[user] reels [user.p_their()] [challenge.used_rod] in, catching a glimpse into the world beyond!"), span_notice("You catch.. a glimpse into the workings of the Mansus itself!"))
	// Heretics that fish in the rift gain knowledge.
	if(IS_HERETIC(user))
		human_user?.add_mood_event("rift fishing", /datum/mood_event/rift_fishing)
		var/obj/effect/heretic_influence/fishfluence = challenge.location
		// But only if it's an open rift
		if(!istype(fishfluence))
			to_chat(user, span_notice("You glimpse something fairly uninteresting."))
			return
		fishfluence.after_drain(user)
		var/datum/antagonist/heretic/heretic_datum = GET_HERETIC(user)
		if(heretic_datum)
			heretic_datum.knowledge_points++
			to_chat(user, "[span_hear("You hear a whisper...")] [span_hypnophrase("THE HIGHER I RISE, THE MORE I FISH.")]")
			// They can also gain an extra influence point if they infused their rod.
			if(HAS_TRAIT(challenge.used_rod, TRAIT_ROD_MANSUS_INFUSED))
				heretic_datum.knowledge_points++
			to_chat(user, span_boldnotice("Your infused rod improves your knowledge gain!"))
		return

	// Non-heretics instead go crazy
	human_user?.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10, 190)
	human_user?.add_mood_event("gates_of_mansus", /datum/mood_event/gates_of_mansus)
	human_user?.do_jitter_animation(50)
	// Hand fires at them from the location
	fire_curse_hand(user, get_turf(challenge.location))
