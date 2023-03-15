/obj/item/organ/ears/fox
	name = "fox ears"
	icon = 'monkestation/icons/obj/device.dmi'
	icon_state = "fox"
	bang_protect = -2

/obj/item/organ/ears/fox/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	if(istype(H))
		H.dna.species.mutant_bodyparts |= "ears"
		H.dna.features["ears"] = "Fox"
		H.update_body()

/obj/item/organ/ears/fox/Remove(mob/living/carbon/human/H,  special = 0)
	..()
	if(istype(H))
		H.dna.features["ears"] = "None"
		H.dna.species.mutant_bodyparts -= "ears"
		H.update_body()


