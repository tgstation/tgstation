/datum/action/bloodsucker/feed
	name = "Feed"
	desc = "Draw the heartsblood of living victims in your grasp. You will break the Masquerade if seen feeding."
	button_icon_state = "power_feed"
	power_explanation = "<b>Feed</b>:\n\
		Activate Feed while next to someone and you will begin to feed blood off of them.\n\
		If <b>passively</b> grabbed, you will feed faster than default.\n\
		If <b>aggressively</b> grabbed, along with drinking even faster, your victim will additionally be put to sleep.\n\
		You cannot talk while Feeding, as your mouth is full of Blood.\n\
		If you feed off of a Rat, unless you are Malkavian or Nosferatu, you will lose <b>Humanity</b> and get a mood debuff.\n\
		Feeding off of someone until they die will cause you to lose <b>Humanity</b>.\n\
		If you are seen feeding off of someone (2 tiles) while your target is grabbed, you will break the Masquerade.\n\
		Higher levels will increase the feeding's speed."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_WHILE_STAKED|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY
	bloodcost = 0
	cooldown = 3 SECONDS

	///Amount of times we were seen Feeding. If seen 3 times, we broke the Masquerade.
	var/feeds_noticed = 0
	///Distance before silent feeding is noticed.
	var/notice_range = 2
	///Check if we were noticed Feeding.
	var/was_noticed = FALSE
	///So we can validate more than just the guy we're grappling.
	var/mob/living/feed_target
	///If you started grappled, then ending it will end your Feed.
	var/target_grappled = FALSE
	///Am I Silent?
	var/amSilent = FALSE
	///How much Blood did I drink? This is used for logs
	var/amount_taken = 0
	///The initial wait before you start drinking blood.
	var/feed_time
	///Quantity to take per tick, based on Silent/frenzied or not.
	var/blood_take_mult
	/// CHECKS - To prevent spam.
	var/warning_target_inhuman = FALSE
	var/warning_target_dead = FALSE
	var/warning_full = FALSE
	var/warning_target_bloodvol = 99999
	var/was_alive = FALSE

/datum/action/bloodsucker/feed/CheckCanUse(mob/living/carbon/user)
	. = ..()
	if(!.)
		return FALSE

	// Wearing mask
	if(user.is_mouth_covered())
		to_chat(owner, span_warning("Your mouth is covered!"))
		return FALSE
	// Find my Target!
	if(!find_target())
		return FALSE
	// DONE!
	return TRUE

/// Called twice: validating a subtle victim, or validating your grapple victim.
/datum/action/bloodsucker/feed/proc/ValidateTarget(mob/living/target)
	// Must have Target.
	if(!target)//|| !ismob(target)
		to_chat(owner, span_warning("You must be next to or grabbing a victim to feed from them."))
		return FALSE
	// Not even living!
	if(!isliving(target) || issilicon(target))
		to_chat(owner, span_warning("You may only feed from living beings."))
		return FALSE
	// Check for other animals (Supposed to be after Mouse so Mouse can skip over it)
	else if(!iscarbon(target))
		to_chat(owner, span_warning("Such simple beings cannot be fed off of."))
		return FALSE
	// Has no blood to take!
	else if(target.blood_volume <= 0)
		to_chat(owner, span_warning("Your victim has no blood to take."))
		return FALSE
	// Bloodsuckers can be fed off of if they are grabbed more than Passively.
	if(IS_BLOODSUCKER(target) && target == owner.pulling && owner.grab_state <= GRAB_PASSIVE)
		to_chat(owner, span_warning("Other Bloodsuckers will not fall for your subtle approach."))
		return FALSE
	if(ishuman(target))
		var/mob/living/carbon/human/target_user = target
		if(!target_user.can_inject(owner, BODY_ZONE_HEAD, 1) && target == owner.pulling && owner.grab_state < GRAB_AGGRESSIVE)
			to_chat(owner, span_warning("Their suit is too thick to feed through."))
			return FALSE
		if(NOBLOOD in target_user.dna.species.species_traits)// || owner.get_blood_id() != target.get_blood_id())
			to_chat(owner, span_warning("Your victim's blood is not suitable for you to take."))
			return FALSE
	return TRUE

/// If I'm not grabbing someone, find me someone nearby.
/datum/action/bloodsucker/feed/proc/find_target()
	// Default
	feed_target = null
	target_grappled = FALSE
	// If you are pulling a mob, that's your target. If you don't like it, then release them.
	if(owner.pulling && ismob(owner.pulling))
		// Check grapple target Valid
		if(!ValidateTarget(owner.pulling)) // Grabbed targets display error.
			return FALSE
		target_grappled = TRUE
		feed_target = owner.pulling
		return TRUE
	// Find Targets
	var/list/mob/living/seen_mobs = list()
	for(var/mob/living/watchers in view(1, owner) - owner)
		if(!isliving(watchers))
			continue
		seen_mobs |= watchers
	// None Seen!
	if(!seen_mobs.len)
		to_chat(owner, span_warning("You must be next to or grabbing a victim to feed from them."))
		return FALSE
	// Check Valids...
	var/list/targets_valid = list()
	var/list/targets_dead = list()
	for(var/mob/living/watchers in seen_mobs)
		// Check adjecent Valid target
		if(watchers != owner && ValidateTarget(watchers)) // Do NOT display errors. We'll be doing this again in CheckCanUse(), which will rule out grabbed targets.
			// Prioritize living, but remember dead as backup
			if(watchers.stat < DEAD)
				targets_valid |= watchers
			else
				targets_dead |= watchers
	// No Living? Try dead.
	if(!targets_valid.len && targets_dead.len)
		targets_valid = targets_dead
	// No Targets
	if(!targets_valid.len)
		// Did I see targets? Then display at least one error
		if(seen_mobs.len > 1)
			to_chat(owner, span_warning("None of these are valid targets to feed from subtly."))
		else
			ValidateTarget(seen_mobs[1])
		return FALSE
	else
		feed_target = pick(targets_valid)
		return TRUE

/datum/action/bloodsucker/feed/ActivatePower()
	. = ..()
	var/mob/living/user = owner
	// Checks: Step 1 - Am I SECRET or LOUD?
	if(!bloodsuckerdatum_power.frenzied && (!target_grappled || owner.grab_state <= GRAB_PASSIVE)) // && iscarbon(target) // Non-carbons (animals) not passive. They go straight into aggressive.
		amSilent = TRUE

	// Checks: Step 2 - Is it a Mouse?
	if(istype(feed_target, /mob/living/simple_animal/mouse))
		var/mob/living/simple_animal/mouse_target = feed_target
		bloodsuckerdatum_power.AddBloodVolume(25)
		to_chat(user, span_notice("You recoil at the taste of a lesser lifeform."))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_bad)
		bloodsuckerdatum_power.AddHumanityLost(1)
		DeactivatePower()
		mouse_target.adjustBruteLoss(20)
		return
	// Checks: Step 3 - How fast should I be and how much should I drink?
	var/feed_time_multiplier
	if(bloodsuckerdatum_power.frenzied)
		blood_take_mult = 2
		feed_time_multiplier = 8
	else if(!amSilent)
		blood_take_mult = 1
		feed_time_multiplier = 25 - (2.5 * level_current)
	else
		blood_take_mult = 0.3
		feed_time_multiplier = 45 - (2.5 * level_current)
	feed_time = max(8, feed_time_multiplier)
	// Let's check if our target is alive
	was_alive = feed_target.stat < DEAD && ishuman(feed_target)

	// Send pre-pull message
	if(amSilent)
		to_chat(owner, span_notice("You quietly lean towards [feed_target]"))
	else
		to_chat(owner, span_notice("You pull [feed_target] close to you!"))

	// Start the countdown
	if(!do_mob(user, feed_target, feed_time, NONE, TRUE))
		DeactivatePower()
		to_chat(owner, span_danger("Your feeding was interrupted!"))
		return

	// Give them the effects (Depending on if we are silent or not)
	if(!amSilent)
		// Sleep & paralysis.
		ApplyVictimEffects(feed_target, first_hit = TRUE)
		// Pull target to you if they don't take up space.
		if(!feed_target.density)
			feed_target.Move(user.loc)
		user.visible_message(
			span_warning("[user] closes [user.p_their()] mouth around [feed_target]'s neck!"),
			span_warning("You sink your fangs into [feed_target]'s neck."),
		)
	if(amSilent)
		var/deadmessage = feed_target.stat == DEAD ? "" : " <i>[feed_target.p_they(TRUE)] looks dazed, and will not remember this.</i>"
		user.visible_message(
			span_notice("[user] puts [feed_target]'s wrist up to [user.p_their()] mouth."), \
			span_notice("You slip your fangs into [feed_target]'s wrist.[deadmessage]"), \
			vision_distance = notice_range, ignored_mobs = feed_target) // Only people who AREN'T the target will notice this action.

	// Check if we have anyone watching - If there is one, we broke the Masquerade.
	for(var/mob/living/watchers in viewers(notice_range, owner) - owner - feed_target)
		// Are they someone who will actually report our behavior?
		if(watchers.client \
				&& !watchers.has_unlimited_silicon_privilege \
				&& watchers.stat != DEAD \
				&& watchers.eye_blind == 0 \
				&& watchers.eye_blurry == 0 \
				&& !IS_BLOODSUCKER(watchers) \
				&& !IS_VASSAL(watchers) \
				&& !HAS_TRAIT(watchers, TRAIT_BLOODSUCKER_HUNTER))
			was_noticed = TRUE
			break
	if(was_noticed && !target_grappled)
		feeds_noticed++
		to_chat(owner, span_danger("Someone may have noticed..."))
		if(!bloodsuckerdatum_power.broke_masquerade)
			to_chat(user, span_cultbold("You broke the Masquerade [feeds_noticed] time(s), if you break it 3 times, you become a criminal to the Bloodsucker's Cause!"))
	else
		to_chat(owner, span_notice("You think no one saw you..."))

	// FEEEEEEEEED!! //
	ADD_TRAIT(user, TRAIT_MUTE, BLOODSUCKER_TRAIT) // My mouth is full!
	user.Immobilize(10 SECONDS) // Prevents spilling blood accidentally.

/datum/action/bloodsucker/feed/UsePower(mob/living/user)
	if(!ContinueActive(user, feed_target))
		if(amSilent)
			to_chat(user, span_warning("Your feeding has been interrupted... but [feed_target.p_they()] didn't seem to notice you."))
			DeactivatePower()
		else
			to_chat(user, span_warning("Your feeding has been interrupted!"))
			user.visible_message(
				span_warning("[user] is ripped from [feed_target]'s throat. [feed_target.p_their(TRUE)] blood sprays everywhere!"),
				span_warning("Your teeth are ripped from [feed_target]'s throat. [feed_target.p_their(TRUE)] blood sprays everywhere!"))
			// Deal Damage to Target (should have been more careful!)
			if(iscarbon(feed_target))
				var/mob/living/carbon/carbon_target = feed_target
				carbon_target.bleed(15)
			playsound(get_turf(feed_target), 'sound/effects/splat.ogg', 40, 1)
			if(ishuman(feed_target))
				var/mob/living/carbon/human/target_user = feed_target
				var/obj/item/bodypart/head_part = target_user.get_bodypart(BODY_ZONE_HEAD)
				if(head_part)
					head_part.generic_bleedstacks += 5
			feed_target.add_splatter_floor(get_turf(feed_target))
			user.add_mob_blood(feed_target) // Put target's blood on us. The donor goes in the ( )
			feed_target.add_mob_blood(feed_target)
			feed_target.apply_damage(10, BRUTE, BODY_ZONE_HEAD, wound_bonus = CANT_WOUND)
			INVOKE_ASYNC(feed_target, /mob.proc/emote, "scream")
			DeactivatePower()
		return

	///////////////////////////////////////////////////////////
	// 		Handle Feeding! User & Victim Effects (per tick)
	bloodsuckerdatum_power.HandleFeeding(feed_target, blood_take_mult, level_current)
	amount_taken += amSilent ? 0.3 : 1
	if(!amSilent)
		ApplyVictimEffects(feed_target)

	///////////////////////////////////////////////////////////
	// MOOD EFFECTS //
	// Drank good blood? - GOOD
	if(amount_taken > 5 && feed_target.stat < DEAD && ishuman(feed_target))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood)
	// Dead Blood? - BAD
	if(feed_target.stat >= DEAD)
		if(ishuman(feed_target))
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_dead)
		if(!warning_target_dead)
			to_chat(user, span_notice("Your victim is dead. [feed_target.p_their(TRUE)] blood barely nourishes you."))
			warning_target_dead = TRUE

	// Blood Remaining? (Carbons/Humans only)
	else if(!IS_BLOODSUCKER(feed_target))
		if(feed_target.blood_volume <= BLOOD_VOLUME_BAD && warning_target_bloodvol > BLOOD_VOLUME_BAD)
			to_chat(owner, span_danger("Your victim's blood is fatally low!"))
		else if(feed_target.blood_volume <= BLOOD_VOLUME_OKAY && warning_target_bloodvol > BLOOD_VOLUME_OKAY)
			to_chat(owner, span_danger("Your victim's blood is dangerously low."))
		else if(feed_target.blood_volume <= BLOOD_VOLUME_SAFE && warning_target_bloodvol > BLOOD_VOLUME_SAFE)
			to_chat(owner, span_danger("Your victim's blood is at an unsafe level."))
		warning_target_bloodvol = feed_target.blood_volume // If we had a warning to give, it's been given by now.
	// Full?
	if(user.blood_volume >= bloodsuckerdatum_power.max_blood_volume && !warning_full)
		to_chat(owner, span_notice("You are full, further blood will be wasted."))
		warning_full = TRUE
	// Done?
	if(feed_target.blood_volume <= 0)
		DeactivatePower()
		to_chat(owner, span_notice("You have bled your victim dry..."))
		return

	// Blood Gulp Sound
	owner.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
	if(!amSilent)
		feed_target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)

/// Check if we killed our target
/datum/action/bloodsucker/feed/proc/CheckKilledTarget(mob/living/target)
	if(target && target.stat >= DEAD && ishuman(target))
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "drankkilled", /datum/mood_event/drankkilled)
		bloodsuckerdatum_power.AddHumanityLost(10)

/// NOTE: We only care about pulling if target started off that way. Mostly only important for Aggressive feed.
/datum/action/bloodsucker/feed/ContinueActive(mob/living/user, mob/living/target)
	if(!target)
		return FALSE
	if(!user.Adjacent(target))
		return FALSE
	if(target_grappled && !user.pulling)
		return FALSE
	return TRUE

/// Bloodsuckers not affected by "the Kiss" of another vampire
/datum/action/bloodsucker/feed/proc/ApplyVictimEffects(mob/living/target, first_hit = FALSE)
	if(IS_BLOODSUCKER(target) || IS_VASSAL(target))
		return
	if(first_hit)
		target.Unconscious(5 SECONDS,0)
	target.Paralyze(40 + 5 * level_current)

/datum/action/bloodsucker/feed/DeactivatePower()
	. = ..() // activate = FALSE

	if(feed_target) // Check: Otherwise it runtimes if you fail to feed on someone.
		if(amSilent)
			to_chat(owner, span_notice("You slowly release [feed_target]'s wrist." + (feed_target.stat == 0 ? " [feed_target.p_their(TRUE)] face lacks expression, like you've already been forgotten." : "")))
		else
			owner.visible_message(
				span_warning("[owner] unclenches their teeth from [feed_target]'s neck."),
				span_warning("You retract your fangs and release [feed_target] from your bite."))
		log_combat(owner, feed_target, "fed on blood", addition="(and took [amount_taken] blood)")
	// Did we kill our target?
	if(was_alive)
		CheckKilledTarget(feed_target)
	// Only break it once we've broken it 3 times, not more.
	if(feeds_noticed == 3)
		bloodsuckerdatum_power.break_masquerade()
	// Reset ALL checks for next time the Power is used.
	amSilent = FALSE
	was_noticed = FALSE
	warning_target_inhuman = FALSE
	warning_target_dead = FALSE
	warning_full = FALSE
	feed_target = null
	warning_target_bloodvol = 99999
	// My mouth is no longer full
	var/mob/living/O = owner
	O.SetImmobilized(0)
	REMOVE_TRAIT(owner, TRAIT_MUTE, BLOODSUCKER_TRAIT) 
