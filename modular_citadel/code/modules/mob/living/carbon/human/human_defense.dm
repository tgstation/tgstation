/mob/living/carbon/human/grabbedby(mob/living/carbon/user, supress_message = 0)
	if(user == src && pulling && !pulling.anchored && grab_state >= GRAB_AGGRESSIVE && isliving(pulling))
		vore_attack(user, pulling)
	else
		..()

/mob/living/carbon/human/alt_attack_hand(mob/user)
	if(..())
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!dna.species.alt_spec_attack_hand(H, src))
			dna.species.spec_attack_hand(H, src)
		return TRUE
