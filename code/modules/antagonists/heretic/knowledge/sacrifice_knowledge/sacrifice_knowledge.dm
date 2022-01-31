// The knowledge and process of heretic sacrificing.

/// How long we put the target so sleep for (during sacrifice).
#define SACRIFICE_SACRIFICE_SLEEP_DURATION 12 SECONDS
/// How long sacrifices must stay in the shadow realm to survive.
#define SACRIFICE_REALM_DURATION 2.5 MINUTES

/**
 * Allows the heretic to sacrifice living heart targets.
 */
/datum/heretic_knowledge/hunt_and_sacrifice
	name = "Heartbeat of the Mansus"
	desc = "Allows you to sacrifice targets to the Mansus by bringing them to a rune in critical (or worse) condition. \
		If you have no targets, stand on a transmutation rune and invoke it to aquire some."
	required_atoms = list(/mob/living/carbon/human = 1)
	cost = 0
	route = PATH_START
	/// If TRUE, we skip the ritual. Done when no targets can be found, to avoid locking up the heretic.
	var/skip_this_ritual = FALSE
	/// A weakref to the mind of our heretic.
	var/datum/weakref/heretic_mind_weakref
	/// Lazylist of weakrefs to minds that we won't pick as targets.
	var/list/datum/weakref/target_blacklist

/datum/heretic_knowledge/hunt_and_sacrifice/on_research(mob/user, regained = FALSE)
	. = ..()
	obtain_targets(user)
	heretic_mind_weakref = WEAKREF(user)
	if(!LAZYLEN(GLOB.heretic_sacrifice_landmarks))
		message_admins("Generating z-level for heretic sacrifices...")
		INVOKE_ASYNC(src, .proc/generate_heretic_z_level)

/// Generate the sacrifice z-level.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/generate_heretic_z_level()
	var/datum/map_template/heretic_sacrifice_level/new_level = new()
	if(!new_level.load_new_z())
		CRASH("Failed to initialize heretic sacrifice z-level!")

/datum/heretic_knowledge/hunt_and_sacrifice/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/obj/item/organ/heart/our_heart = user.getorganslot(ORGAN_SLOT_HEART)
	if(!our_heart || !HAS_TRAIT(our_heart, TRAIT_LIVING_HEART))
		return FALSE

	// We've got no targets set, let's try to set some. Adds the user to the list of atoms,
	// then returns TRUE if skip_this_ritual is FALSE and the user's on top of the rune.
	// If skip_this_ritual is TRUE, returns FALSE to fail the check and move onto the next ritual.
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(!LAZYLEN(heretic_datum.sac_targets))
		if(skip_this_ritual)
			return FALSE

		atoms += user
		return (user in range(1, loc))

	// Determine if livings in our atoms are valid
	for(var/mob/living/carbon/human/sacrifice in atoms)
		// If the mob's not in soft crit or worse, or isn't one of the sacrifices, remove it from the list
		if(sacrifice.stat < SOFT_CRIT || !(WEAKREF(sacrifice) in heretic_datum.sac_targets))
			atoms -= sacrifice

	// Finally, return TRUE if we have a mob remaining in our list
	// Otherwise, return FALSE and stop the ritual
	return !!(locate(/mob/living/carbon/human) in atoms)

/datum/heretic_knowledge/hunt_and_sacrifice/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(LAZYLEN(heretic_datum.sac_targets))
		sacrifice_process(user, selected_atoms, loc)
	else
		obtain_targets(user)

	return TRUE

/**
 * Obtain a list of targets for the user to hunt down and sacrifice.
 * Tries to get four targets (minds) with living human currents.
 *
 * Returns FALSE if no targets are found, TRUE if the targets list was populated.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/obtain_targets(mob/living/user)

	// First construct a list of minds that are valid objective targets.
	var/list/datum/mind/valid_targets = list()
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if(possible_target == user.mind)
			continue
		if(!ishuman(possible_target.current))
			continue
		if(possible_target.current.stat == DEAD)
			continue
		if(istype(get_area(possible_target), /area/shuttle/arrival))
			continue
		if(WEAKREF(possible_target) in target_blacklist)
			continue

		valid_targets += possible_target

	if(!valid_targets.len)
		to_chat(user, span_danger("No sacrifice targets could be found! Attempt the ritual later."))
		skip_this_ritual = TRUE
		addtimer(VARSET_CALLBACK(src, skip_this_ritual, FALSE), 5 MINUTES)
		return FALSE

	// Now, let's try to get four targets.
	// - One completely random
	// - One from your department
	// - One from security
	// - One from heads of staff ("high value")

	// First target (and list definition), random
	var/list/datum/mind/final_targets = list(pick_n_take(valid_targets))

	// Second target, department
	for(var/datum/mind/department_mind as anything in shuffle_inplace(valid_targets))
		if(department_mind.assigned_role?.departments_bitflags & user.mind.assigned_role?.departments_bitflags)
			final_targets += department_mind
			break

	// Third target, security
	for(var/datum/mind/sec_mind as anything in shuffle_inplace(valid_targets))
		if(sec_mind.assigned_role?.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
			final_targets += sec_mind
			break

	// Fourth target, command
	for(var/datum/mind/head_mind as anything in shuffle_inplace(valid_targets))
		if(head_mind.assigned_role?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
			final_targets += head_mind
			break

	// If any of our targets failed to aquire,
	// Let's run a loop until we get four total,
	// grabbing random targets.
	var/target_sanity = 0
	while(final_targets.len < 4 && valid_targets.len > 4 && target_sanity < 25)
		final_targets += pick_n_take(valid_targets)
		target_sanity++

	list_clear_nulls(final_targets)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)

	to_chat(user, span_danger("Your targets have been determined. Your Living Heart will allow you to track their position. Go and sacrifice them!"))
	for(var/datum/mind/chosen_mind as anything in final_targets)
		LAZYADD(heretic_datum.sac_targets, WEAKREF(chosen_mind.current))
		to_chat(user, span_danger("[chosen_mind.current.real_name], the [chosen_mind.assigned_role]."))
	return TRUE

/**
 * Begin the process of sacrificing the target.
 *
 * Arguments
 * * user - the mob doing the sacrifice (a heretic)
 * * selected_atoms - a list of all atoms chosen. Should be (at least) one human.
 * * loc - the turf the sacrifice is occuring on
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/sacrifice_process(mob/living/user, list/selected_atoms)

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/mob/living/carbon/human/sacrifice = locate() in selected_atoms
	if(!sacrifice)
		CRASH("[type] sacrifice_process didn't have a human in the atoms list. How'd it make it so far?")
	if(!(WEAKREF(sacrifice) in heretic_datum.sac_targets))
		CRASH("[type] sacrifice_process managed to get a non-target human. This is incorrect.")

	if(sacrifice.mind)
		LAZYADD(target_blacklist, WEAKREF(sacrifice.mind))
	LAZYREMOVE(heretic_datum.sac_targets, WEAKREF(sacrifice))

	to_chat(user, span_hypnophrase("Your patrons accepts your offer."))

	if(sacrifice.mind?.assigned_role?.departments_bitflags & DEPARTMENT_BITFLAG_COMMAND)
		heretic_datum.knowledge_points++
		heretic_datum.high_value_sacrifices++

	heretic_datum.total_sacrifices++
	heretic_datum.knowledge_points += 2

	if(!begin_sacrifice(sacrifice))
		disembowel_target(sacrifice)

/**
 * This proc is called from [proc/sacrifice_process] after the heretic successfully sacrifices [sac_target].
 *
 * Sets off a chain that sends the person sacrificed to the shadow realm to dodge hands to fight for survival.
 *
 * Arguments
 * * sac_target - the mob being sacrificed.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/begin_sacrifice(mob/living/carbon/human/sac_target)
	. = FALSE

	var/datum/mind/our_heretic_mind = heretic_mind_weakref?.resolve()
	var/datum/antagonist/heretic/our_heretic = our_heretic_mind?.has_antag_datum(/datum/antagonist/heretic)
	if(!our_heretic)
		CRASH("[type] - begin_sacrifice was called, and no heretic [our_heretic_mind ? "antag datum":"mind"] could be found!")

	if(!LAZYLEN(GLOB.heretic_sacrifice_landmarks))
		CRASH("[type] - begin_sacrifice was called, but no heretic sacrifice landmarks were found!")

	var/obj/effect/landmark/heretic/destination_landmark = GLOB.heretic_sacrifice_landmarks[our_heretic.heretic_path]
	if(!destination_landmark)
		CRASH("[type] - begin_sacrifice could not find a destination landmark to send the sacrifice! (heretic's path: [our_heretic.heretic_path])")

	var/turf/destination = get_turf(destination_landmark)

	sac_target.visible_message(span_danger("[sac_target] begins to shudder violenty as dark tendrils begin to drag them into thin air!"))
	sac_target.set_handcuffed(new /obj/item/restraints/handcuffs/energy/cult(sac_target))
	sac_target.update_handcuffed()
	sac_target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 85, 150)
	sac_target.do_jitter_animation(100)

	addtimer(CALLBACK(sac_target, /mob/living/carbon.proc/do_jitter_animation, 100), SACRIFICE_SLEEP_DURATION * (1/3))
	addtimer(CALLBACK(sac_target, /mob/living/carbon.proc/do_jitter_animation, 100), SACRIFICE_SLEEP_DURATION * (2/3))

	 // If our target is dead, and we fail to revive them, just disembowel them and be done
	if(!sac_target.heal_and_revive(50, span_danger("[sac_target]'s heart begins to beat with an unholy force as they return from death!")))
		return

	if(sac_target.AdjustUnconscious(SACRIFICE_SLEEP_DURATION))
		to_chat(sac_target, span_hypnophrase("Your mind feels torn apart as you fall into a shallow slumber..."))
	else
		to_chat(sac_target, span_hypnophrase("Your mind begins to tear apart as you watch dark tendrils envelop you."))

	sac_target.AdjustParalyzed(SACRIFICE_SLEEP_DURATION * 1.2)
	sac_target.AdjustImmobilized(SACRIFICE_SLEEP_DURATION * 1.2)

	addtimer(CALLBACK(src, .proc/after_target_sleeps, sac_target, destination), SACRIFICE_SLEEP_DURATION * 0.5) // Teleport to the minigame

	return TRUE

/**
 * This proc is called from [proc/begin_sacrifice] after the [sac_target] falls asleep, shortly after the sacrifice occurs.
 *
 * Teleports the [sac_target] to the heretic room, asleep.
 * If it fails to teleport, they will be disemboweled and stop the chain.
 *
 * Arguments
 * * sac_target - the mob being sacrificed.
 * * destination - the spot they're being teleported to.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_target_sleeps(mob/living/carbon/human/sac_target, turf/destination)
	// Send 'em to the destination. If the teleport fails, just disembowel them and stop the chain
	if(!destination || !do_teleport(sac_target, destination, asoundin = 'sound/magic/repulse.ogg', asoundout = 'sound/magic/blind.ogg', no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE))
		disembowel_target()
		return

	// If our target died during the (short) timer, and we fail to revive them, just disembowel them and stop the chain
	if(!sac_target.heal_and_revive(75, span_danger("[sac_target]'s heart begins to beat with an unholy force as they return from death!")))
		disembowel_target(sac_target)
		return

	to_chat(sac_target, span_big(span_hypnophrase("Unnatural forces begin to claw at your every being from beyond the veil.")))

	sac_target.apply_status_effect(/datum/status_effect/unholy_determination, SACRIFICE_REALM_DURATION)
	addtimer(CALLBACK(src, .proc/after_target_wakes, sac_target), SACRIFICE_SLEEP_DURATION * 0.5) // Begin the minigame
	RegisterSignal(sac_target, COMSIG_MOVABLE_Z_CHANGED, .proc/on_target_escape) // Cheese condition
	RegisterSignal(sac_target, COMSIG_LIVING_DEATH, .proc/on_target_death) // Loss condition

/**
 * This proc is called from [proc/after_target_sleeps] when the [sac_target] should be waking up.
 *
 * Begins the survival minigame, featuring the sacrifice targets.
 * Gives them Helgrasp, throwing cursed hands towards them that they must dodge to survive.
 * Also gives them a status effect, Unholy Determination, to help them in this endeavor.
 *
 * Then applies some miscellaneous effects.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_target_wakes(mob/living/carbon/human/sac_target)
	// About how long should the helgrasp last? (1 metab a tick = helgrasp_time / 2 ticks (so, 1 minute = 60 seconds = 30 ticks))
	var/helgrasp_time = 1 MINUTES

	sac_target.reagents?.add_reagent(/datum/reagent/inverse/helgrasp, helgrasp_time / 20)
	sac_target.apply_necropolis_curse(CURSE_BLINDING | CURSE_GRASPING)

	SEND_SIGNAL(sac_target, COMSIG_ADD_MOOD_EVENT, "shadow_realm", /datum/mood_event/shadow_realm)

	sac_target.flash_act()
	sac_target.blur_eyes(15)
	sac_target.Jitter(10)
	sac_target.Dizzy(10)
	sac_target.hallucination += 12
	sac_target.emote("scream")

	to_chat(sac_target, span_reallybig(span_hypnophrase("The grasp of the Mansus reveal themselves to you!")))
	to_chat(sac_target, span_hypnophrase("You feel invigorated! Fight to survive!"))
	// When it runs out, let them know they're almost home free
	addtimer(CALLBACK(src, .proc/after_helgrasp_ends, sac_target), helgrasp_time)
	addtimer(CALLBACK(src, .proc/return_target, sac_target), SACRIFICE_REALM_DURATION) // Win condition

/**
 * This proc is called from [proc/after_target_wakes] after the helgrasp runs out in the [sac_target].
 *
 * It gives them a message letting them know it's getting easier and they're almost free.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_helgrasp_ends(mob/living/carbon/human/sac_target)
	to_chat(sac_target, span_hypnophrase("The worst is behind you... Not much longer! Hold fast, or expire!"))

/**
 * This proc is called from [proc/begin_sacrifice] if the target survived the shadow realm, or [COMSIG_LIVING_DEATH] if they don't.
 *
 * Teleports [sac_target] back to a random safe turf on the station (or observer spawn if it fails to find a safe turf).
 * Also clears their status effects, unregisters any signals associated with the shadow realm, and sends a message
 * to the heretic who did the sacrificed about whether they survived, and where they ended up.
 *
 * Arguments
 * * sac_target - the mob being sacrificed
 * * heretic - the heretic who originally did the sacrifice.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/return_target(mob/living/carbon/human/sac_target)
	SIGNAL_HANDLER

	UnregisterSignal(sac_target, COMSIG_MOVABLE_Z_CHANGED)
	UnregisterSignal(sac_target, COMSIG_LIVING_DEATH)
	sac_target.remove_status_effect(/datum/status_effect/necropolis_curse)
	sac_target.remove_status_effect(/datum/status_effect/unholy_determination)
	sac_target.reagents?.del_reagent(/datum/reagent/inverse/helgrasp)
	SEND_SIGNAL(sac_target, COMSIG_CLEAR_MOOD_EVENT, "shadow_realm")

	if(!is_station_level(sac_target.z))
		return

	// Teleport them to a random safe coordinate on the station z level.
	var/turf/open/floor/safe_turf = find_safe_turf(extended_safety_checks = TRUE)
	var/obj/effect/landmark/observer_start/backup_loc = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	if(!safe_turf)
		safe_turf = get_turf(backup_loc)
		stack_trace("[type] - return_target was unable to find a safe turf for [sac_target] to return to. Defaulting to observer start turf.")

	if(!do_teleport(sac_target, safe_turf, asoundout = 'sound/magic/blind.ogg', no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE))
		safe_turf = get_turf(backup_loc)
		sac_target.forceMove(safe_turf)
		stack_trace("[type] - return_target was unable to teleport [sac_target] to the observer start turf. Forcemoving.")

	if(sac_target.stat == DEAD)
		after_return_dead_target(sac_target)
	else
		after_return_live_target(sac_target)

	var/datum/mind/our_heretic_mind = heretic_mind_weakref?.resolve()
	if(our_heretic_mind?.current)
		var/composed_return_message = ""
		composed_return_message += span_notice("Your victim, [sac_target], was returned to the station - ")
		if(sac_target.stat == DEAD)
			composed_return_message += span_red("dead. ")
		else
			composed_return_message += span_green("alive, but with a shattered mind. ")

		composed_return_message += span_notice("You hear a whisper... ")
		composed_return_message += span_hypnophrase(get_area_name(safe_turf, TRUE))
		to_chat(our_heretic_mind.current, composed_return_message)

/**
 * If they die in the shadow realm, they lost. Send them back.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/on_target_death(mob/living/carbon/human/sac_target, gibbed)
	SIGNAL_HANDLER

	to_chat(sac_target, span_userdanger("You failed to resist the horrors of the Mansus!"))
	if(!gibbed)
		return_target(sac_target)

/**
 * If they somehow cheese the shadow realm by teleporting out, they are disemboweled and killed.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/on_target_escape(mob/living/carbon/human/sac_target, old_z, new_z)
	SIGNAL_HANDLER

	to_chat(sac_target, span_userdanger("Your attempt to escape the Mansus is not taken kindly!"))
	disembowel_target(sac_target)
	sac_target.death() // Ends up calling return_target() via signal

/**
 * This proc is called from [proc/return_target] if the [sac_target] survives the shadow realm.
 *
 * Gives the sacrifice target some after effects upon ariving back to reality.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_return_live_target(mob/living/carbon/human/sac_target)
	to_chat(sac_target, span_hypnophrase("The fight is over - but at great cost. You have been returned to your realm in one piece."))
	to_chat(sac_target, span_hypnophrase("You can hardly remember anything from before and leading up to the experience - all you can think about are those horrific hands..."))

	// Oh god where are we?
	sac_target.flash_act()
	sac_target.add_confusion(60)
	sac_target.Jitter(60)
	sac_target.blur_eyes(50)
	sac_target.Dizzy(30)
	sac_target.AdjustKnockdown(80)
	sac_target.adjustStaminaLoss(120)

	// Glad i'm outta there, though!
	SEND_SIGNAL(sac_target, COMSIG_ADD_MOOD_EVENT, "shadow_realm_survived", /datum/mood_event/shadow_realm_live)
	SEND_SIGNAL(sac_target, COMSIG_ADD_MOOD_EVENT, "shadow_realm_survived_sadness", /datum/mood_event/shadow_realm_live_sad)

	// Could use a little pick-me-up...
	sac_target.reagents?.add_reagent(/datum/reagent/medicine/atropine, 8)
	sac_target.reagents?.add_reagent(/datum/reagent/medicine/epinephrine, 8)

/**
 * This proc is called from [proc/return_target] if the target dies in the shadow realm.
 *
 * After teleporting the target back to the station (dead),
 * it spawns a special broken illusion to hint to the rescuers what happened.
 *
 * 1 to 2 minutes later, a centcom announcement is sent detailing where the person landed.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_return_dead_target(mob/living/carbon/human/sac_target)
	var/turf/landing_turf = get_turf(sac_target)
	addtimer(CALLBACK(src, .proc/announce_dead_target, landing_turf), rand(1 MINUTES, 2 MINUTES))

	var/obj/effect/visible_heretic_influence/illusion = new(landing_turf)
	illusion.name = "\improper weakened rift in reality"
	illusion.desc = "A rift wide enough for something... or someone... to come through."
	illusion.color = COLOR_DARK_RED

/**
 * Makes a centcom announcement about our dead person returning on [landing_turf].
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/announce_dead_target(turf/landing_turf)
	priority_announce("Attention, crew. We recorded an anomalous dimensional occurance in: \
		[get_area_name(landing_turf, TRUE)]. We're unsure of what it could be, \
		but something just appeared in the area. We suggest checking it out.", \
		"Central Command Higher Dimensional Affairs")

/**
 * "Fuck you" proc that gets called if the chain is interrupted at some points.
 * Simply disembowels the [sac_target] and brutilizes their body, as it did.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/disembowel_target(mob/living/carbon/human/sac_target)
	sac_target.spill_organs()
	sac_target.apply_damage(250, BRUTE)
	sac_target.visible_message(
		span_danger("[sac_target]'s organs are pulled out of their chest by shadowy hands!"),
		span_userdanger("Your organs are violently pulled out of your chest by shadowy hands!")
	)
