
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
		user.grab_state = GRAB_AGGRESSIVE
		return TRUE
	..()

/**
 * # Status effect
 *
 * This is the status effect given to Bloodsuckers in a Frenzy
 * This deals with everything entering/exiting Frenzy is meant to deal with.
 */

/datum/status_effect/frenzy
	id = "Frenzy"
	status_type = STATUS_EFFECT_UNIQUE
	duration = -1
	tick_interval = 10
	alert_type = /atom/movable/screen/alert/status_effect/frenzy
	/// Store whether they were an advancedtooluser, to give the trait back upon exiting.
	var/was_tooluser = FALSE
	/// The stored Bloodsucker antag datum
	var/datum/antagonist/bloodsucker/bloodsuckerdatum

/datum/status_effect/frenzy/get_examine_text()
	return "<span class='notice'>They seem... inhumane, and feral!</span>"

/atom/movable/screen/alert/status_effect/frenzy
	name = "Frenzy"
	desc = "You are in a Frenzy! You are entirely Feral and, depending on your Clan, fighting for your life!"
	icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	icon_state = "power_recover"

/atom/movable/screen/alert/status_effect/masquerade/MouseEntered(location,control,params)
	desc = initial(desc)
	return ..()

/datum/status_effect/frenzy/on_apply()
	var/mob/living/carbon/human/user = owner
	bloodsuckerdatum = IS_BLOODSUCKER(user)

	// Disable ALL Powers and notify their entry
	if(bloodsuckerdatum.my_clan == CLAN_BRUJAH)
		user.balloon_alert(user, "you enter a frenzy!")
		to_chat(user, span_announce("While in Frenzy, you gain the ability to instantly aggressively grab people, move faster, get stun resistance, and have no blood cost on abilities.<br> \n\
		* In exchange, you will slowly gain Brute damage, cannot speak, hear, or use advanced machineries. Be careful of how you handle it!<br> \n\
		* To leave Frenzy, simply drink enough Blood ([FRENZY_THRESHOLD_EXIT]) to exit.<br>"))
	else
		to_chat(user, "<span class='userdanger'><FONT size = 3>Blood! You need Blood, now! You enter a total Frenzy!</span>")
		to_chat(user, "<span class='announce'>* Bloodsucker Tip: While in Frenzy, you instantly Aggresively grab, cannot speak, hear, get stunned, or use any powers outside of Feed and Trespass (If you have it).</span><br>")
		bloodsuckerdatum.DisableAllPowers()

	ADD_TRAIT(user, TRAIT_STUNIMMUNE, FRENZY_TRAIT) // Brujah can control Frenzy properly, so they don't get any of the effects.
	ADD_TRAIT(user, TRAIT_MUTE, FRENZY_TRAIT)
	ADD_TRAIT(user, TRAIT_DEAF, FRENZY_TRAIT)
	if(HAS_TRAIT_FROM(user, TRAIT_ADVANCEDTOOLUSER, SPECIES_TRAIT))
		was_tooluser = TRUE
		REMOVE_TRAIT(user, TRAIT_ADVANCEDTOOLUSER, SPECIES_TRAIT)
	// Stamina resistances
	user.physiology.stamina_mod *= 0.4

	owner.add_movespeed_modifier(/datum/movespeed_modifier/morbin, TRUE)
	bloodsuckerdatum.frenzygrab.teach(user, TRUE)
	owner.add_client_colour(/datum/client_colour/cursed_heart_blood)
	var/obj/cuffs = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
	var/obj/legcuffs = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
	if(user.handcuffed || user.legcuffed)
		user.clear_cuffs(cuffs, TRUE)
		user.clear_cuffs(legcuffs, TRUE)
	// Keep track of how many times we've entered a Frenzy.
	bloodsuckerdatum.frenzies += 1
	bloodsuckerdatum.frenzied = TRUE
	return ..()

/datum/status_effect/frenzy/on_remove()
	var/mob/living/carbon/human/user = owner
	REMOVE_TRAIT(owner, TRAIT_MUTE, FRENZY_TRAIT)
	REMOVE_TRAIT(owner, TRAIT_DEAF, FRENZY_TRAIT)
	if(was_tooluser)
		ADD_TRAIT(owner, TRAIT_ADVANCEDTOOLUSER, SPECIES_TRAIT)
		was_tooluser = FALSE
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/morbin, TRUE)
	bloodsuckerdatum.frenzygrab.remove(user)
	owner.remove_client_colour(/datum/client_colour/cursed_heart_blood)
	if(bloodsuckerdatum.my_clan == CLAN_BRUJAH)
		to_chat(user, "<span class='warning'>You exit Frenzy.</span>")
	else
		user.adjust_dizzy(5 SECONDS)
		user.Paralyze(3 SECONDS)
		to_chat(user, "<span class='warning'>You suddenly come back to your senses...</span>")
	user.physiology.stamina_mod /= 0.4
	bloodsuckerdatum.frenzied = FALSE
	return ..()

/datum/status_effect/frenzy/tick()
	var/mob/living/carbon/human/user = owner
	if(!bloodsuckerdatum.frenzied)
		return
	if(bloodsuckerdatum.my_clan == CLAN_BRUJAH)
		user.adjustBruteLoss(1.5 + (bloodsuckerdatum.humanity_lost / 10))
	else
		user.adjustFireLoss(1.5 + (bloodsuckerdatum.humanity_lost / 10))
