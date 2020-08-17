

/datum/action/bloodsucker/feed
	name = "Feed"
	desc = "Draw the heartsblood of living victims in your grasp.<br><b>None/Passive:</b> Feed silently and unnoticed by your victim.<br><b>Aggressive: </b>Subdue your target quickly."
	button_icon_state = "power_feed"

	bloodcost = 0
	cooldown = 30
	amToggle = TRUE
	bloodsucker_can_buy = TRUE
	can_be_staked = TRUE
	cooldown_static = TRUE

	var/notice_range = 2 		// Distance before silent feeding is noticed.
	var/mob/living/feed_target 	// So we can validate more than just the guy we're grappling.
	var/target_grappled = FALSE // If you started grappled, then ending it will end your Feed.

/datum/action/bloodsucker/feed/CheckCanUse(display_error)
	if(!..(display_error))// DEFAULT CHECKS
		return FALSE

	// Wearing mask
	var/mob/living/L = owner
	if (L.is_mouth_covered())
		if (display_error)
			to_chat(owner, "<span class='warning'>You cannot feed with your mouth covered! Remove your mask.</span>")
		return FALSE

	// Find my Target!
	if (!FindMyTarget(display_error)) // Sets feed_target within after Validating
		return FALSE

	// Not in correct state
	//if (owner.grab_state < GRAB_PASSIVE)//GRAB_AGGRESSIVEs)
	//	to_chat(owner, "<span class='warning'>You aren't grabbing anyone!</span>")
	//	return FALSE

	// DONE!
	return TRUE

/datum/action/bloodsucker/feed/proc/ValidateTarget(mob/living/target, display_error) // Called twice: validating a subtle victim, or validating your grapple victim.
	// Bloodsuckers + Animals MUST be grabbed aggressively!
	if (!owner.pulling || target == owner.pulling && owner.grab_state < GRAB_AGGRESSIVE)
		// NOTE: It's OKAY that we are checking if(!target) below, AFTER animals here. We want passive check vs animal to warn you first, THEN the standard warning.
		// Animals:
		if (isliving(target) && !iscarbon(target))
			if (display_error)
				to_chat(owner, "<span class='warning'>Lesser beings require a tighter grip.</span>")
			return FALSE
		// Bloodsuckers:
		else if (iscarbon(target) && target.mind && target.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
			if (display_error)
				to_chat(owner, "<span class='warning'>Other Bloodsuckers will not fall for your subtle approach.</span>")
			return FALSE
	// Must have Target
	if (!target)	 //  || !ismob(target)
		if (display_error)
			to_chat(owner, "<span class='warning'>You must be next to or grabbing a victim to feed from them.</span>")
		return FALSE
	// Not even living!
	if (!isliving(target) || issilicon(target))
		if (display_error)
			to_chat(owner, "<span class='warning'>You may only feed from living beings.</span>")
		return FALSE
	if (target.blood_volume <= 0)
		if (display_error)
			to_chat(owner, "<span class='warning'>Your victim has no blood to take.</span>")
		return FALSE
	if (ishuman(target))
		var/mob/living/carbon/human/H = target
		if(NOBLOOD in H.dna.species.species_traits)// || owner.get_blood_id() != target.get_blood_id())
			if (display_error)
				to_chat(owner, "<span class='warning'>Your victim's blood is not suitable for you to take.</span>")
			return FALSE
	return TRUE

// If I'm not grabbing someone, find me someone nearby.
/datum/action/bloodsucker/feed/proc/FindMyTarget(display_error)
	// Default
	feed_target = null
	target_grappled = FALSE

	// If you are pulling a mob, that's your target. If you don't like it, then release them.
	if (owner.pulling && ismob(owner.pulling))
		// Check grapple target Valid
		if (!ValidateTarget(owner.pulling, display_error)) // Grabbed targets display error.
			return FALSE
		target_grappled = TRUE
		feed_target = owner.pulling
		return TRUE

	// Find Targets
	var/list/mob/living/seen_targets = view(1, owner)
	var/list/mob/living/seen_mobs = list()
	for(var/mob/living/M in seen_targets)
		if (isliving(M) && M != owner)
			seen_mobs += M

	// None Seen!
	if (seen_mobs.len == 0)
		if (display_error)
			to_chat(owner, "<span class='warning'>You must be next to or grabbing a victim to feed from them.</span>")
		return FALSE

	// Check Valids...
	var/list/targets_valid = list()
	var/list/targets_dead = list()
	for(var/mob/living/M in seen_mobs)
		// Check adjecent Valid target
		if (M != owner && ValidateTarget(M, display_error = FALSE)) // Do NOT display errors. We'll be doing this again in CheckCanUse(), which will rule out grabbed targets.
			// Prioritize living, but remember dead as backup
			if (M.stat < DEAD)
				targets_valid += M
			else
				targets_dead += M

	// No Living? Try dead.
	if (targets_valid.len == 0 && targets_dead.len > 0)
		targets_valid = targets_dead
	// No Targets
	if (targets_valid.len == 0)
		// Did I see targets? Then display at least one error
		if (seen_mobs.len > 1)
			if (display_error)
				to_chat(owner, "<span class='warning'>None of these are valid targets to feed from subtly.</span>")
		else
			ValidateTarget(seen_mobs[1], display_error)
		return FALSE
	// Too Many Targets
	//else if (targets.len > 1)
	//	if (display_error)
	//		to_chat(owner, "<span class='warning'>You are adjecent to too many witnesses. Either grab your victim or move away.</span>")
	//	return FALSE
	// One Target!
	else
		feed_target = pick(targets_valid)//targets[1]
		return TRUE


/datum/action/bloodsucker/feed/ActivatePower()
	// set waitfor = FALSE   <---- DONT DO THIS!We WANT this power to hold up Activate(), so Deactivate() can happen after.

	var/mob/living/target = feed_target // Stored during CheckCanUse(). Can be a grabbed OR adjecent character.
	var/mob/living/user = owner
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)

	// Am I SECRET or LOUD? It stays this way the whole time! I must END IT to try it the other way.
	var/amSilent = (!target_grappled || owner.grab_state <= GRAB_PASSIVE) //  && iscarbon(target) // Non-carbons (animals) not passive. They go straight into aggressive.

	// Initial Wait
	var/feed_time = (amSilent ? 45 : 25) - (2.5 * level_current)
	feed_time = max(15, feed_time)
	if (amSilent)
		to_chat(user, "<span class='notice'>You lean quietly toward [target] and secretly draw out your fangs...</span>")
	else
		to_chat(user, "<span class='warning'>You pull [target] close to you and draw out your fangs...</span>")
	if (!do_mob(user, target, feed_time,0,1,extra_checks=CALLBACK(src, .proc/ContinueActive, user, target)))//sleep(10)
		to_chat(user, "<span class='warning'>Your feeding was interrupted.</span>")
		//DeactivatePower(user,target)
		return

	// Put target to Sleep (Bloodsuckers are immune to their own bite's sleep effect)
	if (!amSilent)
		ApplyVictimEffects(target)	// Sleep, paralysis, immobile, unconscious, and mute
		if(target.stat <= UNCONSCIOUS)
			sleep(1)
			// Wait, then Cancel if Invalid
			if (!ContinueActive(user,target)) // Cancel. They're gone.
				//DeactivatePower(user,target)
				return
		// Pull Target Close
		if (!target.density) // Pull target to you if they don't take up space.
			target.Move(user.loc)

	// Broadcast Message
	if (amSilent)
		//if (!iscarbon(target))
		//	user.visible_message("<span class='notice'>[user] shifts [target] closer to [user.p_their()] mouth.</span>", \
		//					 	 "<span class='notice'>You secretly slip your fangs into [target]'s flesh.</span>", \
		//					 	 vision_distance = 2, ignored_mobs=target) // Only people who AREN'T the target will notice this action.
		//else
		var/deadmessage = target.stat == DEAD ? "" : " <i>[target.p_they(TRUE)] looks dazed, and will not remember this.</i>"
		user.visible_message("<span class='notice'>[user] puts [target]'s wrist up to [user.p_their()] mouth.</span>", \
						 	 "<span class='notice'>You secretly slip your fangs into [target]'s wrist.[deadmessage]</span>", \
						 	 vision_distance = notice_range, ignored_mobs=target) // Only people who AREN'T the target will notice this action.
		// Warn Feeder about Witnesses...
		var/was_unnoticed = TRUE
		for(var/mob/living/M in viewers(notice_range, owner))
			if(M != owner && M != target && iscarbon(M) && M.mind && !M.has_unlimited_silicon_privilege && !M.eye_blind && !M.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
				was_unnoticed = FALSE
				break
		if (was_unnoticed)
			to_chat(user, "<span class='notice'>You think no one saw you...</span>")
		else
			to_chat(user, "<span class='warning'>Someone may have noticed...</span>")

	else						 // /atom/proc/visible_message(message, self_message, blind_message, vision_distance, ignored_mobs)
		user.visible_message("<span class='warning'>[user] closes [user.p_their()] mouth around [target]'s neck!</span>", \
						 "<span class='warning'>You sink your fangs into [target]'s neck.</span>")

	// My mouth is full!
	ADD_TRAIT(user, TRAIT_MUTE, "bloodsucker_feed")

	// Begin Feed Loop
	var/warning_target_inhuman = FALSE
	var/warning_target_dead = FALSE
	var/warning_full = FALSE
	var/warning_target_bloodvol = 99999
	var/amount_taken = 0
	var/blood_take_mult = amSilent ? 0.3 : 1 // Quantity to take per tick, based on Silent or not.
	var/was_alive = target.stat < DEAD && ishuman(target)
	// Activate Effects
	//target.add_trait(TRAIT_MUTE, "bloodsucker_victim")  // <----- Make mute a power you buy?

	// FEEEEEEEEED!!! //
	bloodsuckerdatum.poweron_feed = TRUE
	while (bloodsuckerdatum && target && active)
		user.mobility_flags &= ~MOBILITY_MOVE // user.canmove = 0 // Prevents spilling blood accidentally.

		// Abort? A bloody mistake.
		if (!do_mob(user, target, 20, 0, 0, extra_checks=CALLBACK(src, .proc/ContinueActive, user, target)))
			// May have disabled Feed during do_mob
			if (!active || !ContinueActive(user, target))
				break

			if (amSilent)
				to_chat(user, "<span class='warning'>Your feeding has been interrupted...but [target.p_they()] didn't seem to notice you.<span>")
			else
				to_chat(user, "<span class='warning'>Your feeding has been interrupted!</span>")
				user.visible_message("<span class='danger'>[user] is ripped from [target]'s throat. [target.p_their(TRUE)] blood sprays everywhere!</span>", \
						 			 "<span class='userdanger'>Your teeth are ripped from [target]'s throat. [target.p_their(TRUE)] blood sprays everywhere!</span>")

				// Deal Damage to Target (should have been more careful!)
				if (iscarbon(target))
					var/mob/living/carbon/C = target
					C.bleed(15)
				playsound(get_turf(target), 'sound/effects/splat.ogg', 40, 1)
				//if (ishuman(target))
					//var/mob/living/carbon/human/H = target
					//H.bleed_rate += 5  DEAD CODE MUST REWORK TO FIT WOUNDS PR SOMEHOW
				target.add_splatter_floor(get_turf(target))
				user.add_mob_blood(target) // Put target's blood on us. The donor goes in the ( )
				target.add_mob_blood(target)
				target.take_overall_damage(10,0)
				target.emote("scream")

			// Killed Target?
			if (was_alive)
				CheckKilledTarget(user,target)

			return

		///////////////////////////////////////////////////////////
		// 		Handle Feeding! User & Victim Effects (per tick)
		bloodsuckerdatum.HandleFeeding(target, blood_take_mult)
		amount_taken += amSilent ? 0.3 : 1
		if (!amSilent)
			ApplyVictimEffects(target)	// Sleep, paralysis, immobile, unconscious, and mute
		if (amount_taken > 5 && target.stat < DEAD && ishuman(target))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood) // GOOD // in bloodsucker_life.dm

		///////////////////////////////////////////////////////////
		// Not Human?
		if (!ishuman(target))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_bad) // BAD // in bloodsucker_life.dm
			if (!warning_target_inhuman)
				to_chat(user, "<span class='notice'>You recoil at the taste of a lesser lifeform.</span>")
				warning_target_inhuman = TRUE
		// Dead Blood?
		if (target.stat >= DEAD)
			if (ishuman(target))
				SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_dead) // BAD // in bloodsucker_life.dm
			if (!warning_target_dead)
				to_chat(user, "<span class='notice'>Your victim is dead. [target.p_their(TRUE)] blood barely nourishes you.</span>")
				warning_target_dead = TRUE
		// Full?
		if (!warning_full && user.blood_volume >= bloodsuckerdatum.maxBloodVolume)
			to_chat(user, "<span class='notice'>You are full. Further blood will be wasted.</span>")
			warning_full = TRUE
		// Blood Remaining? (Carbons/Humans only)
		if (iscarbon(target) && !target.AmBloodsucker(1))
			if (target.blood_volume <= BLOOD_VOLUME_BAD && warning_target_bloodvol > BLOOD_VOLUME_BAD)
				to_chat(user, "<span class='warning'>Your victim's blood volume is fatally low!</span>")
			else if (target.blood_volume <= BLOOD_VOLUME_OKAY && warning_target_bloodvol > BLOOD_VOLUME_OKAY)
				to_chat(user, "<span class='warning'>Your victim's blood volume is dangerously low.</span>")
			else if (target.blood_volume <= BLOOD_VOLUME_SAFE && warning_target_bloodvol > BLOOD_VOLUME_SAFE)
				to_chat(user, "<span class='notice'>Your victim's blood is at an unsafe level.</span>")
			warning_target_bloodvol = target.blood_volume // If we had a warning to give, it's been given by now.
		// Done?
		if (target.blood_volume <= 0)
			to_chat(user, "<span class='notice'>You have bled your victim dry.</span>")
			break

		// Blood Gulp Sound
		owner.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.

	// DONE!
	//DeactivatePower(user,target)
	if (amSilent)
		to_chat(user, "<span class='notice'>You slowly release [target]'s wrist." + (target.stat == 0 ? " [target.p_their(TRUE)] face lacks expression, like you've already been forgotten.</span>" : ""))
	else
		user.visible_message("<span class='warning'>[user] unclenches their teeth from [target]'s neck.</span>", \
							 "<span class='warning'>You retract your fangs and release [target] from your bite.</span>")

	// /proc/log_combat(atom/user, atom/target, what_done, atom/object=null, addition=null)
	log_combat(owner, target, "fed on blood", addition="(and took [amount_taken] blood)")

	// Killed Target?
	if (was_alive)
		CheckKilledTarget(user,target)


/datum/action/bloodsucker/feed/proc/CheckKilledTarget(mob/living/user, mob/living/target)
	// Bad Vampire. You shouldn't do that.
	if (target && target.stat >= DEAD && ishuman(target))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankkilled", /datum/mood_event/drankkilled) // BAD // in bloodsucker_life.dm

/datum/action/bloodsucker/feed/ContinueActive(mob/living/user, mob/living/target)
	return ..()  && target && (!target_grappled || user.pulling == target)// Active, and still Antag,
	// NOTE: We only care about pulling if target started off that way. Mostly only important for Aggressive feed.

/datum/action/bloodsucker/feed/proc/ApplyVictimEffects(mob/living/target)
	// Bloodsuckers not affected by "the Kiss" of another vampire
	if (!target.mind || !target.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER))
		target.Unconscious(50,0)
		target.Paralyze(40 + 5 * level_current,1)
		// NOTE: THis is based on level of power!
		if (ishuman(target))
			target.adjustStaminaLoss(5, forced = TRUE)// Base Stamina Damage

/datum/action/bloodsucker/feed/DeactivatePower(mob/living/user = owner, mob/living/target)
	..() // activate = FALSE
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(ANTAG_DATUM_BLOODSUCKER)
	// No longer Feeding
	if (bloodsuckerdatum)
		bloodsuckerdatum.poweron_feed = FALSE
	feed_target = null
	// My mouth is no longer full
	REMOVE_TRAIT(owner, TRAIT_MUTE, "bloodsucker_feed")
	// Let me move immediately
	user.update_mobility()

