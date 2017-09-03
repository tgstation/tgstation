/obj/item/clothing/gloves/color/white/soft
	name = "soft gloves"
	desc = "These gloves are very soft and feel nice to touch."

/obj/item/clothing/gloves/color/white/soft/Touch(mob/living/carbon/human/target,proximity)
	var/mob/M = loc
	if(ishuman(target))
		if(M.a_intent == INTENT_HELP && target.a_intent != INTENT_HELP)
			target.a_intent = INTENT_HELP
			target.hud_used.action_intent.icon_state = "[target.a_intent]" //Else we get your intent being one thing and your hud another.
			target.visible_message("<span class='notice'>[M] gives [target] a hug, they look happier!</span>", \
									"<span class='warning'>[M] hugs you and you feel a bit nicer.</span>")
			playsound(target, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			.= TRUE
		else .= FALSE
	else
		.= FALSE