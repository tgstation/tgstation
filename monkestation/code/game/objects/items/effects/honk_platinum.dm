/obj/item/effect_granter/honk_platinum
	name = "Honk Platinum Transformation"
	icon_state = "honk_platinum"


/obj/item/effect_granter/honk_platinum/grant_effect(mob/living/carbon/granter)
	var/mob/living/basic/parrot/honk_platinum/new_honk = new(granter.loc)
	new_honk.mind_initialize()

	var/datum/mind/granters_mind = granter.mind

	granters_mind.transfer_to(new_honk)
	new_honk.adjust_hand_count(2)
	qdel(granter)

	. = ..()
