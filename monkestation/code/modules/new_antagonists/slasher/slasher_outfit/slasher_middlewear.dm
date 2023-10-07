/obj/item/clothing/suit/apron/slasher
	name = "butcher's apron"
	desc = "A brown butcher's apron, you can feel an aura of something dark radiating off of it."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	icon_state = "slasher"
	inhand_icon_state = null

/obj/item/clothing/suit/apron/slasher/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "slasher")

/obj/item/clothing/under/color/random/slasher
	name = "butcher's jumpsuit"
	clothing_traits = list(TRAIT_NODROP)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

