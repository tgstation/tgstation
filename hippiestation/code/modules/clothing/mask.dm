/obj/item/clothing/mask/hippie/cluwne
	name = "clown wig and mask"
	desc = "A true prankster's facial attire. A clown is incomplete without his wig and mask."
	flags_cover = MASKCOVERSEYES
	icon_state = "cluwne"
	item_state = "cluwne"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	flags_1 = NODROP_1 | MASKINTERNALS_1 | DROPDEL_1
	flags_inv = HIDEEARS|HIDEEYES

/obj/item/clothing/mask/hippie/cluwne/equipped(mob/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_wear_mask)
		var/mob/living/carbon/human/H = user
		H.dna.add_mutation(CLUWNEMUT)
	return