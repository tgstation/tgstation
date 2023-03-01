/**
 *	# WITHOUT THIS POWER:
 *
 *	- Mid-Blood: SHOW AS PALE
 *	- Low-Blood: SHOW AS DEAD
 *	- No Heartbeat
 *  - Examine shows actual blood
 *	- Thermal homeostasis (ColdBlooded)
 * 		WITH THIS POWER:
 *	- Normal body temp -- remove Cold Blooded (return on deactivate)
 */

/datum/action/cooldown/bloodsucker/masquerade
	name = "Masquerade"
	desc = "Feign the vital signs of a mortal, and escape both casual and medical notice as the monster you truly are."
	button_icon_state = "power_human"
	power_explanation = "<b>Masquerade</b>:\n\
		Activating Masquerade will forge your identity to be practically identical to that of a human;\n\
		- You lose nearly all Bloodsucker benefits, including healing, sleep, radiation, crit, virus and cold immunity.\n\
		- Your eyes turn to that of a regular human as your heart begins to beat.\n\
		- You gain a Genetic sequence, and appear to have 100% blood when scanned by a Health Analyzer.\n\
		- You will not appear as Pale when examined. Anything further than Pale, however, will not be hidden.\n\
		At the end of a Masquerade, you will re-gain your Vampiric abilities, as well as lose any Disease & Gene you might have."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_FRENZY|BP_AM_COSTLESS_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY
	bloodcost = 10
	cooldown = 5 SECONDS
	constant_bloodcost = 0.1

/datum/action/cooldown/bloodsucker/masquerade/ActivatePower()
	. = ..()
	var/mob/living/carbon/user = owner
	to_chat(user, span_notice("Your heart beats falsely within your lifeless chest. You may yet pass for a mortal."))
	to_chat(user, span_warning("Your vampiric healing is halted while imitating life."))

	// Remove Bloodsucker traits
	REMOVE_TRAIT(user, TRAIT_NOHARDCRIT, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_NOSOFTCRIT, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_VIRUSIMMUNE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_RADIMMUNE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_TOXIMMUNE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_COLDBLOODED, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_RESISTCOLD, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_NOPULSE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_NOBREATH, BLOODSUCKER_TRAIT)
	// Falsifies Health & Genetic Analyzers
	ADD_TRAIT(user, TRAIT_MASQUERADE, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_GENELESS, BLOODSUCKER_TRAIT)
	// Organs
	var/obj/item/organ/internal/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
	eyes.flash_protect = initial(eyes.flash_protect)
	var/obj/item/organ/internal/heart/vampheart/vampheart = user.getorganslot(ORGAN_SLOT_HEART)
	if(istype(vampheart))
		vampheart.FakeStart()
	user.apply_status_effect(STATUS_EFFECT_MASQUERADE)

/datum/action/cooldown/bloodsucker/masquerade/DeactivatePower()
	. = ..() // activate = FALSE
	var/mob/living/carbon/user = owner
	user.remove_status_effect(STATUS_EFFECT_MASQUERADE)
	ADD_TRAIT(user, TRAIT_NOHARDCRIT, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_NOSOFTCRIT, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_VIRUSIMMUNE, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_RADIMMUNE, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_TOXIMMUNE, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_COLDBLOODED, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_RESISTCOLD, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_SLEEPIMMUNE, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_NOPULSE, BLOODSUCKER_TRAIT)
	ADD_TRAIT(user, TRAIT_NOBREATH, BLOODSUCKER_TRAIT)
	REMOVE_TRAIT(user, TRAIT_MASQUERADE, BLOODSUCKER_TRAIT)
	// Remove genes, then make unable to get new ones.
	user.dna.remove_all_mutations()
	ADD_TRAIT(user, TRAIT_GENELESS, BLOODSUCKER_TRAIT)
	// Organs
	var/obj/item/organ/internal/heart/vampheart/vampheart = user.getorganslot(ORGAN_SLOT_HEART)
	if(istype(vampheart))
		vampheart.Stop()
	var/obj/item/organ/internal/eyes/eyes = user.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		eyes.flash_protect = max(initial(eyes.flash_protect) - 1, - 1)
	// Remove all diseases
	for(var/thing in user.diseases)
		var/datum/disease/disease = thing
		disease.cure()
	to_chat(user, span_notice("Your heart beats one final time, while your skin dries out and your icy pallor returns."))

/**
 * # Status effect
 *
 * This is what the Masquerade power gives, handles their bonuses and gives them a neat icon to tell them they're on Masquerade.
 */

/datum/status_effect/masquerade
	id = "masquerade"
	duration = -1
	tick_interval = -1
	alert_type = /atom/movable/screen/alert/status_effect/masquerade

/atom/movable/screen/alert/status_effect/masquerade
	name = "Masquerade"
	desc = "You are currently hiding your identity using the Masquerade power. This halts Vampiric healing."
	icon = 'icons/mob/actions/actions_bloodsucker.dmi'
	icon_state = "power_human"

/atom/movable/screen/alert/status_effect/masquerade/MouseEntered(location,control,params)
	desc = initial(desc)
	return ..()
