/**
 * # The path of VOID.
 *
 * Goes as follows:
 *
 * Glimmer of Winter
 * Grasp of Void
 * Aristocrat's Way
 * > Sidepaths:
 *   Void Cloak
 *   Armorer's Ritual
 *
 * Mark of Void
 * Void Phase
 * > Sidepaths:
 *   Carving Knife
 *   Mawed Crucible
 *
 * Seeking blade
 * Void Pull
 * > Sidepaths:
 *   Rusted Ritual
 *   Blood Siphon
 *
 * Waltz at the End of Time
 */
/datum/heretic_knowledge/limited_amount/base_void
	name = "Glimmer of Winter"
	desc = "Opens up the path of void to you. \
		Allows you to transmute a knife in sub-zero temperatures into a Void Blade. \
		You can only create two at a time."
	gain_text = "I feel a shimmer in the air, the air around me gets colder. \
		I start to realize the emptiness of existance. Something's watching me."
	next_knowledge = list(/datum/heretic_knowledge/void_grasp)
	banned_knowledge = list(
		/datum/heretic_knowledge/limited_amount/base_ash,
		/datum/heretic_knowledge/limited_amount/base_flesh,
		/datum/heretic_knowledge/limited_amount/base_rust,
		/datum/heretic_knowledge/final/ash_final,
		/datum/heretic_knowledge/final/flesh_final,
		/datum/heretic_knowledge/final/rust_final,
	)
	required_atoms = list(/obj/item/knife = 1)
	result_atoms = list(/obj/item/melee/sickly_blade/void)
	limit = 2
	cost = 1
	route = PATH_VOID

/datum/heretic_knowledge/limited_amount/base_void/on_research(mob/user)
	. = ..()
	var/datum/antagonist/heretic/our_heretic = IS_HERETIC(user)
	our_heretic.heretic_path = route

/datum/heretic_knowledge/limited_amount/base_void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!isopenturf(loc))
		return FALSE

	var/turf/open/our_turf = loc
	if(our_turf.GetTemperature() > T0C)
		return FALSE

	return ..()

/datum/heretic_knowledge/void_grasp
	name = "Grasp of Void"
	desc = "Your Masus Grasp will temporarily mute and chill the victim."
	gain_text = "I saw the cold watcher who observes me. The chill mounts within me. \
		They are quiet. This isn't the end of the mystery."
	next_knowledge = list(/datum/heretic_knowledge/cold_snap)
	cost = 1
	route = PATH_VOID

/datum/heretic_knowledge/void_grasp/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)

/datum/heretic_knowledge/void_grasp/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/void_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	var/turf/open/target_turf = get_turf(carbon_target)
	target_turf.TakeTemperature(-20)
	carbon_target.adjust_bodytemperature(-40)
	carbon_target.silent += 4

/datum/heretic_knowledge/cold_snap
	name = "Aristocrat's Way"
	desc = "Grants you immunity to cold temperatures, and removing your need breathe. \
		You can still take damage due to lack of pressure."
	gain_text = "I found a thread of cold breath. It lead me to a strange shrine, all made of crystals. \
		Translucent and white, a depiction of a nobleman stood before me."
	next_knowledge = list(
		/datum/heretic_knowledge/void_mark,
		/datum/heretic_knowledge/codex_cicatrix,
		/datum/heretic_knowledge/void_cloak,
		/datum/heretic_knowledge/armor,
	)
	cost = 1
	route = PATH_VOID

/datum/heretic_knowledge/cold_snap/on_gain(mob/user)
	ADD_TRAIT(user, TRAIT_RESISTCOLD, type)
	ADD_TRAIT(user, TRAIT_NOBREATH, type)

/datum/heretic_knowledge/cold_snap/on_lose(mob/user)
	REMOVE_TRAIT(user, TRAIT_RESISTCOLD, type)
	REMOVE_TRAIT(user, TRAIT_NOBREATH, type)

/datum/heretic_knowledge/void_mark
	name = "Mark of Void"
	desc = "Your Mansus Grasp now applies the Mark of Void. The mark is triggered from an attack with your Void Blade. \
		When triggered, silences the victim and lowers their body temperature significantly."
	gain_text = "A gust of wind? A shimmer in the air? The presence is overwhelming, \
		my senses began to betray me. My mind is my own enemy."
	next_knowledge = list(/datum/heretic_knowledge/knowledge_ritual/void)
	banned_knowledge = list(
		/datum/heretic_knowledge/rust_mark,
		/datum/heretic_knowledge/ash_mark,
		/datum/heretic_knowledge/flesh_mark,
	)
	cost = 2
	route = PATH_VOID

/datum/heretic_knowledge/void_mark/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, .proc/on_mansus_grasp)
	RegisterSignal(user, COMSIG_HERETIC_BLADE_ATTACK, .proc/on_eldritch_blade)

/datum/heretic_knowledge/void_mark/on_lose(mob/user)
	UnregisterSignal(user, list(COMSIG_HERETIC_MANSUS_GRASP_ATTACK, COMSIG_HERETIC_BLADE_ATTACK))

/datum/heretic_knowledge/void_mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	target.apply_status_effect(/datum/status_effect/eldritch/void)

/datum/heretic_knowledge/void_mark/proc/on_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	var/datum/status_effect/eldritch/mark = target.has_status_effect(/datum/status_effect/eldritch)
	if(!istype(mark))
		return

	mark.on_effect()

/datum/heretic_knowledge/knowledge_ritual/void
	next_knowledge = list(/datum/heretic_knowledge/spell/void_phase)
	banned_knowledge = list(
		/datum/heretic_knowledge/knowledge_ritual/ash,
		/datum/heretic_knowledge/knowledge_ritual/rust,
		/datum/heretic_knowledge/knowledge_ritual/flesh,
	)
	route = PATH_VOID

/datum/heretic_knowledge/spell/void_phase
	name = "Void Phase"
	desc = "Grants you Void Phase, a long range targeted teleport spell. \
		Additionally causes damage to heathens around your original and target destination."
	gain_text = "The entity calls themself the Aristocrat. They effortlessly walk through air like\
		nothing leaving a harsh, cold breeze in their wake. They disappear, and I am left in the snow."
	next_knowledge = list(
		/datum/heretic_knowledge/void_blade_upgrade,
		/datum/heretic_knowledge/reroll_targets,
		/datum/heretic_knowledge/rune_carver,
		/datum/heretic_knowledge/crucible,
	)
	spell_to_add = /obj/effect/proc_holder/spell/pointed/void_phase
	cost = 1
	route = PATH_VOID

/datum/heretic_knowledge/void_blade_upgrade
	name = "Seeking blade"
	desc = "You can now attack distant marked targets with your Void Blade, teleporting directly next to them."
	gain_text = "Fleeting memories, fleeting feet. I mark my way with frozen blood upon the snow. Covered and forgotten."
	next_knowledge = list(/datum/heretic_knowledge/spell/voidpull)
	banned_knowledge = list(
		/datum/heretic_knowledge/ash_blade_upgrade,
		/datum/heretic_knowledge/flesh_blade_upgrade,
		/datum/heretic_knowledge/rust_blade_upgrade,
	)
	cost = 2
	route = PATH_VOID


/datum/heretic_knowledge/void_blade_upgrade/on_gain(mob/user)
	RegisterSignal(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK, .proc/on_ranged_eldritch_blade)

/datum/heretic_knowledge/void_blade_upgrade/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_RANGED_BLADE_ATTACK)

/datum/heretic_knowledge/void_blade_upgrade/proc/on_ranged_eldritch_blade(mob/living/user, mob/living/target)
	SIGNAL_HANDLER

	if(!target.has_status_effect(/datum/status_effect/eldritch))
		return

	var/dir = angle2dir(dir2angle(get_dir(user, target)) + 180)
	user.forceMove(get_step(target, dir))

	INVOKE_ASYNC(src, .proc/follow_up_attack, user, target)

/datum/heretic_knowledge/void_blade_upgrade/proc/follow_up_attack(mob/living/user, mob/living/target)
	var/obj/item/melee/sickly_blade/blade = user.get_active_held_item()
	blade?.melee_attack_chain(user, target)

/datum/heretic_knowledge/spell/voidpull
	name = "Void Pull"
	desc = "Grants you Void Pull, a spell that pulls all nearby heathens towards you, stunning them briefly."
	gain_text = "All is fleeting, but what else stays? I'm close to ending what was started. \
		The Aristocrat reveals themself to me again. They tell me I am late. Their pull is immense, I cannot turn back."
	next_knowledge = list(
		/datum/heretic_knowledge/final/void_final,
		/datum/heretic_knowledge/spell/blood_siphon,
		/datum/heretic_knowledge/summon/rusty
	)
	spell_to_add = /obj/effect/proc_holder/spell/targeted/void_pull
	cost = 1
	route = PATH_VOID

/datum/heretic_knowledge/final/void_final
	name = "Waltz at the End of Time"
	desc = "The ascension ritual of the Path of Void. \
		Bring 3 corpses to a transumation rune in sub-zero temperatures to complete the ritual. \
		When completed, causes a violent storm of void snow \
		to assault the station, freezing and damaging heathens. Those nearby will be silenced and frozen even quicker. \
		Additionally, you will become immune to the effects of space."
	gain_text = "The world falls into darkness. I stand in an empty plane, small flakes of ice fall from the sky. \
		The Aristocrat stands before me, beckoning. We will play a waltz to the whispers of dying reality, \
		as the world is destroyed before our eyes. The void will return all to nothing, WITNESS MY ASCENSION!"
	route = PATH_VOID
	///soundloop for the void theme
	var/datum/looping_sound/void_loop/sound_loop
	///Reference to the ongoing voidstrom that surrounds the heretic
	var/datum/weather/void_storm/storm

/datum/heretic_knowledge/final/void_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!isopenturf(loc))
		return FALSE

	var/turf/open/our_turf = loc
	if(our_turf.GetTemperature() > T0C)
		return FALSE

	return ..()

/datum/heretic_knowledge/final/void_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	priority_announce("[generate_heretic_text()] The nobleman of void [user.real_name] has arrived, step along the Waltz that ends worlds! [generate_heretic_text()]","[generate_heretic_text()]", ANNOUNCER_SPANOMALIES)
	user.client?.give_award(/datum/award/achievement/misc/void_ascension, user)
	ADD_TRAIT(user, TRAIT_RESISTLOWPRESSURE, MAGIC_TRAIT)

	// Let's get this show on the road!
	sound_loop = new(user, TRUE, TRUE)
	RegisterSignal(user, COMSIG_LIVING_LIFE, .proc/on_life)
	RegisterSignal(user, COMSIG_LIVING_DEATH, .proc/on_death)

/datum/heretic_knowledge/final/void_final/on_lose(mob/user)
	on_death() // Losing is pretty much dying. I think
	RegisterSignal(user, list(COMSIG_LIVING_LIFE, COMSIG_LIVING_DEATH))

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Any non-heretics nearby the heretic ([source])
 * are constantly silenced and battered by the storm.
 *
 * Also starts storms in any area that doesn't have one.
 */
/datum/heretic_knowledge/final/void_final/proc/on_life(mob/living/source, delta_time, times_fired)
	SIGNAL_HANDLER

	for(var/mob/living/carbon/close_carbon in view(5, source))
		if(IS_HERETIC_OR_MONSTER(close_carbon))
			continue
		close_carbon.silent += 1
		close_carbon.adjust_bodytemperature(-20)

	var/turf/open/source_turf = get_turf(source)
	if(!isopenturf(source_turf))
		return
	source_turf.TakeTemperature(-20)

	var/area/source_area = get_area(source)

	if(!storm)
		storm = new /datum/weather/void_storm(list(source_turf.z))
		storm.telegraph()

	storm.area_type = source_area.type
	storm.impacted_areas = list(source_area)
	storm.update_areas()

/**
 * Signal proc for [COMSIG_LIVING_DEATH].
 *
 * Stop the storm when the heretic passes away.
 */
/datum/heretic_knowledge/final/void_final/proc/on_death()
	SIGNAL_HANDLER

	if(sound_loop)
		sound_loop.stop()
	if(storm)
		storm.end()
		QDEL_NULL(storm)
