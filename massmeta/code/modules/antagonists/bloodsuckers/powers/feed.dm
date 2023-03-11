#define FEED_NOTICE_RANGE 2
#define FEED_DEFAULT_TIMER (10 SECONDS)

/datum/action/bloodsucker/feed
	name = "Feed"
	desc = "Feed blood off of a living creature."
	button_icon_state = "power_feed"
	power_explanation = "Feed:\n\
		Feed can't be used until you reach your first Bloodsucker level.\n\
		Activate Feed while next to someone and you will begin to feed blood off of them.\n\
		The time needed before you start feeding speeds up the higher level you are.\n\
		Feeding off of someone while you have them aggressively grabbed will put them to sleep.\n\
		While feeding, you can't speak, as your mouth is covered.\n\
		Feeding while nearby (2 tiles away from) a mortal who is unaware of Bloodsuckers' existence, will cause a Masquerade Infraction\n\
		If you get too many Masquerade Infractions, you will break the Masquerade.\n\
		If you are in desperate need of blood, mice can be fed off of, at a cost."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_WHILE_STAKED|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|BLOODSUCKER_DEFAULT_POWER
	bloodcost = 0
	cooldown = 15 SECONDS
	///Amount of blood taken, reset after each Feed. Used for logging.
	var/blood_taken = 0
	///The amount of Blood a target has since our last feed, this loops and lets us not spam alerts of low blood.
	var/warning_target_bloodvol = BLOOD_VOLUME_MAX_LETHAL
	///Reference to the target we've fed off of
	var/datum/weakref/target_ref

/datum/action/bloodsucker/feed/CheckCanUse(mob/living/carbon/user, trigger_flags)
	. = ..()
	if(!.)
		return FALSE
	if(target_ref) //already sucking blood.
		return FALSE
	if(!level_current)
		owner.balloon_alert(owner, "too weak!")
		to_chat(owner, span_warning("You can't use [src] until you level up."))
		return FALSE
	if(user.is_mouth_covered())
		owner.balloon_alert(owner, "mouth covered!")
		return FALSE
	//Find target, it will alert what the problem is, if any.
	if(!find_target())
		return FALSE
	return TRUE

/datum/action/bloodsucker/feed/ContinueActive(mob/living/user, mob/living/target)
	if(!target)
		return FALSE
	if(!user.Adjacent(target))
		return FALSE
	return TRUE

/datum/action/bloodsucker/feed/DeactivatePower()
	var/mob/living/user = owner
	if(target_ref)
		var/mob/living/feed_target = target_ref.resolve()
		log_combat(user, feed_target, "fed on blood", addition="(and took [blood_taken] blood)")
		user.balloon_alert(owner, "feed stopped")
		to_chat(user, span_notice("You slowly release [feed_target]."))
		if(feed_target.stat == DEAD)
			user.add_mood_event("drankkilled", /datum/mood_event/drankkilled)
			bloodsuckerdatum_power.AddHumanityLost(10)

	target_ref = null
	warning_target_bloodvol = BLOOD_VOLUME_MAX_LETHAL
	blood_taken = 0
	REMOVE_TRAIT(user, TRAIT_IMMOBILIZED, FEED_TRAIT)
	REMOVE_TRAIT(user, TRAIT_MUTE, FEED_TRAIT)
	return ..()

/datum/action/bloodsucker/feed/ActivatePower(trigger_flags)
	var/mob/living/feed_target = target_ref.resolve()
	if(istype(feed_target, /mob/living/basic/mouse))
		to_chat(owner, span_notice("You recoil at the taste of a lesser lifeform."))
		if(bloodsuckerdatum_power.my_clan.blood_drink_type != BLOODSUCKER_DRINK_INHUMANELY)
			var/mob/living/user = owner
			user.add_mood_event("drankblood", /datum/mood_event/drankblood_bad)
			bloodsuckerdatum_power.AddHumanityLost(1)
		bloodsuckerdatum_power.AddBloodVolume(25)
		DeactivatePower()
		feed_target.death()
		return
	var/feed_timer = clamp(round(FEED_DEFAULT_TIMER / (1.25 * level_current)), 1, FEED_DEFAULT_TIMER)
	if(bloodsuckerdatum_power.frenzied)
		feed_timer = 2 SECONDS

	owner.balloon_alert(owner, "feeding off [feed_target]...")
	if(!do_after(owner, feed_timer, feed_target, NONE, TRUE))
		owner.balloon_alert(owner, "interrupted!")
		DeactivatePower()
		return
	if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		if(!IS_BLOODSUCKER(feed_target) && !IS_VASSAL(feed_target) && !IS_MONSTERHUNTER(feed_target))
			feed_target.Unconscious((5 SECONDS + level_current))
		if(!feed_target.density)
			feed_target.Move(owner.loc)
	if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		owner.visible_message(
			span_warning("[owner] closes [owner.p_their()] mouth around [feed_target]'s neck!"),
			span_warning("You sink your fangs into [feed_target]'s neck."))
	else
		// Only people who AREN'T the target will notice this action.
		var/dead_message = feed_target.stat != DEAD ? " <i>[feed_target.p_they(TRUE)] looks dazed, and will not remember this.</i>" : ""
		owner.visible_message(
			span_notice("[owner] puts [feed_target]'s wrist up to [owner.p_their()] mouth."), \
			span_notice("You slip your fangs into [feed_target]'s wrist.[dead_message]"), \
			vision_distance = FEED_NOTICE_RANGE, ignored_mobs = feed_target)

	//check if we were seen
	for(var/mob/living/watchers in oviewers(FEED_NOTICE_RANGE) - feed_target)
		if(!watchers.client)
			continue
		if(watchers.has_unlimited_silicon_privilege)
			continue
		if(watchers.stat >= DEAD)
			continue
		if(watchers.is_blind() || watchers.is_nearsighted_currently())
			continue
		if(IS_BLOODSUCKER(watchers) || IS_VASSAL(watchers) || HAS_TRAIT(watchers.mind, TRAIT_BLOODSUCKER_HUNTER))
			continue
		owner.balloon_alert(owner, "feed noticed!")
		bloodsuckerdatum_power.give_masquerade_infraction()
		break

	ADD_TRAIT(owner, TRAIT_MUTE, FEED_TRAIT)
	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, FEED_TRAIT)
	return ..()

/datum/action/bloodsucker/feed/process(delta_time)
	var/mob/living/user = owner
	var/mob/living/feed_target = target_ref.resolve()
	if(!ContinueActive(user, feed_target))
		owner.balloon_alert(owner, "interrupted!")
		DeactivatePower()
		return

	var/feed_strength_mult = 0
	if(bloodsuckerdatum_power.frenzied)
		feed_strength_mult = 2
	else if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		feed_strength_mult = 1
	else
		feed_strength_mult = 0.3
	blood_taken += bloodsuckerdatum_power.handle_feeding(feed_target, feed_strength_mult, level_current)

	if(feed_strength_mult > 5 && feed_target.stat < DEAD)
		user.add_mood_event("drankblood", /datum/mood_event/drankblood)
	// Drank mindless as Ventrue? - BAD
	if((bloodsuckerdatum_power.my_clan.blood_drink_type == BLOODSUCKER_DRINK_SNOBBY) && !feed_target.mind)
		user.add_mood_event("drankblood", /datum/mood_event/drankblood_bad)
	if(feed_target.stat >= DEAD)
		user.add_mood_event("drankblood", /datum/mood_event/drankblood_dead)

	if(!IS_BLOODSUCKER(feed_target))
		if(feed_target.blood_volume <= BLOOD_VOLUME_BAD && warning_target_bloodvol > BLOOD_VOLUME_BAD)
			owner.balloon_alert(owner, "your victim's blood is fatally low!")
		else if(feed_target.blood_volume <= BLOOD_VOLUME_OKAY && warning_target_bloodvol > BLOOD_VOLUME_OKAY)
			owner.balloon_alert(owner, "your victim's blood is dangerously low.")
		else if(feed_target.blood_volume <= BLOOD_VOLUME_SAFE && warning_target_bloodvol > BLOOD_VOLUME_SAFE)
			owner.balloon_alert(owner, "your victim's blood is at an unsafe level.")
		warning_target_bloodvol = feed_target.blood_volume

	if(bloodsuckerdatum_power.bloodsucker_blood_volume >= bloodsuckerdatum_power.max_blood_volume)
		owner.balloon_alert(owner, "you are full...")
		DeactivatePower()
		return
	if(feed_target.blood_volume <= 0)
		owner.balloon_alert(owner, "out of blood...")
		DeactivatePower()
		return
	owner.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
	//play sound to target to show they're dying.
	if(owner.pulling == feed_target && owner.grab_state >= GRAB_AGGRESSIVE)
		feed_target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)

/datum/action/bloodsucker/feed/proc/find_target()
	if(owner.pulling && isliving(owner.pulling))
		if(!can_feed_from(owner.pulling, give_warnings = TRUE))
			return FALSE
		target_ref = WEAKREF(owner.pulling)
		return TRUE

	var/list/close_living_mobs = list()
	var/list/close_dead_mobs = list()
	for(var/mob/living/near_targets in oview(1, owner))
		if(!owner.Adjacent(near_targets))
			continue
		if(near_targets.stat)
			close_living_mobs |= near_targets
		else
			close_dead_mobs |= near_targets
	//Check living first
	for(var/mob/living/suckers in close_living_mobs)
		if(can_feed_from(suckers))
			target_ref = WEAKREF(suckers)
			return TRUE
	//If not, check dead
	for(var/mob/living/suckers in close_dead_mobs)
		if(can_feed_from(suckers))
			target_ref = WEAKREF(suckers)
			return TRUE
	//No one to suck blood from.
	return FALSE

/datum/action/bloodsucker/feed/proc/can_feed_from(mob/living/target, give_warnings = FALSE)
	if(istype(target, /mob/living/basic/mouse) || istype(target, /mob/living/basic/mouse/rat))
		if(bloodsuckerdatum_power.my_clan.blood_drink_type == BLOODSUCKER_DRINK_SNOBBY)
			if(give_warnings)
				to_chat(owner, span_warning("The thought of feeding off of a dirty rat leaves your stomach aching."))
			return FALSE
		return TRUE
	//Mice check done, only humans are otherwise allowed
	if(!ishuman(target))
		return FALSE

	var/mob/living/carbon/human/target_user = target
	if(!(target_user.dna?.species) || !(target_user.mob_biotypes & MOB_ORGANIC))
		if(give_warnings)
			to_chat(owner, span_warning("Your victim has no blood to take."))
		return FALSE
	if(!target_user.can_inject(owner, BODY_ZONE_HEAD, INJECT_CHECK_PENETRATE_THICK))
		if(give_warnings)
			to_chat(owner, span_warning("Their suit is too thick to feed through."))
		return FALSE
	if((bloodsuckerdatum_power.my_clan.blood_drink_type == BLOODSUCKER_DRINK_SNOBBY) && !target_user.mind && !bloodsuckerdatum_power.frenzied)
		if(give_warnings)
			to_chat(owner, span_warning("The thought of drinking blood from the mindsless leaves a distasteful feeling in your mouth."))
		return FALSE
	return TRUE

#undef FEED_NOTICE_RANGE
#undef FEED_DEFAULT_TIMER
