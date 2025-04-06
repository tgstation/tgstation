
/datum/heretic_knowledge_tree_column/main/void
	neighbour_type_left = /datum/heretic_knowledge_tree_column/flesh_to_void
	neighbour_type_right = /datum/heretic_knowledge_tree_column/void_to_blade

	route = PATH_VOID
	ui_bgr = "node_void"

	start = /datum/heretic_knowledge/limited_amount/starting/base_void
	grasp = /datum/heretic_knowledge/void_grasp
	tier1 = /datum/heretic_knowledge/cold_snap
	mark = 	/datum/heretic_knowledge/mark/void_mark
	ritual_of_knowledge = /datum/heretic_knowledge/knowledge_ritual/void
	unique_ability = /datum/heretic_knowledge/spell/void_conduit
	tier2 = /datum/heretic_knowledge/spell/void_phase
	blade = /datum/heretic_knowledge/blade_upgrade/void
	tier3 =	/datum/heretic_knowledge/spell/void_pull
	ascension = /datum/heretic_knowledge/ultimate/void_final

/datum/heretic_knowledge/limited_amount/starting/base_void
	name = "Glimmer of Winter"
	desc = "Opens up the Path of Void to you. \
		Allows you to transmute a knife in sub-zero temperatures into a Void Blade. \
		You can only create two at a time."
	gain_text = "I feel a shimmer in the air, the air around me gets colder. \
		I start to realize the emptiness of existence. Something's watching me."
	required_atoms = list(/obj/item/knife = 1)
	result_atoms = list(/obj/item/melee/sickly_blade/void)
	research_tree_icon_path = 'icons/obj/weapons/khopesh.dmi'
	research_tree_icon_state = "void_blade"

/datum/heretic_knowledge/limited_amount/starting/base_void/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!isopenturf(loc))
		loc.balloon_alert(user, "ritual failed, invalid location!")
		return FALSE

	var/turf/open/our_turf = loc
	if(our_turf.GetTemperature() > T0C)
		loc.balloon_alert(user, "ritual failed, not cold enough!")
		return FALSE

	return ..()

/datum/heretic_knowledge/void_grasp
	name = "Grasp of Void"
	desc = "Your Mansus Grasp will temporarily mute and chill the victim."
	gain_text = "I saw the cold watcher who observes me. The chill mounts within me. \
		They are quiet. This isn't the end of the mystery."
	cost = 1
	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "grasp_void"

/datum/heretic_knowledge/void_grasp/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/heretic_knowledge/void_grasp/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/heretic_knowledge/void_grasp/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!iscarbon(target))
		return

	var/mob/living/carbon/carbon_target = target
	carbon_target.adjust_silence(10 SECONDS)
	carbon_target.apply_status_effect(/datum/status_effect/void_chill, 2)

/datum/heretic_knowledge/cold_snap
	name = "Aristocrat's Way"
	desc = "Grants you immunity to cold temperatures, and removes your need to breathe. \
		You can still take damage due to a lack of pressure."
	gain_text = "I found a thread of cold breath. It lead me to a strange shrine, all made of crystals. \
		Translucent and white, a depiction of a nobleman stood before me."
	cost = 1
	research_tree_icon_path = 'icons/effects/effects.dmi'
	research_tree_icon_state = "the_freezer"

	/// Traits we apply to become immune to the environment
	var/static/list/gain_traits = list(TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE)

/datum/heretic_knowledge/cold_snap/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	user.add_traits(list(TRAIT_NOBREATH, TRAIT_RESISTCOLD), type)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(check_environment))

/datum/heretic_knowledge/cold_snap/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	user.remove_traits(list(TRAIT_RESISTCOLD, TRAIT_NOBREATH), type)
	UnregisterSignal(user, COMSIG_LIVING_LIFE)

///Checks if our traits should be active
/datum/heretic_knowledge/cold_snap/proc/check_environment(mob/living/user)
	SIGNAL_HANDLER

	var/datum/gas_mixture/environment = user.loc?.return_air()
	if(!isnull(environment))
		var/affected_temperature = environment.return_temperature()
		var/affected_pressure = environment.return_pressure()
		if(affected_temperature <= T0C || affected_pressure < ONE_ATMOSPHERE)
			user.add_traits(gain_traits, type)
		else
			user.remove_traits(gain_traits, type)

/datum/heretic_knowledge/mark/void_mark
	name = "Mark of Void"
	desc = "Your Mansus Grasp now applies the Mark of Void. The mark is triggered from an attack with your Void Blade. \
		When triggered, further silences the victim and swiftly lowers the temperature of their body and the air around them."
	gain_text = "A gust of wind? A shimmer in the air? The presence is overwhelming, \
		my senses began to betray me. My mind is my own enemy."
	mark_type = /datum/status_effect/eldritch/void

/datum/heretic_knowledge/knowledge_ritual/void

/datum/heretic_knowledge/spell/void_conduit
	name = "Void Conduit"
	desc = "Grants you Void Conduit, a spell which summons a pulsing gate to the Void itself. Every pulse breaks windows and airlocks, while afflicting Heathens with an eldritch chill and shielding Heretics against low pressure."
	gain_text = "The hum in the still, cold air turns to a cacophonous rattle. \
		Over the noise, there is no distinction to the clattering of window panes and the yawning knowledge that ricochets through my skull. \
		The doors won't close. I can't keep the cold out now."
	action_to_add = /datum/action/cooldown/spell/conjure/void_conduit
	cost = 1

/datum/heretic_knowledge/spell/void_phase
	name = "Void Phase"
	desc = "Grants you Void Phase, a long range targeted teleport spell. \
		Additionally causes damage to heathens around your original and target destination."
	gain_text = "The entity calls themself the Aristocrat. They effortlessly walk through air like \
		nothing - leaving a harsh, cold breeze in their wake. They disappear, and I am left in the blizzard."
	action_to_add = /datum/action/cooldown/spell/pointed/void_phase
	cost = 1
	research_tree_icon_frame = 7

/datum/heretic_knowledge/blade_upgrade/void
	name = "Seeking Blade"
	desc = "Your blade now freezes enemies. Additionally, you can now attack distant marked targets with your Void Blade, teleporting directly next to them."
	gain_text = "Fleeting memories, fleeting feet. I mark my way with frozen blood upon the snow. Covered and forgotten."


	research_tree_icon_path = 'icons/ui_icons/antags/heretic/knowledge.dmi'
	research_tree_icon_state = "blade_upgrade_void"

/datum/heretic_knowledge/blade_upgrade/void/do_melee_effects(mob/living/source, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(source == target || !isliving(target))
		return

	target.apply_status_effect(/datum/status_effect/void_chill, 2)

/datum/heretic_knowledge/blade_upgrade/void/do_ranged_effects(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	if(!target.has_status_effect(/datum/status_effect/eldritch))
		return

	var/dir = angle2dir(dir2angle(get_dir(user, target)) + 180)
	user.forceMove(get_step(target, dir))

	INVOKE_ASYNC(src, PROC_REF(follow_up_attack), user, target, blade)

/datum/heretic_knowledge/blade_upgrade/void/proc/follow_up_attack(mob/living/user, mob/living/target, obj/item/melee/sickly_blade/blade)
	blade.melee_attack_chain(user, target)

/datum/heretic_knowledge/spell/void_pull
	name = "Void Pull"
	desc = "Grants you Void Pull, a spell that pulls all nearby heathens towards you, stunning them briefly."
	gain_text = "All is fleeting, but what else stays? I'm close to ending what was started. \
		The Aristocrat reveals themselves to me again. They tell me I am late. Their pull is immense, I cannot turn back."

	action_to_add = /datum/action/cooldown/spell/aoe/void_pull
	cost = 1


	research_tree_icon_frame = 6

/datum/heretic_knowledge/ultimate/void_final
	name = "Waltz at the End of Time"
	desc = "The ascension ritual of the Path of Void. \
		Bring 3 corpses to a transmutation rune in sub-zero temperatures to complete the ritual. \
		When completed, causes a violent storm of void snow \
		to assault the station, freezing and damaging heathens. Those nearby will be silenced and frozen even quicker. \
		Additionally, you will become immune to the effects of space."
	gain_text = "The world falls into darkness. I stand in an empty plane, small flakes of ice fall from the sky. \
		The Aristocrat stands before me, beckoning. We will play a waltz to the whispers of dying reality, \
		as the world is destroyed before our eyes. The void will return all to nothing, WITNESS MY ASCENSION!"

	ascension_achievement = /datum/award/achievement/misc/void_ascension
	announcement_text = "%SPOOKY% The nobleman of void %NAME% has arrived, stepping along the Waltz that ends worlds! %SPOOKY%"
	announcement_sound = 'sound/music/antag/heretic/ascend_void.ogg'
	///soundloop for the void theme
	var/datum/looping_sound/void_loop/sound_loop
	///Reference to the ongoing voidstrom that surrounds the heretic
	var/datum/weather/void_storm/storm
	///The storm where there are actual effects
	var/datum/proximity_monitor/advanced/void_storm/heavy_storm

/datum/heretic_knowledge/ultimate/void_final/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	if(!isopenturf(loc))
		loc.balloon_alert(user, "ritual failed, invalid location!")
		return FALSE

	var/turf/open/our_turf = loc
	if(our_turf.GetTemperature() > T0C)
		loc.balloon_alert(user, "ritual failed, not cold enough!")
		return FALSE

	return ..()

/datum/heretic_knowledge/ultimate/void_final/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	. = ..()
	user.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_NEGATES_GRAVITY, TRAIT_MOVE_FLYING, TRAIT_FREE_HYPERSPACE_MOVEMENT), type)

	// Let's get this show on the road!
	sound_loop = new(user, TRUE, TRUE)
	RegisterSignal(user, COMSIG_LIVING_LIFE, PROC_REF(on_life))
	RegisterSignal(user, COMSIG_ATOM_PRE_BULLET_ACT, PROC_REF(hit_by_projectile))
	RegisterSignals(user, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_death))
	heavy_storm = new(user, 10)
	if(ishuman(user))
		var/mob/living/carbon/human/ascended_human = user
		var/obj/item/organ/eyes/heretic_eyes = ascended_human.get_organ_slot(ORGAN_SLOT_EYES)
		heretic_eyes?.color_cutoffs = list(30, 30, 30)
		ascended_human.update_sight()

/datum/heretic_knowledge/ultimate/void_final/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	on_death() // Losing is pretty much dying. I think

/**
 * Signal proc for [COMSIG_LIVING_LIFE].
 *
 * Any non-heretics nearby the heretic ([source])
 * are constantly silenced and battered by the storm.
 *
 * Also starts storms in any area that doesn't have one.
 */
/datum/heretic_knowledge/ultimate/void_final/proc/on_life(mob/living/source, seconds_per_tick, times_fired)
	SIGNAL_HANDLER

	for(var/atom/thing_in_range as anything in range(10, source))
		if(iscarbon(thing_in_range))
			var/mob/living/carbon/close_carbon = thing_in_range
			if(IS_HERETIC_OR_MONSTER(close_carbon))
				close_carbon.apply_status_effect(/datum/status_effect/void_conduit)
				continue
			close_carbon.adjust_silence_up_to(2 SECONDS, 20 SECONDS)
			close_carbon.apply_status_effect(/datum/status_effect/void_chill, 1)
			close_carbon.adjust_eye_blur(rand(0 SECONDS, 2 SECONDS))
			close_carbon.adjust_bodytemperature(-30 * TEMPERATURE_DAMAGE_COEFFICIENT)

		if(istype(thing_in_range, /obj/machinery/door) || istype(thing_in_range, /obj/structure/door_assembly))
			var/obj/affected_door = thing_in_range
			affected_door.take_damage(rand(60, 80))

		if(istype(thing_in_range, /obj/structure/window) || istype(thing_in_range, /obj/structure/grille))
			var/obj/structure/affected_structure = thing_in_range
			affected_structure.take_damage(rand(20, 40))

		if(isturf(thing_in_range))
			var/turf/affected_turf = thing_in_range
			var/datum/gas_mixture/environment = affected_turf.return_air()
			environment.temperature *= 0.9

	// Telegraph the storm in every area on the station.
	var/list/station_levels = SSmapping.levels_by_trait(ZTRAIT_STATION)
	if(!storm)
		storm = new /datum/weather/void_storm(station_levels)
		storm.telegraph()

/**
 * Signal proc for [COMSIG_LIVING_DEATH].
 *
 * Stop the storm when the heretic passes away.
 */
/datum/heretic_knowledge/ultimate/void_final/proc/on_death(datum/source)
	SIGNAL_HANDLER

	if(sound_loop)
		sound_loop.stop()
	if(storm)
		storm.end()
		QDEL_NULL(storm)
	if(heavy_storm)
		QDEL_NULL(heavy_storm)
	UnregisterSignal(source, list(COMSIG_LIVING_LIFE, COMSIG_ATOM_PRE_BULLET_ACT, COMSIG_LIVING_DEATH, COMSIG_QDELETING))

///Few checks to determine if we can deflect bullets
/datum/heretic_knowledge/ultimate/void_final/proc/can_deflect(mob/living/ascended_heretic)
	if(!(ascended_heretic.mobility_flags & MOBILITY_USE))
		return FALSE
	if(!isturf(ascended_heretic.loc))
		return FALSE
	return TRUE

/datum/heretic_knowledge/ultimate/void_final/proc/hit_by_projectile(mob/living/ascended_heretic, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	if(!can_deflect(ascended_heretic))
		return NONE

	ascended_heretic.visible_message(
		span_danger("The void storm surrounding [ascended_heretic] deflects [hitting_projectile]!"),
		span_userdanger("The void storm protects you from [hitting_projectile]!"),
	)
	playsound(ascended_heretic, SFX_VOID_DEFLECT, 75, TRUE)
	hitting_projectile.firer = ascended_heretic
	if(prob(75))
		hitting_projectile.set_angle(get_angle(hitting_projectile.firer, hitting_projectile.fired_from))
	else
		hitting_projectile.set_angle(rand(0, 360))//SHING
	return COMPONENT_BULLET_PIERCED
