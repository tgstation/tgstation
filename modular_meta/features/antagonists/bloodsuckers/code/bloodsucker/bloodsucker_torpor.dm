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

/atom/movable/screen/alert/status_effect/torpor
	name = "Torpor"
	desc = "You have returned to the precipice of oblivion once more. Through this you shall recover at the expense of being immensely vulnerable."
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/bloodsucker_status_effects.dmi'
	icon_state = "torpor"
	alerttooltipstyle = "alien"

/datum/status_effect/torpor
	id = "Torpor"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/torpor
	/// Our Bloodsucker's antag datum.
	var/datum/antagonist/bloodsucker/bloodsuckerdatum

/datum/status_effect/torpor/on_apply()
	. = ..()
	var/mob/living/carbon/human/user = owner
	bloodsuckerdatum = IS_BLOODSUCKER(user)

	to_chat(owner, span_notice("You enter the horrible slumber of deathless Torpor. You will heal until you are renewed."))
	// Force them to go to sleep
	REMOVE_TRAIT(owner, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	// Without this, you'll just keep dying while you recover.
	owner.add_traits(list(TRAIT_NODEATH, TRAIT_FAKEDEATH, TRAIT_DEATHCOMA, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE), BLOODSUCKER_TRAIT)
	owner.set_timed_status_effect(0 SECONDS, /datum/status_effect/jitter, only_if_higher = TRUE)
	// Disable ALL Powers
	bloodsuckerdatum.DisableAllPowers()

/datum/status_effect/torpor/on_remove()
	owner.grab_ghost()
	to_chat(owner, span_warning("You have recovered from Torpor."))
	owner.remove_traits(list(TRAIT_NODEATH, TRAIT_FAKEDEATH, TRAIT_DEATHCOMA, TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTHIGHPRESSURE), BLOODSUCKER_TRAIT)
	if(!HAS_TRAIT(owner, TRAIT_MASQUERADE))
		ADD_TRAIT(owner, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	bloodsuckerdatum.heal_vampire_organs()
	SEND_SIGNAL(bloodsuckerdatum, BLOODSUCKER_EXIT_TORPOR)

/datum/antagonist/bloodsucker/proc/check_begin_torpor(SkipChecks = FALSE)
	var/mob/living/carbon/user = owner.current
	/// Prevent Torpor whilst frenzied.
	if(frenzied || (IS_DEAD_OR_INCAP(user) && bloodsucker_blood_volume == 0))
		to_chat(user, span_userdanger("Your frenzy prevents you from entering torpor!"))
		return
	/// Are we entering Torpor via Sol/Death? Then entering it isnt optional!
	if(SkipChecks)
		to_chat(user, span_danger("Your immortal body will not yet relinquish your soul to the abyss. You enter Torpor."))
		owner.current.apply_status_effect(/datum/status_effect/torpor)
		return
	var/total_brute = user.getBruteLoss()
	var/total_burn = user.getFireLoss()
	var/total_damage = total_brute + total_burn
	/// Checks - Not daylight & Has more than 10 Brute/Burn & not already in Torpor
	if(!SSsunlight.sunlight_active && total_damage >= 10 && !HAS_TRAIT(owner.current, TRAIT_NODEATH))
		owner.current.apply_status_effect(/datum/status_effect/torpor)

/datum/antagonist/bloodsucker/proc/check_end_torpor()
	var/mob/living/carbon/user = owner.current
	var/total_brute = user.getBruteLoss()
	var/total_burn = user.getFireLoss()
	var/total_damage = total_brute + total_burn
	if(total_burn >= 199)
		return FALSE
	if(SSsunlight.sunlight_active)
		return FALSE
	// You are in a Coffin, so instead we'll check TOTAL damage, here.
	if(istype(user.loc, /obj/structure/closet/crate/coffin))
		if(total_damage <= 10)
			owner.current.remove_status_effect(/datum/status_effect/torpor)
	else
		if(total_brute <= 10)
			owner.current.remove_status_effect(/datum/status_effect/torpor)
