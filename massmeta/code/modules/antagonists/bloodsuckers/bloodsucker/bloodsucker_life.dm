///How much Blood it costs to live.
#define BLOODSUCKER_PASSIVE_BLOOD_DRAIN 0.1

/// Runs from COMSIG_LIVING_LIFE, handles Bloodsucker constant proccesses.
/datum/antagonist/bloodsucker/proc/LifeTick()
	SIGNAL_HANDLER

	if(isbrain(owner.current))
		return
	if(!owner)
		INVOKE_ASYNC(src, PROC_REF(HandleDeath))
		return
	if(HAS_TRAIT(owner.current, TRAIT_NODEATH))
		check_end_torpor()
	// Deduct Blood
	if(owner.current.stat == CONSCIOUS && !HAS_TRAIT(owner.current, TRAIT_IMMOBILIZED) && !HAS_TRAIT(owner.current, TRAIT_NODEATH))
		INVOKE_ASYNC(src, PROC_REF(AddBloodVolume), -BLOODSUCKER_PASSIVE_BLOOD_DRAIN) // -.1 currently
	if(HandleHealing())
		if((COOLDOWN_FINISHED(src, bloodsucker_spam_healing)) && bloodsucker_blood_volume > 0)
			to_chat(owner.current, span_notice("The power of your blood begins knitting your wounds..."))
			COOLDOWN_START(src, bloodsucker_spam_healing, BLOODSUCKER_SPAM_HEALING)
	// Standard Updates
	INVOKE_ASYNC(src, PROC_REF(HandleDeath))
	INVOKE_ASYNC(src, PROC_REF(HandleStarving))
	INVOKE_ASYNC(src, PROC_REF(update_blood))

	INVOKE_ASYNC(src, PROC_REF(update_hud))

	if(my_clan)
		SEND_SIGNAL(my_clan, BLOODSUCKER_HANDLE_LIFE, src)

/**
 * ## BLOOD STUFF
 */
/datum/antagonist/bloodsucker/proc/AddBloodVolume(value)
	bloodsucker_blood_volume = clamp(bloodsucker_blood_volume + value, 0, max_blood_volume)

/datum/antagonist/bloodsucker/proc/AddHumanityLost(value)
	if(humanity_lost >= 500)
		to_chat(owner.current, span_warning("You hit the maximum amount of lost Humanty, you are far from Human."))
		return
	humanity_lost += value
	to_chat(owner.current, span_warning("You feel as if you lost some of your humanity, you will now enter Frenzy at [FRENZY_THRESHOLD_ENTER + (humanity_lost * 10)] Blood."))

/// mult: SILENT feed is 1/3 the amount
/datum/antagonist/bloodsucker/proc/handle_feeding(mob/living/carbon/target, mult=1, power_level)
	// Starts at 15 (now 8 since we doubled the Feed time)
	var/feed_amount = 15 + (power_level * 2)
	var/blood_taken = min(feed_amount, target.blood_volume) * mult
	target.blood_volume -= blood_taken

	///////////
	// Shift Body Temp (toward Target's temp, by volume taken)
	owner.current.bodytemperature = ((bloodsucker_blood_volume * owner.current.bodytemperature) + (blood_taken * target.bodytemperature)) / (bloodsucker_blood_volume + blood_taken)
	// our volume * temp, + their volume * temp, / total volume
	///////////
	// Reduce Value Quantity
	if(target.stat == DEAD) // Penalty for Dead Blood
		blood_taken /= 3
	if(!ishuman(target)) // Penalty for Non-Human Blood
		blood_taken /= 2
	//if (!iscarbon(target)) // Penalty for Animals (they're junk food)
	// Apply to Volume
	AddBloodVolume(blood_taken)
	// Reagents (NOT Blood!)
	if(target.reagents && target.reagents.total_volume)
		target.reagents.trans_to(owner.current, INGEST, 1) // Run transfer of 1 unit of reagent from them to me.
	owner.current.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, 1) // Play THIS sound for user only. The "null" is where turf would go if a location was needed. Null puts it right in their head.
	total_blood_drank += blood_taken
	return blood_taken

/**
 * ## HEALING
 */

/// Constantly runs on Bloodsucker's LifeTick, and is increased by being in Torpor/Coffins
/datum/antagonist/bloodsucker/proc/HandleHealing(mult = 1)
	var/actual_regen = bloodsucker_regen_rate + additional_regen
	// Don't heal if I'm staked or on Masquerade (+ not in a Coffin). Masqueraded Bloodsuckers in a Coffin however, will heal.
	if(owner.current.am_staked() || (HAS_TRAIT(owner.current, TRAIT_MASQUERADE) && !HAS_TRAIT(owner.current, TRAIT_NODEATH)))
		return FALSE
	owner.current.adjustCloneLoss(-1 * (actual_regen * 4) * mult, 0)
	owner.current.adjustOrganLoss(ORGAN_SLOT_BRAIN, -1 * (actual_regen * 4) * mult) //adjustBrainLoss(-1 * (actual_regen * 4) * mult, 0)
	if(!iscarbon(owner.current)) // Damage Heal: Do I have damage to ANY bodypart?
		return
	var/mob/living/carbon/user = owner.current
	var/costMult = 1 // Coffin makes it cheaper
	var/bruteheal = min(user.getBruteLoss(), actual_regen) // BRUTE: Always Heal
	var/fireheal = 0 // BURN: Heal in Coffin while Fakedeath, or when damage above maxhealth (you can never fully heal fire)
	/// Checks if you're in a coffin here, additionally checks for Torpor right below it.
	var/amInCoffin = istype(user.loc, /obj/structure/closet/crate/coffin)
	if(amInCoffin && HAS_TRAIT(user, TRAIT_NODEATH))
		if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
			to_chat(user, span_warning("You do not heal while your Masquerade ability is active."))
			return
		fireheal = min(user.getFireLoss(), actual_regen)
		mult *= 5 // Increase multiplier if we're sleeping in a coffin.
		costMult /= 2 // Decrease cost if we're sleeping in a coffin.
		user.extinguish_mob()
		user.remove_all_embedded_objects() // Remove Embedded!
		if(check_limbs(costMult))
			return TRUE
	// In Torpor, but not in a Coffin? Heal faster anyways.
	else if(HAS_TRAIT(user, TRAIT_NODEATH))
		mult *= 3
	// Heal if Damaged
	if((bruteheal + fireheal > 0) && mult != 0) // Just a check? Don't heal/spend, and return.
		// We have damage. Let's heal (one time)
		user.adjustBruteLoss(-bruteheal * mult, forced=TRUE) // Heal BRUTE / BURN in random portions throughout the body.
		user.adjustFireLoss(-fireheal * mult, forced=TRUE)
		AddBloodVolume(((bruteheal * -0.5) + (fireheal * -1)) * costMult * mult) // Costs blood to heal
		return TRUE

/datum/antagonist/bloodsucker/proc/check_limbs(costMult = 1)
	var/limb_regen_cost = 50 * -costMult
	var/mob/living/carbon/user = owner.current
	var/list/missing = user.get_missing_limbs()
	if(missing.len && (user.blood_volume < limb_regen_cost + 5))
		return FALSE
	for(var/missing_limb in missing) //Find ONE Limb and regenerate it.
		user.regenerate_limb(missing_limb, FALSE)
		AddBloodVolume(limb_regen_cost)
		var/obj/item/bodypart/missing_bodypart = user.get_bodypart(missing_limb) // 2) Limb returns Damaged
		missing_bodypart.brute_dam = 60
		to_chat(user, span_notice("Your flesh knits as it regrows your [missing_bodypart]!"))
		playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
		return TRUE

/*
 *	# Heal Vampire Organs
 *
 *	This is used by Bloodsuckers, these are the steps of this proc:
 *	Step 1 - Cure husking and Regenerate organs. regenerate_organs() removes their Vampire Heart & Eye augments, which leads us to...
 *	Step 2 - Repair any (shouldn't be possible) Organ damage, then return their Vampiric Heart & Eye benefits.
 *	Step 3 - Revive them, clear all wounds, remove any Tumors (If any).
 *
 *	This is called on Bloodsucker's Assign, and when they end Torpor.
 */

/datum/antagonist/bloodsucker/proc/heal_vampire_organs()
	var/mob/living/carbon/bloodsuckeruser = owner.current

	// Step 1 - Fix basic things, husk and organs.
	bloodsuckeruser.cure_husk()
	bloodsuckeruser.regenerate_organs()

	// Step 2 NOTE: Giving passive organ regeneration will cause Torpor to spam /datum/client_colour/monochrome at the Bloodsucker, permanently making them colorblind!
	for(var/all_organs in bloodsuckeruser.organs)
		var/obj/item/organ/organ = all_organs
		organ.set_organ_damage(0)
	var/obj/item/organ/internal/heart/current_heart = bloodsuckeruser.get_organ_slot(ORGAN_SLOT_HEART)
	if(!istype(current_heart, /obj/item/organ/internal/heart/vampheart) && !istype(current_heart, /obj/item/organ/internal/heart/demon) && !istype(current_heart, /obj/item/organ/internal/heart/cursed))
		qdel(current_heart)
		var/obj/item/organ/internal/heart/vampheart/vampiric_heart = new
		vampiric_heart.Insert(owner.current)
		vampiric_heart.Stop()
	var/obj/item/organ/internal/eyes/current_eyes = bloodsuckeruser.get_organ_slot(ORGAN_SLOT_EYES)
	if(current_eyes)
		current_eyes.flash_protect = max(initial(current_eyes.flash_protect) - 1, FLASH_PROTECTION_SENSITIVE)
		current_eyes.color_cutoffs = list(60, 16, 10)
		current_eyes.sight_flags = SEE_MOBS
	bloodsuckeruser.update_sight()

	// Step 3
	if(bloodsuckeruser.stat == DEAD)
		bloodsuckeruser.revive()
	for(var/i in bloodsuckeruser.all_wounds)
		var/datum/wound/iter_wound = i
		iter_wound.remove_wound()
	// From [powers/panacea.dm]
	var/list/bad_organs = list(
		bloodsuckeruser.get_organ_by_type(/obj/item/organ/internal/body_egg),
		bloodsuckeruser.get_organ_by_type(/obj/item/organ/internal/zombie_infection))
	for(var/tumors in bad_organs)
		var/obj/item/organ/yucky_organs = tumors
		if(!istype(yucky_organs))
			continue
		yucky_organs.Remove(bloodsuckeruser)
		yucky_organs.forceMove(get_turf(bloodsuckeruser))

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//			DEATH

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/// FINAL DEATH
/datum/antagonist/bloodsucker/proc/HandleDeath()
	// Not "Alive"?
	if(!owner.current || !get_turf(owner.current))
		FinalDeath()
		return
	// Fire Damage? (above double health)
	if(owner.current.getFireLoss() >= owner.current.maxHealth * 2.5)
		FinalDeath()
		return
	// Staked while "Temp Death" or Asleep
	if(owner.current.StakeCanKillMe() && owner.current.am_staked())
		FinalDeath()
		return
	// Not organic/living? (Zombie/Skeleton/Plasmaman)
	if(!(owner.current.mob_biotypes & MOB_ORGANIC))
		FinalDeath()
		return
	// Temporary Death? Convert to Torpor.
	if(owner.current.stat == DEAD)
		var/mob/living/carbon/human/dead_bloodsucker = owner.current
		if(!HAS_TRAIT(dead_bloodsucker, TRAIT_NODEATH))
			to_chat(dead_bloodsucker, span_danger("Your immortal body will not yet relinquish your soul to the abyss. You enter Torpor."))
			check_begin_torpor(TRUE)

/datum/antagonist/bloodsucker/proc/HandleStarving() // I am thirsty for blood!
	// Nutrition - The amount of blood is how full we are.
	owner.current.set_nutrition(min(bloodsucker_blood_volume, NUTRITION_LEVEL_FED))

	// BLOOD_VOLUME_GOOD: [336] - Pale
//	handled in bloodsucker_integration.dm

	// BLOOD_VOLUME_EXIT: [250] - Exit Frenzy (If in one) This is high because we want enough to kill the poor soul they feed off of.
	if(bloodsucker_blood_volume >= (FRENZY_THRESHOLD_EXIT + (humanity_lost * 10)) && frenzied)
		owner.current.remove_status_effect(/datum/status_effect/frenzy)
	// BLOOD_VOLUME_BAD: [224] - Jitter
	if(bloodsucker_blood_volume < BLOOD_VOLUME_BAD && prob(0.5) && !HAS_TRAIT(owner.current, TRAIT_NODEATH) && !HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		owner.current.set_timed_status_effect(3 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	// BLOOD_VOLUME_SURVIVE: [122] - Blur Vision
	if(bloodsucker_blood_volume < BLOOD_VOLUME_SURVIVE)
		owner.current.set_eye_blur_if_lower((8 - 8 * (bloodsucker_blood_volume / BLOOD_VOLUME_BAD))*2 SECONDS)

	// The more blood, the better the Regeneration, get too low blood, and you enter Frenzy.
	if(bloodsucker_blood_volume < (FRENZY_THRESHOLD_ENTER + (humanity_lost * 10)) && !frenzied)
		owner.current.apply_status_effect(/datum/status_effect/frenzy)
	else if(bloodsucker_blood_volume < BLOOD_VOLUME_BAD)
		additional_regen = 0.1
	else if(bloodsucker_blood_volume < BLOOD_VOLUME_OKAY)
		additional_regen = 0.2
	else if(bloodsucker_blood_volume < BLOOD_VOLUME_NORMAL)
		additional_regen = 0.3
	else if(bloodsucker_blood_volume < BS_BLOOD_VOLUME_MAX_REGEN)
		additional_regen = 0.4
	else
		additional_regen = 0.5

/// Makes your blood_volume look like your bloodsucker blood, unless you're Masquerading.
/datum/antagonist/bloodsucker/proc/update_blood()
	//If we're on Masquerade, we appear to have full blood, unless we are REALLY low, in which case we don't look as bad.
	if(HAS_TRAIT(owner.current, TRAIT_MASQUERADE))
		switch(bloodsucker_blood_volume)
			if(BLOOD_VOLUME_OKAY to INFINITY) // 336 and up, we are perfectly fine.
				owner.current.blood_volume = initial(bloodsucker_blood_volume)
			if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY) // 224 to 336
				owner.current.blood_volume = BLOOD_VOLUME_SAFE
			else // 224 and below
				owner.current.blood_volume = BLOOD_VOLUME_OKAY
		return

	owner.current.blood_volume = bloodsucker_blood_volume

/// Gibs the Bloodsucker, roundremoving them.
/datum/antagonist/bloodsucker/proc/FinalDeath()
	// If we have no body, end here.
	if(!owner.current || dust_timer)
		return

	free_all_vassals()
	DisableAllPowers(forced = TRUE)
	if(!iscarbon(owner.current))
		owner.current.gib(TRUE, FALSE, FALSE)
		return
	// Drop anything in us and play a tune
	var/mob/living/carbon/user = owner.current
	owner.current.drop_all_held_items()
	owner.current.unequip_everything()
	user.remove_all_embedded_objects()
	playsound(owner.current, 'sound/effects/tendril_destroyed.ogg', 40, TRUE)

	if(my_clan)
		var/unique_death = SEND_SIGNAL(my_clan, BLOODSUCKER_FINAL_DEATH, owner.current)
		if(unique_death & DONT_DUST)
			return

	// Elders get dusted, Fledglings get gibbed.
	if(bloodsucker_level >= 4)
		user.visible_message(
			span_warning("[user]'s skin crackles and dries, their skin and bones withering to dust. A hollow cry whips from what is now a sandy pile of remains."),
			span_userdanger("Your soul escapes your withering body as the abyss welcomes you to your Final Death."),
			span_hear("You hear a dry, crackling sound."))
		dust_timer = addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, dust)), 5 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)
		return
	user.visible_message(
		span_warning("[user]'s skin bursts forth in a spray of gore and detritus. A horrible cry echoes from what is now a wet pile of decaying meat."),
		span_userdanger("Your soul escapes your withering body as the abyss welcomes you to your Final Death."),
		span_hear("<span class='italics'>You hear a wet, bursting sound."))
	dust_timer = addtimer(CALLBACK(user, TYPE_PROC_REF(/mob/living, gib), TRUE, FALSE, FALSE), 2 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

#undef BLOODSUCKER_PASSIVE_BLOOD_DRAIN
