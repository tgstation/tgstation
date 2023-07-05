/obj/item/clothing/under/rank/civilian/cluwne
	name = "clown suit"
	desc = "<i>'HONK!'</i>"
	icon_state = "greenclown"
	inhand_icon_state = "greenclown"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	item_flags = DROPDEL
	can_adjust = FALSE

/obj/item/clothing/under/rank/civilian/cluwne/Initialize(mapload)
	.=..()
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type))

/obj/item/clothing/under/rank/civilian/cluwne/equipped(mob/living/carbon/user, slot)
	if(!user.has_dna())
		return ..()
	if(slot == ITEM_SLOT_ICLOTHING)
		var/mob/living/carbon/player = user
		player.dna.add_mutation(/datum/mutation/human/cluwne)
	return ..()
