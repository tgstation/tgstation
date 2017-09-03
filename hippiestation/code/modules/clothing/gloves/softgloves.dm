/obj/item/clothing/gloves/color/white/soft
	name = "soft gloves"
	desc = "These gloves are very soft and feel nice to touch."

/datum/species/help(mob/living/carbon/human/user, mob/living/carbon/human/target)
	if(user.gloves && istype(user.gloves, /obj/item/clothing/gloves/color/white/soft))
		if(target.a_intent != INTENT_HELP)
			target.a_intent = INTENT_HELP
			target.hud_used.action_intent.icon_state = "[target.a_intent]" //Else we get your intent being one thing and your hud another.
			target.visible_message("<span class='notice'>[user] gives [target] a hug, they look happier!</span>", \
									"<span class='warning'>[user] hugs you and you feel a bit nicer.</span>")
			playsound(target, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		else
			..() // If they have help intent carry on as normal
	else
		..() // If you are not wearing soft gloves carry on as normal