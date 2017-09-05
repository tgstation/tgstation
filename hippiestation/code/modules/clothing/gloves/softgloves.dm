/obj/item/clothing/gloves/color/white/soft
	name = "soft gloves"
	desc = "These gloves are very soft and feel nice to touch."

/obj/item/clothing/gloves/color/white/soft/Touch(mob/living/carbon/human/target,proximity = 1)
	var/mob/M = loc
	if(ishuman(target))
		if(M.a_intent == INTENT_HELP && target.a_intent != INTENT_HELP)
			target.a_intent_change(INTENT_HELP)
			if(!emagged)
				target.visible_message("<span class='notice'>[M] gives [target] a hug, they look happier!</span>", \
									"<span class='warning'>[M] hugs you and you feel a bit nicer.</span>")
				playsound(target, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			else
				to_chat(M, "<span class='notice'>You hug [target] so gently they hardly feel it, they still look happier.</span>")
			.= TRUE
		else .= FALSE
	else
		.= FALSE

/obj/item/clothing/gloves/color/white/soft/emag_act(mob/user)
	if(!emagged)
		to_chat(user,"<span class='warning'>The electrostatic charge in the card somehow makes the gloves even softer!</span>")
		emagged = TRUE
