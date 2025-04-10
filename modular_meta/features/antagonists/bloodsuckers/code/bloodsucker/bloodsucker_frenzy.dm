
/**
 * # FrenzyGrab
 *
 * The martial art given to Bloodsuckers so they can instantly aggressively grab people.
 */
/datum/martial_art/frenzygrab
	name = "Frenzy Grab"
	id = MARTIALART_FRENZYGRAB

/datum/martial_art/frenzygrab/grab_act(mob/living/user, mob/living/target)
	if(user != target)
		target.grabbedby(user)
		target.grippedby(user, instant = TRUE)
		return TRUE
	return ..()

/**
 * # Status effect
 *
 * This is the status effect given to Bloodsuckers in a Frenzy
 * This deals with everything entering/exiting Frenzy is meant to deal with.
 */

/atom/movable/screen/alert/status_effect/frenzy
	name = "Frenzy"
	desc = "You are in a frenzy! You are entirely feral and, depending on your clan, fighting for your life!"
	icon = 'modular_meta/features/antagonists/icons/bloodsuckers/bloodsucker_status_effects.dmi'
	icon_state = "frenzy"
	alerttooltipstyle = "cult"

/datum/status_effect/frenzy
	id = "Frenzy"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 10
	alert_type = /atom/movable/screen/alert/status_effect/frenzy
	///Boolean on whether they were an AdvancedToolUser, to give the trait back upon exiting.
	var/was_tooluser = FALSE
	/// The stored Bloodsucker antag datum
	var/datum/antagonist/bloodsucker/bloodsuckerdatum
	///Boolean indicating whether or not the owner is part of the Brujah clan
	///Used in passive burn damage calculation
	var/brujah = FALSE

/datum/status_effect/frenzy/get_examine_text()
	return span_cult_italic("They seem inhuman and feral!")

/atom/movable/screen/alert/status_effect/masquerade/MouseEntered(location,control,params)
	desc = initial(desc)
	return ..()

/datum/status_effect/frenzy/on_apply()
	var/mob/living/carbon/human/user = owner
	bloodsuckerdatum = IS_BLOODSUCKER(user)

	// Disable ALL Powers and notify their entry
	bloodsuckerdatum.DisableAllPowers(forced = TRUE)
	to_chat(owner, span_userdanger("<FONT size = 3>Blood! You need blood, <b>now</b>! You enter a total frenzy!"))
	to_chat(owner, span_announce("* Bloodsucker Tip: While in a frenzy, you instantly aggresively grab, have stun resistance, cannot speak, hear, or use any powers outside of Feed and Trespass (If you have it)."))
	owner.balloon_alert(owner, "you enter a frenzy!")
	SEND_SIGNAL(bloodsuckerdatum, BLOODSUCKER_ENTERS_FRENZY)

	// Give the other Frenzy effects
	owner.add_traits(list(TRAIT_MUTE, TRAIT_DEAF), FRENZY_TRAIT)
	if(HAS_TRAIT(owner, TRAIT_ADVANCEDTOOLUSER))
		was_tooluser = TRUE
		REMOVE_TRAIT(owner, TRAIT_ADVANCEDTOOLUSER, SPECIES_TRAIT)
	owner.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)
	bloodsuckerdatum.frenzygrab = new(src)
	bloodsuckerdatum.frenzygrab.teach(user)
	bloodsuckerdatum.frenzygrab.locked_to_use = TRUE
	owner.add_client_colour(/datum/client_colour/manual_heart_blood)
	var/obj/cuffs = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
	var/obj/legcuffs = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
	if(user.handcuffed || user.legcuffed)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, 1, -1)
		user.clear_cuffs(cuffs, TRUE)
		user.clear_cuffs(legcuffs, TRUE)
	bloodsuckerdatum.frenzied = TRUE

	// Determine if the owner is part of the Brujah clan
	if(istype(bloodsuckerdatum.my_clan, /datum/bloodsucker_clan/brujah))
		brujah = TRUE
	return ..()

/datum/status_effect/frenzy/on_remove()
	owner.balloon_alert(owner, "You come back to your senses.")
	owner.remove_traits(list(TRAIT_MUTE, TRAIT_DEAF), FRENZY_TRAIT)
	if(was_tooluser)
		ADD_TRAIT(owner, TRAIT_ADVANCEDTOOLUSER, SPECIES_TRAIT)
		was_tooluser = FALSE
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)
	QDEL_NULL(bloodsuckerdatum.frenzygrab)
	owner.remove_client_colour(/datum/client_colour/manual_heart_blood)

	SEND_SIGNAL(bloodsuckerdatum, BLOODSUCKER_EXITS_FRENZY)
	bloodsuckerdatum.frenzied = FALSE
	return ..()

/datum/status_effect/frenzy/tick()
	var/mob/living/carbon/human/user = owner
	if(!bloodsuckerdatum.frenzied)
		return
	//Passively accumulate burn damage (Bloodsuckers can't survive on low blood forever).
	//Humanity loss is supposed to be a bad thing for Bloodsuckers so it adds to this damage.
	//Brujah Bloodsuckers start with a lot of lost humanity so we give them a bit of leeway.
	user.adjustFireLoss(1.5 + (brujah ? 1 : (bloodsuckerdatum.humanity_lost / 10)))
	if(prob(30))
		user.do_jitter_animation(300)
		return
	if(prob(10))
		user.emote("tremble")
		return
	if(prob(5))
		user.emote("screech")
		return
