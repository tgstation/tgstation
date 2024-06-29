// The knowledge and process of heretic sacrificing.

/// How long we put the target so sleep for (during sacrifice).
#define SACRIFICE_SLEEP_DURATION (12 SECONDS)
/// How long sacrifices must stay in the shadow realm to survive.
#define SACRIFICE_REALM_DURATION (2.5 MINUTES)

/**
 * Allows the heretic to sacrifice living heart targets.
 */
/datum/heretic_knowledge/hunt_and_sacrifice
	name = "Heartbeat of the Mansus"
	desc = "Allows you to sacrifice targets to the Mansus by bringing them to a rune in critical (or worse) condition. \
		If you have no targets, stand on a transmutation rune and invoke it to acquire some."
	required_atoms = list(/mob/living/carbon/human = 1)
	cost = 0
	priority = MAX_KNOWLEDGE_PRIORITY // Should be at the top
	route = PATH_START
	research_tree_icon_path = 'icons/effects/eldritch.dmi'
	research_tree_icon_state = "eye_close"
	research_tree_icon_frame = 1
	/// How many targets do we generate?
	var/num_targets_to_generate = 5
	/// Whether we've generated a heretic sacrifice z-level yet, from any heretic.
	var/static/heretic_level_generated = FALSE
	/// A weakref to the mind of our heretic.
	var/datum/mind/heretic_mind
	/// Lazylist of minds that we won't pick as targets.
	var/list/datum/mind/target_blacklist
	/// An assoc list of [ref] to [timers] - a list of all the timers of people in the shadow realm currently
	var/list/return_timers
	/// Evil organs we can put in people
	var/static/list/grantable_organs = list(
		/obj/item/organ/internal/appendix/corrupt,
		/obj/item/organ/internal/eyes/corrupt,
		/obj/item/organ/internal/heart/corrupt,
		/obj/item/organ/internal/liver/corrupt,
		/obj/item/organ/internal/lungs/corrupt,
		/obj/item/organ/internal/stomach/corrupt,
		/obj/item/organ/internal/tongue/corrupt,
	)

/datum/heretic_knowledge/hunt_and_sacrifice/Destroy(force)
	heretic_mind = null
	LAZYCLEARLIST(target_blacklist)
	return ..()

/datum/heretic_knowledge/hunt_and_sacrifice/on_research(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	obtain_targets(user, silent = TRUE, heretic_datum = our_heretic)
	heretic_mind = our_heretic.owner

#ifndef UNIT_TESTS // This is a decently hefty thing to generate while unit testing, so we should skip it.
	if(!heretic_level_generated)
		heretic_level_generated = TRUE
		log_game("Loading heretic lazytemplate for heretic sacrifices...")
		INVOKE_ASYNC(src, PROC_REF(generate_heretic_z_level))
#endif

/// Generate the sacrifice z-level.
/datum/heretic_knowledge/hunt_and_sacrifice/proc/generate_heretic_z_level()
	if(!SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_HERETIC_SACRIFICE))
		log_game("The heretic sacrifice template failed to load.")
		message_admins("The heretic sacrifice lazy template failed to load. Heretic sacrifices won't be teleported to the shadow realm. \
			If you want, you can spawn an /obj/effect/landmark/heretic somewhere to stop that from happening.")
		CRASH("Failed to lazy load heretic sacrifice template!")

/datum/heretic_knowledge/hunt_and_sacrifice/recipe_snowflake_check(mob/living/user, list/atoms, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	// First we have to check if the heretic has a Living Heart.
	// You may wonder why we don't straight up prevent them from invoking the ritual if they don't have one -
	// Hunt and sacrifice should always be invokable for clarity's sake, even if it'll fail immediately.
	if(heretic_datum.has_living_heart() != HERETIC_HAS_LIVING_HEART)
		loc.balloon_alert(user, "ritual failed, no living heart!")
		return FALSE

	// We've got no targets set, let's try to set some.
	// If we recently failed to aquire targets, we will be unable to aquire any.
	if(!LAZYLEN(heretic_datum.sac_targets))
		atoms += user
		return TRUE

	// If we have targets, we can check to see if we can do a sacrifice
	// Let's remove any humans in our atoms list that aren't a sac target
	for(var/mob/living/carbon/human/sacrifice in atoms)
		// If the mob's not in soft crit or worse, remove from list
		if(sacrifice.stat < SOFT_CRIT)
			atoms -= sacrifice
		// Otherwise if it's neither a target nor a cultist, remove it
		else if(!(sacrifice in heretic_datum.sac_targets) && !IS_CULTIST(sacrifice))
			atoms -= sacrifice

	// Finally, return TRUE if we have a target in the list
	if(locate(/mob/living/carbon/human) in atoms)
		return TRUE

	// or FALSE if we don't
	loc.balloon_alert(user, "ritual failed, no sacrifice found!")
	return FALSE

/datum/heretic_knowledge/hunt_and_sacrifice/on_finished_recipe(mob/living/user, list/selected_atoms, turf/loc)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	// Force it to work if the sacrifice is a cultist, even if there's no targets.
	var/mob/living/carbon/human/sac = selected_atoms[1]
	if(!LAZYLEN(heretic_datum.sac_targets) && !IS_CULTIST(sac))
		if(obtain_targets(user, heretic_datum = heretic_datum))
			return TRUE
		else
			loc.balloon_alert(user, "ritual failed, no targets found!")
			return FALSE

	sacrifice_process(user, selected_atoms, loc)
	return TRUE

/**
 * Obtain a list of targets for the user to hunt down and sacrifice.
 * Tries to get four targets (minds) with living human currents.
 *
 * Returns FALSE if no targets are found, TRUE if the targets list was populated.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/obtain_targets(mob/living/user, silent = FALSE, datum/antagonist/heretic/heretic_datum)

	// First construct a list of minds that are valid objective targets.
	var/list/datum/mind/valid_targets = list()
	for(var/datum/mind/possible_target as anything in get_crewmember_minds())
		if(possible_target == user.mind)
			continue
		if(possible_target in target_blacklist)
			continue
		if(!ishuman(possible_target.current))
			continue
		if(possible_target.current.stat == DEAD)
			continue

		valid_targets += possible_target

	if(!length(valid_targets))
		if(!silent)
			to_chat(user, span_hierophant_warning("No sacrifice targets could be found!"))
		return FALSE

	// Now, let's try to get four targets.
	// - One completely random
	// - One from your department
	// - One from security
	// - One from heads of staff ("high value")
	var/list/datum/mind/final_targets = list()

	// First target, any command.
	for(var/datum/mind/head_mind as anything in shuffle(valid_targets))
		if(head_mind.assigned_role?.job_flags & JOB_HEAD_OF_STAFF)
			final_targets += head_mind
			valid_targets -= head_mind
			break

	// Second target, any security
	for(var/datum/mind/sec_mind as anything in shuffle(valid_targets))
		if(sec_mind.assigned_role?.departments_bitflags & DEPARTMENT_BITFLAG_SECURITY)
			final_targets += sec_mind
			valid_targets -= sec_mind
			break

	// Third target, someone in their department.
	for(var/datum/mind/department_mind as anything in shuffle(valid_targets))
		if(department_mind.assigned_role?.departments_bitflags & user.mind.assigned_role?.departments_bitflags)
			final_targets += department_mind
			valid_targets -= department_mind
			break

	// Now grab completely random targets until we'll full
	var/target_sanity = 0
	while(length(final_targets) < num_targets_to_generate && length(valid_targets) > num_targets_to_generate && target_sanity < 25)
		final_targets += pick_n_take(valid_targets)
		target_sanity++

	if(!silent)
		to_chat(user, span_danger("Your targets have been determined. Your Living Heart will allow you to track their position. Go and sacrifice them!"))

	for(var/datum/mind/chosen_mind as anything in final_targets)
		heretic_datum.add_sacrifice_target(chosen_mind.current)
		if(!silent)
			to_chat(user, span_danger("[chosen_mind.current.real_name], the [chosen_mind.assigned_role?.title]."))

	return TRUE

/**
 * Begin the process of sacrificing the target.
 *
 * Arguments
 * * user - the mob doing the sacrifice (a heretic)
 * * selected_atoms - a list of all atoms chosen. Should be (at least) one human.
 * * loc - the turf the sacrifice is occuring on
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/sacrifice_process(mob/living/user, list/selected_atoms, turf/loc)

	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	var/mob/living/carbon/human/sacrifice = locate() in selected_atoms
	if(!sacrifice)
		CRASH("[type] sacrifice_process didn't have a human in the atoms list. How'd it make it so far?")
	if(!(sacrifice in heretic_datum.sac_targets) && !IS_CULTIST(sacrifice))
		CRASH("[type] sacrifice_process managed to get a non-target, non-cult human. This is incorrect.")

	if(sacrifice.mind)
		LAZYADD(target_blacklist, sacrifice.mind)
	heretic_datum.remove_sacrifice_target(sacrifice)


	var/feedback = "Your patrons accept your offer"
	var/sac_job_flag = sacrifice.mind?.assigned_role?.job_flags | sacrifice.last_mind?.assigned_role?.job_flags
	var/datum/antagonist/cult/cultist_datum = IS_CULTIST(sacrifice)
	// Heads give 3 points, cultists give 1 point (and a special reward), normal sacrifices give 2 points.
	heretic_datum.total_sacrifices++
	if((sac_job_flag & JOB_HEAD_OF_STAFF))
		heretic_datum.knowledge_points += 3
		heretic_datum.high_value_sacrifices++
		feedback += " <i>graciously</i>"
	else if(cultist_datum)
		heretic_datum.knowledge_points += 1
		grant_reward(user, sacrifice, loc)
		// easier to read
		var/rewards_given = heretic_datum.rewards_given
		// Chance for it to send a warning to cultists, higher with each reward. Stops after 5 because they probably got the hint by then.
		if(prob(min(15 * rewards_given)) && (rewards_given <= 5))
			for(var/datum/mind/mind as anything in cultist_datum.cult_team.members)
				if(mind.current)
					SEND_SOUND(mind.current, 'sound/magic/clockwork/narsie_attack.ogg')
					var/message = span_narsie("A vile heretic has ") + \
					span_cult_large(span_hypnophrase("sacrificed")) + \
					span_narsie(" one of our own. Destroy and sacrifice the infidel before it claims more!")
					to_chat(mind.current, message)
			// he(retic) gets a warn too
			var/message = span_cult_bold("You feel that your action has attracted") + \
			span_cult_bold_italic(" attention.")
			to_chat(user, message)
		return
	else
		heretic_datum.knowledge_points += 2

	to_chat(user, span_hypnophrase("[feedback]."))
	if(!begin_sacrifice(sacrifice))
		disembowel_target(sacrifice)
		return

	sacrifice.apply_status_effect(/datum/status_effect/heretic_curse, user)


/datum/heretic_knowledge/hunt_and_sacrifice/proc/grant_reward(mob/living/user, mob/living/sacrifice, turf/loc)

	// Visible and audible encouragement!
	to_chat(user, span_big(span_hypnophrase("A servant of the Sanguine Apostate!")))
	to_chat(user, span_hierophant("Your patrons are rapturous!"))
	playsound(sacrifice, 'sound/magic/disintegrate.ogg', 75, TRUE)

	// Drop all items and splatter them around messily.
	var/list/dustee_items = sacrifice.unequip_everything()
	for(var/obj/item/loot as anything in dustee_items)
		loot.throw_at(get_step_rand(sacrifice), 2, 4, user, TRUE)

	// The loser is DUSTED.
	sacrifice.dust(TRUE, TRUE)

	// Increase reward counter
	var/datum/antagonist/heretic/antag = IS_HERETIC(user)
	antag.rewards_given++

	// We limit the amount so the heretic doesn't just turn into a frickin' god (early)
	to_chat(user, span_hierophant("You feel the rotten energies of the infidel warp and twist, mixing with that of your own..."))
	if(prob(8 * antag.rewards_given))
		to_chat(user, span_hierophant("Faint, dark red sparks flit around the dust, then fade. It looks like your patrons weren't able to fashion something out of it."))
		return

	// Cool effect for the rune as well as the item
	var/obj/effect/heretic_rune/rune = locate() in range(2, user)
	if(rune)
		rune.gender_reveal(
			outline_color = COLOR_CULT_RED,
			ray_color = null,
			do_float = FALSE,
			do_layer = FALSE,
		)

	addtimer(CALLBACK(src, PROC_REF(deposit_reward), user, loc, null, rune), 5 SECONDS)


/datum/heretic_knowledge/hunt_and_sacrifice/proc/deposit_reward(mob/user, turf/loc, loop = 0, obj/rune)
	if(loop > 5) // Max limit for retrying a reward
		return
	// Remove the rays, we don't need them anymore.
	rune?.remove_filter("reward_outline")
	playsound(loc, 'sound/magic/repulse.ogg', 75, TRUE)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	ASSERT(heretic_datum)
	// This list will be almost identical to unlocked_heretic_items, with the same keys, the difference being the values will be 1 to 5.
	var/list/rewards = heretic_datum.unlocked_heretic_items.Copy()
	// We will make it increasingly less likely to get a reward if you've already got it
	for(var/possible_reward in heretic_datum.unlocked_heretic_items)
		var/amount_already_awarded = heretic_datum.unlocked_heretic_items[possible_reward]
		rewards[possible_reward] = min(5 - (amount_already_awarded * 2), 1)

	var/atom/reward = pick_weight(rewards)
	reward = new reward(loc)

	if(isliving(reward))
		if(summon_ritual_mob(user, loc, reward) == FALSE)
			qdel(reward)
			deposit_reward(user, loc, loop++, rune) // If no ghosts, try again until limit is hit
		return

	else if(isitem(reward))
		var/obj/item/item_reward = reward
		item_reward.gender_reveal(outline_color = null, ray_color = COLOR_CULT_RED)

	ASSERT(reward)

	return reward

/**
 * This proc is called from [proc/sacrifice_process] after the heretic successfully sacrifices [sac_target].)
 *
 * Sets off a chain that sends the person sacrificed to the shadow realm to dodge hands to fight for survival.
 *
 * Arguments
 * * sac_target - the mob being sacrificed.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/begin_sacrifice(mob/living/carbon/human/sac_target)
	. = FALSE

	var/datum/antagonist/heretic/our_heretic = heretic_mind?.has_antag_datum(/datum/antagonist/heretic)
	if(!our_heretic)
		CRASH("[type] - begin_sacrifice was called, and no heretic [heretic_mind ? "antag datum":"mind"] could be found!")

	if(!LAZYLEN(GLOB.heretic_sacrifice_landmarks))
		CRASH("[type] - begin_sacrifice was called, but no heretic sacrifice landmarks were found!")

	var/obj/effect/landmark/heretic/destination_landmark = GLOB.heretic_sacrifice_landmarks[our_heretic.heretic_path] || GLOB.heretic_sacrifice_landmarks[PATH_START]
	if(!destination_landmark)
		CRASH("[type] - begin_sacrifice could not find a destination landmark OR default landmark to send the sacrifice! (Heretic's path: [our_heretic.heretic_path])")

	var/turf/destination = get_turf(destination_landmark)

	sac_target.visible_message(span_danger("[sac_target] begins to shudder violenty as dark tendrils begin to drag them into thin air!"))
	sac_target.set_handcuffed(new /obj/item/restraints/handcuffs/energy/cult(sac_target))
	sac_target.update_handcuffed()

	if(sac_target.legcuffed)
		sac_target.legcuffed.forceMove(sac_target.drop_location())
		sac_target.legcuffed.dropped(sac_target)
		sac_target.legcuffed = null
		sac_target.update_worn_legcuffs()

	sac_target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 85, 150)
	sac_target.do_jitter_animation()
	log_combat(heretic_mind.current, sac_target, "sacrificed")

	addtimer(CALLBACK(sac_target, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation)), SACRIFICE_SLEEP_DURATION * (1/3))
	addtimer(CALLBACK(sac_target, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation)), SACRIFICE_SLEEP_DURATION * (2/3))

	// If our target is dead, try to revive them
	// and if we fail to revive them, don't proceede the chain
	sac_target.adjustOxyLoss(-100, FALSE)
	if(!sac_target.heal_and_revive(50, span_danger("[sac_target]'s heart begins to beat with an unholy force as they return from death!")))
		return

	if(sac_target.AdjustUnconscious(SACRIFICE_SLEEP_DURATION))
		to_chat(sac_target, span_hypnophrase("Your mind feels torn apart as you fall into a shallow slumber..."))
	else
		to_chat(sac_target, span_hypnophrase("Your mind begins to tear apart as you watch dark tendrils envelop you."))

	sac_target.AdjustParalyzed(SACRIFICE_SLEEP_DURATION * 1.2)
	sac_target.AdjustImmobilized(SACRIFICE_SLEEP_DURATION * 1.2)

	addtimer(CALLBACK(src, PROC_REF(after_target_sleeps), sac_target, destination), SACRIFICE_SLEEP_DURATION * 0.5) // Teleport to the minigame

	return TRUE

/**
 * This proc is called from [proc/begin_sacrifice] after the [sac_target] falls asleep), shortly after the sacrifice occurs.
 *
 * Teleports the [sac_target] to the heretic room, asleep.
 * If it fails to teleport, they will be disemboweled and stop the chain.
 *
 * Arguments
 * * sac_target - the mob being sacrificed.
 * * destination - the spot they're being teleported to.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_target_sleeps(mob/living/carbon/human/sac_target, turf/destination)
	if(QDELETED(sac_target))
		return

	// The target disconnected or something, we shouldn't bother sending them along.
	if(!sac_target.client || !sac_target.mind)
		disembowel_target(sac_target)
		return

	curse_organs(sac_target)

	// Send 'em to the destination. If the teleport fails, just disembowel them and stop the chain
	if(!destination || !do_teleport(sac_target, destination, asoundin = 'sound/magic/repulse.ogg', asoundout = 'sound/magic/blind.ogg', no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC, forced = TRUE))
		disembowel_target(sac_target)
		return

	// If our target died during the (short) wait timer,
	// and we fail to revive them (using a lower number than before),
	// just disembowel them and stop the chain
	sac_target.adjustOxyLoss(-100, FALSE)
	if(!sac_target.heal_and_revive(60, span_danger("[sac_target]'s heart begins to beat with an unholy force as they return from death!")))
		disembowel_target(sac_target)
		return

	to_chat(sac_target, span_big(span_hypnophrase("Unnatural forces begin to claw at your every being from beyond the veil.")))

	sac_target.apply_status_effect(/datum/status_effect/unholy_determination, SACRIFICE_REALM_DURATION)
	addtimer(CALLBACK(src, PROC_REF(after_target_wakes), sac_target), SACRIFICE_SLEEP_DURATION * 0.5) // Begin the minigame

	RegisterSignal(sac_target, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_target_escape)) // Cheese condition
	RegisterSignal(sac_target, COMSIG_LIVING_DEATH, PROC_REF(on_target_death)) // Loss condition

/// Apply a sinister curse to some of the target's organs as an incentive to leave us alone
/datum/heretic_knowledge/hunt_and_sacrifice/proc/curse_organs(mob/living/carbon/human/sac_target)
	var/usable_organs = grantable_organs.Copy()
	if (isplasmaman(sac_target))
		usable_organs -= /obj/item/organ/internal/lungs/corrupt // Their lungs are already more cursed than anything I could give them

	var/total_implant = rand(2, 4)
	var/gave_any = FALSE

	for (var/i in 1 to total_implant)
		if (!length(usable_organs))
			break
		var/organ_path = pick_n_take(usable_organs)
		var/obj/item/organ/internal/to_give = new organ_path
		if (!to_give.Insert(sac_target))
			qdel(to_give)
		else
			gave_any = TRUE

	if (!gave_any)
		return

	new /obj/effect/gibspawner/human/bodypartless(get_turf(sac_target))
	sac_target.visible_message(span_boldwarning("Several organs force themselves out of [sac_target]!"))

/**
 * This proc is called from [proc/after_target_sleeps] when the [sac_target] should be waking up.)
 *
 * Begins the survival minigame, featuring the sacrifice targets.
 * Gives them Helgrasp, throwing cursed hands towards them that they must dodge to survive.
 * Also gives them a status effect, Unholy Determination, to help them in this endeavor.
 *
 * Then applies some miscellaneous effects.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_target_wakes(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target))
		return

	// About how long should the helgrasp last? (1 metab a tick = helgrasp_time / 2 ticks (so, 1 minute = 60 seconds = 30 ticks))
	var/helgrasp_time = 1 MINUTES

	sac_target.reagents?.add_reagent(/datum/reagent/inverse/helgrasp/heretic, helgrasp_time / 20)
	sac_target.apply_necropolis_curse(CURSE_BLINDING | CURSE_GRASPING)

	sac_target.add_mood_event("shadow_realm", /datum/mood_event/shadow_realm)

	sac_target.flash_act()
	sac_target.set_eye_blur_if_lower(30 SECONDS)
	sac_target.set_jitter_if_lower(20 SECONDS)
	sac_target.set_dizzy_if_lower(20 SECONDS)
	sac_target.adjust_hallucinations(24 SECONDS)
	sac_target.emote("scream")

	to_chat(sac_target, span_reallybig(span_hypnophrase("The grasp of the Mansus reveal themselves to you!")))
	to_chat(sac_target, span_hypnophrase("You feel invigorated! Fight to survive!"))
	// When it runs out, let them know they're almost home free
	addtimer(CALLBACK(src, PROC_REF(after_helgrasp_ends), sac_target), helgrasp_time)
	// Win condition
	var/win_timer = addtimer(CALLBACK(src, PROC_REF(return_target), sac_target), SACRIFICE_REALM_DURATION, TIMER_STOPPABLE)
	LAZYSET(return_timers, REF(sac_target), win_timer)

/**
 * This proc is called from [proc/after_target_wakes] after the helgrasp runs out in the [sac_target].)
 *
 * It gives them a message letting them know it's getting easier and they're almost free.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_helgrasp_ends(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target) || sac_target.stat == DEAD)
		return

	to_chat(sac_target, span_hypnophrase("The worst is behind you... Not much longer! Hold fast, or expire!"))

/**
 * This proc is called from [proc/begin_sacrifice] if the target survived the shadow realm), or [COMSIG_LIVING_DEATH] if they don't.
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
	if(QDELETED(sac_target))
		return

	var/current_timer = LAZYACCESS(return_timers, REF(sac_target))
	if(current_timer)
		deltimer(current_timer)
	LAZYREMOVE(return_timers, REF(sac_target))

	UnregisterSignal(sac_target, COMSIG_MOVABLE_Z_CHANGED)
	UnregisterSignal(sac_target, COMSIG_LIVING_DEATH)
	sac_target.remove_status_effect(/datum/status_effect/necropolis_curse)
	sac_target.remove_status_effect(/datum/status_effect/unholy_determination)
	sac_target.reagents?.del_reagent(/datum/reagent/inverse/helgrasp/heretic)
	sac_target.clear_mood_event("shadow_realm")
	if(IS_HERETIC(sac_target))
		var/datum/antagonist/heretic/victim_heretic = sac_target.mind?.has_antag_datum(/datum/antagonist/heretic)
		victim_heretic.knowledge_points -= 3

	// Wherever we end up, we sure as hell won't be able to explain
	sac_target.adjust_timed_status_effect(40 SECONDS, /datum/status_effect/speech/slurring/heretic)
	sac_target.adjust_stutter(40 SECONDS)

	// They're already back on the station for some reason, don't bother teleporting
	var/turf/below_target = get_turf(sac_target)
	// is_station_level runtimes when passed z = 0, so I'm being very explicit here about checking for nullspace until fixed
	// otherwise, we really don't want this to runtime error, as it'll get people stuck in hell forever - not ideal!
	if(below_target && below_target.z != 0 && is_station_level(below_target.z))
		return

	// Teleport them to a random safe coordinate on the station z level.
	var/turf/open/floor/safe_turf = get_safe_random_station_turf()
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

	if(heretic_mind?.current)
		var/composed_return_message = ""
		composed_return_message += span_notice("Your victim, [sac_target], was returned to the station - ")
		if(sac_target.stat == DEAD)
			composed_return_message += span_red("dead. ")
		else
			composed_return_message += span_green("alive, but with a shattered mind. ")

		composed_return_message += span_notice("You hear a whisper... ")
		composed_return_message += span_hypnophrase(get_area_name(safe_turf, TRUE))
		to_chat(heretic_mind.current, composed_return_message)

/**
 * If they die in the shadow realm, they lost. Send them back.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/on_target_death(mob/living/carbon/human/sac_target, gibbed)
	SIGNAL_HANDLER

	if(gibbed) // Nothing to return
		return

	return_target(sac_target)

/**
 * If they somehow cheese the shadow realm by teleporting out, they are disemboweled and killed.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/on_target_escape(mob/living/carbon/human/sac_target, old_z, new_z)
	SIGNAL_HANDLER

	to_chat(sac_target, span_boldwarning("Your attempt to escape the Mansus is not taken kindly!"))
	// Ends up calling return_target() via death signal to clean up.
	disembowel_target(sac_target)

/**
 * This proc is called from [proc/return_target] if the [sac_target] survives the shadow realm.)
 *
 * Gives the sacrifice target some after effects upon ariving back to reality.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_return_live_target(mob/living/carbon/human/sac_target)
	to_chat(sac_target, span_hypnophrase("The fight is over, but at great cost. You have been returned to the station in one piece."))
	if(IS_HERETIC(sac_target))
		to_chat(sac_target, span_big(span_hypnophrase("You don't remember anything leading up to the experience, but you feel your connection with the Mansus weakened - Knowledge once known, forgotten...")))
	else
		to_chat(sac_target, span_big(span_hypnophrase("You don't remember anything leading up to the experience - All you can think about are those horrific hands...")))

	// Oh god where are we?
	sac_target.flash_act()
	sac_target.adjust_confusion(60 SECONDS)
	sac_target.set_jitter_if_lower(120 SECONDS)
	sac_target.set_eye_blur_if_lower(100 SECONDS)
	sac_target.set_dizzy_if_lower(1 MINUTES)
	sac_target.AdjustKnockdown(80)
	sac_target.adjustStaminaLoss(120)

	// Glad i'm outta there, though!
	sac_target.add_mood_event("shadow_realm_survived", /datum/mood_event/shadow_realm_live)
	if(IS_HERETIC(sac_target))
		sac_target.add_mood_event("shadow_realm_survived_sadness", /datum/mood_event/shadow_realm_live_sad_heretic)
	else
		sac_target.add_mood_event("shadow_realm_survived_sadness", /datum/mood_event/shadow_realm_live_sad)

	// Could use a little pick-me-up...
	sac_target.reagents?.add_reagent(/datum/reagent/medicine/atropine, 8)
	sac_target.reagents?.add_reagent(/datum/reagent/medicine/epinephrine, 8)

/**
 * This proc is called from [proc/return_target] if the target dies in the shadow realm.)
 *
 * After teleporting the target back to the station (dead),
 * it spawns a special red broken illusion on their spot, for style.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/after_return_dead_target(mob/living/carbon/human/sac_target)
	to_chat(sac_target, span_hypnophrase("You failed to resist the horrors of the Mansus! Your ruined body has been returned to the station."))
	to_chat(sac_target, span_big(span_hypnophrase("The experience leaves your mind torn and memories tattered. You will not remember anything leading up to the experience if revived.")))

	var/obj/effect/visible_heretic_influence/illusion = new(get_turf(sac_target))
	illusion.name = "\improper weakened rift in reality"
	illusion.desc = "A rift wide enough for something... or someone... to come through."
	illusion.color = COLOR_DARK_RED

/**
 * "Fuck you" proc that gets called if the chain is interrupted at some points.
 * Disembowels the [sac_target] and brutilizes their body. Throws some gibs around for good measure.
 */
/datum/heretic_knowledge/hunt_and_sacrifice/proc/disembowel_target(mob/living/carbon/human/sac_target)
	if(heretic_mind)
		log_combat(heretic_mind.current, sac_target, "disemboweled via sacrifice")
	sac_target.spill_organs(DROP_ALL_REMAINS)
	sac_target.apply_damage(250, BRUTE)
	if(sac_target.stat != DEAD)
		sac_target.investigate_log("has been killed by heretic sacrifice.", INVESTIGATE_DEATHS)
		sac_target.death()
	sac_target.visible_message(
		span_danger("[sac_target]'s organs are pulled out of [sac_target.p_their()] chest by shadowy hands!"),
		span_userdanger("Your organs are violently pulled out of your chest by shadowy hands!")
	)

	new /obj/effect/gibspawner/human/bodypartless(get_turf(sac_target))

#undef SACRIFICE_SLEEP_DURATION
#undef SACRIFICE_REALM_DURATION
