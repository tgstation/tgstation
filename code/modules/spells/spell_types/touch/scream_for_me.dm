/// Weaker smite, not outright gibbing your target, but a lot more bloody, and Sanguine school, so doesn't get affected by splattercasting.
/datum/action/cooldown/spell/touch/scream_for_me
	name = "Scream For Me"
	desc = "This wicked spell inflicts many severe wounds on your target, causing them to \
		likely bleed to death unless they recieve immediate medical attention."
	button_icon_state = "scream_for_me"
	sound = null //trust me, you'll hear their wounds

	school = SCHOOL_SANGUINE
	invocation_type = INVOCATION_SHOUT
	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank = 10 SECONDS

	invocation = "SCREAM FOR ME!!"

	hand_path = /obj/item/melee/touch_attack/scream_for_me

/datum/action/cooldown/spell/touch/scream_for_me/on_antimagic_triggered(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)


	// Informs the wizard of the backfire
	to_chat(victim, span_warning("The feedback mutilates [caster]'s arm!"))
	to_chat(caster, span_userdanger("The spell bounces from [victim]'s skin back into your arm!"))

	var/list/wounds = list(
		WOUND_SEVERITY_TRIVIAL,
		WOUND_SEVERITY_MODERATE,
		WOUND_SEVERITY_SEVERE,
	)

	// Gets the holding hand of the touch attack.
	var/obj/item/bodypart/to_wound = caster.get_holding_bodypart_of_item(hand)

	// Wounds the bodypart severely.
	caster.cause_wound_of_type_and_severity(WOUND_SLASH, to_wound, pick(wounds))

/datum/action/cooldown/spell/touch/scream_for_me/cast_on_hand_hit(obj/item/melee/touch_attack/hand, mob/living/victim, mob/living/carbon/caster)
	// Is the victim a human.
	if(!ishuman(victim))
		// If the victim is not a human, show a warning.
		to_chat(caster, span_warning("The ancient powers refuse to wound non-humanesque animals."))
		return

	if(victim.stat == DEAD)
		// If the victim is dead, show a warning.
		to_chat(caster, span_warning("The ancient powers refuse to wound a dead animal."))
		return
	//If yes, get the mob/living/carbon/human.
	var/mob/living/carbon/human/human_victim = victim

	// Create a list of wound severity to pick from when causing a wound.
	var/list/wounds = list(
		WOUND_SEVERITY_MODERATE,
		WOUND_SEVERITY_SEVERE,
		WOUND_SEVERITY_CRITICAL,
	)
	// Loop through every body part in the human victim.
	for(var/obj/item/bodypart/bodypart as anything in human_victim.bodyparts)
		human_victim.cause_wound_of_type_and_severity(WOUND_SLASH, bodypart, pick(wounds))
	// Force a scream emote.
	human_victim.emote("screams")
	return TRUE

/obj/item/melee/touch_attack/scream_for_me
	name = "\improper bloody touch"
	desc = "Guaranteed to make your victims scream, or your money back!"
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "scream_for_me"
	inhand_icon_state = "disintegrate"
