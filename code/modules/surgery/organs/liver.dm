/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	origin_tech = "biotech=5"
	w_class = WEIGHT_CLASS_NORMAL
	zone = "chest"
	slot = "liver"
	desc = "Goes great with a nice chianti and some fava beans."

/obj/item/organ/liver/on_life()
	var/mob/living/carbon/C = owner

	if(iscarbon(C))
		if(C.reagents)
			C.reagents.metabolize(C, can_overdose=1)
