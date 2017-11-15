/obj/item/clothing/gloves/fingerless/rapid
	name = "Gloves of the north star"
	desc = "Just looking at these fills you with an urge to beat the shit out of people."

/obj/item/clothing/gloves/fingerless/rapid/Touch(mob/living/target,proximity = TRUE)
	var/mob/living/M = loc

	if(M.a_intent == INTENT_HARM)
		M.changeNext_move(CLICK_CD_RAPID)
	.= FALSE