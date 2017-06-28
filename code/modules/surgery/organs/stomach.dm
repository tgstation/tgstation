/obj/item/organ/stomach
	name = "stomach"
	icon_state = "stomach"
	origin_tech = "biotech=4"
	w_class = WEIGHT_CLASS_NORMAL
	zone = "chest"
	slot = "stomach"
	attack_verb = list("gored", "squished", "slapped")
	desc = "Onaka ga suite imasu."

/obj/item/organ/stomach/on_life()
	var/mob/living/carbon/C = owner

	if(iscarbon(C))
		if(ishuman(C))
			C.dna.species.handle_digestion(C)