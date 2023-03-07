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
	var/mob/living/living_owner = owner.current
	if(HAS_TRAIT(living_owner, TRAIT_NODEATH))
		check_end_torpor()
	// Deduct Blood
	if(living_owner.stat == CONSCIOUS && !HAS_TRAIT(living_owner, TRAIT_IMMOBILIZED) && !HAS_TRAIT(living_owner, TRAIT_NODEATH))
		INVOKE_ASYNC(src, PROC_REF(AddBloodVolume), -BLOODSUCKER_PASSIVE_BLOOD_DRAIN) // -.1 currently
	if(HandleHealing())
		if((COOLDOWN_FINISHED(src, bloodsucker_spam_healing)) && living_owner.blood_volume > 0)
			to_chat(owner.current, span_notice("The power of your blood begins knitting your wounds..."))
			COOLDOWN_START(src, bloodsucker_spam_healing, BLOODSUCKER_SPAM_HEALING)
	// Standard Updates
	INVOKE_ASYNC(src, PROC_REF(HandleDeath))
	INVOKE_ASYNC(src, PROC_REF(HandleStarving))

	INVOKE_ASYNC(src, PROC_REF(update_hud))

	/// Special check, Tremere Bloodsuckers burn while in the Chapel
	if(my_clan == CLAN_TREMERE)
		var/area/A = get_area(owner.current)
		if(istype(A, /area/station/service/chapel))
			to_chat(owner.current, "<span class='warning'>You don't belong in holy areas!</span>")
			owner.current.adjustFireLoss(10)
			owner.current.adjust_fire_stacks(2)
			owner.current.ignite_mob()

	if(my_clan == CLAN_MALKAVIAN && prob(15) && !HAS_TRAIT(owner.current, TRAIT_MASQUERADE) && owner.current.stat)
		switch(rand(0,4))
			if(0) // 20% chance to call out a player at their location
				for(var/mob/living/carbon/human/H in shuffle(GLOB.player_list))
					if(!H.mind)
						continue
					if(!H.stat == DEAD || HAS_TRAIT(H, TRAIT_CRITICAL_CONDITION))
						continue
					if(!SSjob.GetJob(H.mind.assigned_role) || !is_station_level(H))
						continue
					var/area/A = get_area(H)
					owner.current.say("#...oh dear... [H]... what are you doing... at [A]?")
					break
			else // 80% chance to say some malkavian revelation
				owner.current.say(pick(strings("malkavian_revelations.json", "revelations")))

/**
 * ## BLOOD STUFF
 */

/// mult: SILENT feed is 1/3 the amount
/datum/antagonist/bloodsucker/proc/handle_feeding(mob/living/carbon/target, mult=1, power_level)
	// Starts at 15 (now 8 since we doubled the Feed time)
	var/feed_amount = 15 + (power_level * 2)
	var/blood_taken = min(feed_amount, target.blood_volume) * mult
	var/mob/living/living_owner = owner.current
	target.blood_volume -= blood_taken

	///////////
	// Shift Body Temp (toward Target's temp, by volume taken)
	living_owner.bodytemperature = ((living_owner.blood_volume * owner.current.bodytemperature) + (blood_taken * target.bodytemperature)) / (living_owner.blood_volume + blood_taken)
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
	if(owner.current.AmStaked() || (HAS_TRAIT(owner.current, TRAIT_MASQUERADE) && !HAS_TRAIT(owner.current, TRAIT_NODEATH)))
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
		user.heal_bodypart_damage(bruteheal * mult, fireheal * mult)
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
	for(var/all_organs in bloodsuckeruser.internal_organs)
		var/obj/item/organ/organ = all_organs
		organ.setOrganDamage(0)
	var/obj/item/organ/internal/heart/current_heart = bloodsuckeruser.getorganslot(ORGAN_SLOT_HEART)
	if(!istype(current_heart, /obj/item/organ/internal/heart/vampheart) && !istype(current_heart, /obj/item/organ/internal/heart/demon) && !istype(current_heart, /obj/item/organ/internal/heart/cursed))
		qdel(current_heart)
		var/obj/item/organ/internal/heart/vampheart/vampiric_heart = new
		vampiric_heart.Insert(owner.current)
		vampiric_heart.Stop()
	var/obj/item/organ/internal/eyes/current_eyes = bloodsuckeruser.getorganslot(ORGAN_SLOT_EYES)
	if(current_eyes)
		current_eyes.flash_protect = max(initial(current_eyes.flash_protect) - 1, FLASH_PROTECTION_SENSITIVE)
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
		bloodsuckeruser.getorgan(/obj/item/organ/internal/body_egg),
		bloodsuckeruser.getorgan(/obj/item/organ/internal/zombie_infection))
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
	if(owner.current.StakeCanKillMe() && owner.current.AmStaked())
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
	var/mob/living/living_owner = owner.current
	living_owner.set_nutrition(min(living_owner.blood_volume, NUTRITION_LEVEL_FED))

	// BLOOD_VOLUME_GOOD: [336] - Pale
//	handled in bloodsucker_integration.dm

	// BLOOD_VOLUME_EXIT: [250] - Exit Frenzy (If in one) This is high because we want enough to kill the poor soul they feed off of.
	if(living_owner.blood_volume >= FRENZY_THRESHOLD_EXIT && frenzied && my_clan != CLAN_BRUJAH)
		owner.current.remove_status_effect(/datum/status_effect/frenzy)
	// BLOOD_VOLUME_BAD: [224] - Jitter
	if(living_owner.blood_volume < BLOOD_VOLUME_BAD && prob(0.5) && !HAS_TRAIT(living_owner, TRAIT_NODEATH) && !HAS_TRAIT(living_owner, TRAIT_MASQUERADE))
		owner.current.set_timed_status_effect(3 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	// BLOOD_VOLUME_SURVIVE: [122] - Blur Vision
	if(living_owner.blood_volume < BLOOD_VOLUME_SURVIVE)
		owner.current.set_eye_blur_if_lower((8 - 8 * (living_owner.blood_volume / BLOOD_VOLUME_BAD))*2 SECONDS)

	// The more blood, the better the Regeneration, get too low blood, and you enter Frenzy.
	if(living_owner.blood_volume < (frenzy_threshold + (humanity_lost * 10)) && !frenzied)
		if(my_clan != CLAN_BRUJAH)
			living_owner.apply_status_effect(/datum/status_effect/frenzy)
		else
			for(var/datum/action/bloodsucker/power in powers)
				if(istype(power, /datum/action/bloodsucker/brujah))
					if(power.active)
						return
					power.ActivatePower()
	else if(living_owner.blood_volume < BLOOD_VOLUME_BAD)
		additional_regen = 0.1
	else if(living_owner.blood_volume < BLOOD_VOLUME_OKAY)
		additional_regen = 0.2
	else if(living_owner.blood_volume < BLOOD_VOLUME_NORMAL)
		additional_regen = 0.3
	else if(living_owner.blood_volume < BS_BLOOD_VOLUME_MAX_REGEN)
		additional_regen = 0.4
	else
		additional_regen = 0.5

/// Gibs the Bloodsucker, roundremoving them.
/datum/antagonist/bloodsucker/proc/FinalDeath()
	// If we have no body, end here.
	if(!owner.current || dust_timer)
		return

	FreeAllVassals()
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

/**
 * # Torpor
 *
 * Torpor is what deals with the Bloodsucker falling asleep, their healing, the effects, ect.
 * This is basically what Sol is meant to do to them, but they can also trigger it manually if they wish to heal, as Burn is only healed through Torpor.
 * You cannot manually exit Torpor, it is instead entered/exited by:
 *
 * Torpor is triggered by:
 * - Being in a Coffin while Sol is on, dealt with by Sol
 * - Entering a Coffin with more than 10 combined Brute/Burn damage, dealt with by /closet/crate/coffin/close() [bloodsucker_coffin.dm]
 * - Death, dealt with by /HandleDeath()
 * Torpor is ended by:
 * - Having less than 10 Brute damage while OUTSIDE of your Coffin while it isnt Sol.
 * - Having less than 10 Brute & Burn Combined while INSIDE of your Coffin while it isnt Sol.
 * - Sol being over, dealt with by /sunlight/process() [bloodsucker_daylight.dm]
*/
/datum/antagonist/bloodsucker/proc/check_begin_torpor(SkipChecks = FALSE)
	/// Are we entering Torpor via Sol/Death? Then entering it isnt optional!
	if(SkipChecks)
		torpor_begin()
		return
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss()
	var/total_burn = user.getFireLoss()
	var/total_damage = total_brute + total_burn
	/// Checks - Not daylight & Has more than 10 Brute/Burn & not already in Torpor
	if(!clan.bloodsucker_sunlight.amDay && total_damage >= 10 && !HAS_TRAIT(owner.current, TRAIT_NODEATH))
		torpor_begin()

/datum/antagonist/bloodsucker/proc/check_end_torpor()
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss()
	var/total_burn = user.getFireLoss()
	var/total_damage = total_brute + total_burn
	// You are in a Coffin, so instead we'll check TOTAL damage, here.
	if(istype(user.loc, /obj/structure/closet/crate/coffin))
		if(!clan.bloodsucker_sunlight.amDay && total_damage <= 10)
			torpor_end()
	// You're not in a Coffin? We won't check for low Burn damage
	else if(!clan.bloodsucker_sunlight.amDay && total_brute <= 10)
		// You're under 10 brute, but over 200 Burn damage? Don't exit Torpor, to prevent spam revival/death. Only way out is healing that Burn.
		if(total_burn >= 199)
			return
		torpor_end()

/datum/antagonist/bloodsucker/proc/torpor_begin()
	to_chat(owner.current, span_notice("You enter the horrible slumber of deathless Torpor. You will heal until you are renewed."))
	/// Force them to go to sleep
	REMOVE_TRAIT(owner.current, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	/// Without this, you'll just keep dying while you recover.
	ADD_TRAIT(owner.current, TRAIT_NODEATH, BLOODSUCKER_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_FAKEDEATH, BLOODSUCKER_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_DEATHCOMA, BLOODSUCKER_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, BLOODSUCKER_TRAIT)
	owner.current.set_timed_status_effect(0 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	/// Disable ALL Powers
	DisableAllPowers()

/datum/antagonist/bloodsucker/proc/torpor_end()
	owner.current.grab_ghost()
	to_chat(owner.current, span_warning("You have recovered from Torpor."))
	REMOVE_TRAIT(owner.current, TRAIT_RESISTLOWPRESSURE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_DEATHCOMA, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_FAKEDEATH, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(owner.current, TRAIT_NODEATH, BLOODSUCKER_TRAIT)
	ADD_TRAIT(owner.current, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	heal_vampire_organs()

/datum/antagonist/bloodsucker/proc/AddBloodVolume(value)
	owner.current.blood_volume = clamp(owner.current.blood_volume + value, 0, max_blood_volume)
	update_hud()

/datum/antagonist/bloodsucker/proc/AddHumanityLost(value)
	if(humanity_lost >= 500)
		to_chat(owner.current, span_warning("You hit the maximum amount of lost Humanity, you are far from Human."))
		return
	humanity_lost += value
	to_chat(owner.current, span_warning("You feel as if you lost some of your humanity, you will now enter Frenzy at [frenzy_threshold + (humanity_lost * 10)] Blood."))

// Bloodsuckers moodlets //
/datum/mood_event/drankblood
	description = "<span class='nicegreen'>I have fed greedly from that which nourishes me.</span>\n"
	mood_change = 10
	timeout = 8 MINUTES

/datum/mood_event/drankblood_bad
	description = "<span class='boldwarning'>I drank the blood of a lesser creature. Disgusting.</span>\n"
	mood_change = -4
	timeout = 3 MINUTES

/datum/mood_event/drankblood_dead
	description = "<span class='boldwarning'>I drank dead blood. I am better than this.</span>\n"
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankblood_synth
	description = "<span class='boldwarning'>I drank synthetic blood. What is wrong with me?</span>\n"
	mood_change = -7
	timeout = 8 MINUTES

/datum/mood_event/drankkilled
	description = "<span class='boldwarning'>I drank from my victim until they died. I feel... less human.</span>\n"
	mood_change = -15
	timeout = 10 MINUTES

/datum/mood_event/madevamp
	description = "<span class='boldwarning'>A soul has been cursed to undeath by my own hand.</span>\n"
	mood_change = 15
	timeout = 20 MINUTES

/datum/mood_event/coffinsleep
	description = "<span class='nicegreen'>I slept in a coffin during the day. I feel whole again.</span>\n"
	mood_change = 10
	timeout = 6 MINUTES

/datum/mood_event/daylight_1
	description = "<span class='boldwarning'>I slept poorly in a makeshift coffin during the day.</span>\n"
	mood_change = -3
	timeout = 6 MINUTES

/datum/mood_event/daylight_2
	description = "<span class='boldwarning'>I have been scorched by the unforgiving rays of the sun.</span>\n"
	mood_change = -6
	timeout = 6 MINUTES

///Candelabrum's mood event to non Bloodsucker/Vassals
/datum/mood_event/vampcandle
	description = "<span class='boldwarning'>Something is making your mind feel... loose.</span>\n"
	mood_change = -15
	timeout = 5 MINUTES

#undef BLOODSUCKER_PASSIVE_BLOOD_DRAIN
