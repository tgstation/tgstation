/datum/action/changeling/regenerate
	name = "Regenerate"
	desc = "Allows us to regrow and restore missing external limbs and vital internal organs, as well as curing all wounds (not to be confused with damage), removing shrapnel, and restoring blood volume. Costs 10 chemicals."
	helptext = "Will alert nearby crew if any external limbs are regenerated. Can be used while unconscious."
	button_icon_state = "regenerate"
	chemical_cost = 10
	dna_cost = 0
	req_stat = HARD_CRIT

/datum/action/changeling/regenerate/sting_action(mob/living/user)
	..()
	to_chat(user, "<span class='notice'>You feel an itching, both inside and \
		outside as your tissues knit and reknit.</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/list/missing = C.get_missing_limbs()
		if(missing.len)
			playsound(user, 'sound/magic/demon_consume.ogg', 50, TRUE)
			C.visible_message("<span class='warning'>[user]'s missing limbs \
				reform, making a loud, grotesque sound!</span>",
				"<span class='userdanger'>Your limbs regrow, making a \
				loud, crunchy sound and giving you great pain!</span>",
				"<span class='hear'>You hear organic matter ripping \
				and tearing!</span>")
			C.emote("scream")
			C.regenerate_limbs(1)
		if(!user.getorganslot(ORGAN_SLOT_BRAIN))
			var/obj/item/organ/brain/B
			if(C.has_dna() && C.dna.species.mutantbrain)
				B = new C.dna.species.mutantbrain()
			else
				B = new()
			B.organ_flags &= ~ORGAN_VITAL
			B.decoy_override = TRUE
			B.Insert(C)
		C.regenerate_organs()
		for(var/organ in C.internal_organs)
			var/obj/item/organ/O = organ
			O.setOrganDamage(0) //this heals brain damage too!
		var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
		if(istype(ears))
			ears.deaf = 0 //because deafness isn't cured by just healing ear damage
		C.set_blindness(0)
		C.set_blurriness(0)
		C.cure_all_traumas(TRAUMA_RESILIENCE_LOBOTOMY)
		for(var/i in C.all_wounds)
			var/datum/wound/iter_wound = i
			iter_wound.remove_wound()
		C.restore_blood()
		C.remove_all_embedded_objects()
	return TRUE
