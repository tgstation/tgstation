/obj/item/tank/suicide_act(mob/user)
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='suicide'>[user] is putting [src]'s valve to [user.p_their()] lips! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/effects/spray.ogg', 10, 1, -3)
	if (!QDELETED(H))
		for(var/obj/item/W in H)
			H.dropItemToGround(W)
			if(prob(50))
				step(W, pick(GLOB.alldirs))
		H.status_flags |= DISFIGURED
		H.bleed_rate = 5
		H.gib_animation()
		sleep(3)
		H.adjustBruteLoss(1000) //to make the body super-bloody
		H.spawn_gibs()
		H.spill_organs()
		H.spread_bodyparts()

	return (BRUTELOSS)
