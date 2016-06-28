/mob/living/carbon/human/attack_hulk(mob/living/carbon/human/user)
	if(user.a_intent == "harm")
		..(user, 1)
		playsound(loc, user.dna.species.attack_sound, 25, 1, -1)
		var/hulk_verb = pick("smash","pummel")
		visible_message("<span class='danger'>[user] has [hulk_verb]ed [src]!</span>", \
								"<span class='userdanger'>[user] has [hulk_verb]ed [src]!</span>")
		adjustBruteLoss(15)
		return 1

/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M)
	if(..())	//to allow surgery to return properly.
		return
	dna.species.spec_attack_hand(M, src)
