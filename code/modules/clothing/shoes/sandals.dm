/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	inhand_icon_state = "wizshoe"
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT * 0.5)
	resistance_flags = FLAMMABLE
	strip_delay = 0.5 SECONDS
	equip_delay_other = 5 SECONDS
	armor_type = /datum/armor/shoes_sandal
	fastening_type = SHOES_SLIPON
	species_exception = list(/datum/species/golem)

	lace_time = 3 SECONDS

/obj/item/clothing/shoes/sandal/alt
	desc = "A pair of shiny black wooden sandals."
	name = "black sandals"
	icon_state = "blacksandals"
	inhand_icon_state = "blacksandals"

/datum/armor/shoes_sandal
	bio = 10

/obj/item/clothing/shoes/sandal/magic
	name = "magical sandals"
	desc = "A pair of sandals imbued with magic."
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/shoes/sandal/beach
	name = "flip-flops"
	desc = "A very fashionable pair of flip-flops."

/obj/item/clothing/shoes/sandal/velcro
	name = "velcro sandals"
	desc = "A pair of wooden sandals that have been 'upgraded' with velcro straps in order to comply with corporate uniform policy."
	fastening_type = SHOES_VELCRO

/obj/item/clothing/shoes/sandal/alt/velcro
	name = "black velcro sandals"
	desc = "A pair of shiny black sandals that have been 'upgraded' with velcro straps in order to comply with corporate uniform policy."
	fastening_type = SHOES_VELCRO
