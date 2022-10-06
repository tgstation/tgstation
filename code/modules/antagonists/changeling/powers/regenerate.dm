/datum/action/changeling/regenerate
	name = "Regenerate"
	desc = "Allows us to regrow and restore missing external limbs and vital internal organs, as well as removing shrapnel, healing major wounds, and restoring blood volume. Costs 10 chemicals."
	helptext = "Will alert nearby crew if any external limbs are regenerated. Can be used while unconscious."
	button_icon_state = "regenerate"
	chemical_cost = 10
	dna_cost = 0
	req_stat = HARD_CRIT

/datum/action/changeling/regenerate/sting_action(mob/living/user)
	if(!iscarbon(user))
		to_chat(user, span_notice("You have nothing to regenerate in this state!"))
		return FALSE

	..()
	to_chat(user, span_notice("You feel an itching, both inside and outside as your tissues knit and reknit."))
	var/mob/living/carbon/carbon_user = user
	if(length(carbon_user.get_missing_limbs()))
		playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
		carbon_user.visible_message(
			span_warning("[user]'s missing limbs reform, making a loud, grotesque sound!"),
			span_userdanger("Your limbs regrow, making a loud, crunchy sound and giving you great pain!"),
			span_hear("You hear organic matter ripping and tearing!"),
		)

		carbon_user.emote("scream")

	carbon_user.fully_heal(HEAL_BODY)

	// Make sure the brain's nonvital
	// Shouldn't be necessary but you can never be certain with lingcode
	var/obj/item/organ/internal/brain/replacement_brain = user.getorganslot(ORGAN_SLOT_BRAIN)
	replacement_brain.organ_flags &= ~ORGAN_VITAL
	replacement_brain.decoy_override = TRUE

	return TRUE
