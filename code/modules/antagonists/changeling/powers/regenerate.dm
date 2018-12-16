/obj/effect/proc_holder/changeling/regenerate
	name = "Regenerate"
	desc = "Allows us to regrow and restore missing external limbs, and \
		vital internal organs, as well as removing shrapnel and restoring \
		blood volume."
	helptext = "Will alert nearby crew if any external limbs are \
		regenerated. Can be used while unconscious."
	chemical_cost = 10
	dna_cost = 0
	req_stat = UNCONSCIOUS

/obj/effect/proc_holder/changeling/regenerate/sting_action(mob/living/user)
	..()
	to_chat(user, "<span class='notice'>You feel an itching, both inside and \
		outside as your tissues knit and reknit.</span>")
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/list/missing = C.get_missing_limbs()
		if(missing.len)
			playsound(user, 'sound/magic/demon_consume.ogg', 50, 1)
			C.visible_message("<span class='warning'>[user]'s missing limbs \
				reform, making a loud, grotesque sound!</span>",
				"<span class='userdanger'>Your limbs regrow, making a \
				loud, crunchy sound and giving you great pain!</span>",
				"<span class='italics'>You hear organic matter ripping \
				and tearing!</span>")
			C.emote("scream")
			C.regenerate_limbs(1)
		if(!user.getorganslot(ORGAN_SLOT_BRAIN))
			var/obj/item/organ/brain/B
			if(C.has_dna() && C.dna.species.mutant_brain)
				B = new C.dna.species.mutant_brain()
			else
				B = new()
			B.vital = FALSE
			B.decoy_override = TRUE
			B.Insert(C)
		C.regenerate_organs()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.restore_blood()
		H.remove_all_embedded_objects()
	return TRUE
