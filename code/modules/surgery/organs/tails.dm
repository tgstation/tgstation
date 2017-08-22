/obj/item/organ/tail
	name = "tail"
	desc = "What did you cut this off of?"
	zone = "groin"
	slot = "tail"

/obj/item/organ/tail/cat
	name = "cat tail"
	desc = "Who's wagging now?"
	icon_state = "severedtail"

/obj/item/organ/tail/cat/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	color = H.hair_color
	H.dna.features["tail_human"] = "Cat"
	H.update_body()

/obj/item/organ/ears/cat/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	H.endTailWag()
	H.dna.features["tail_human"] = "None"
	color = H.hair_color
	H.update_body()
