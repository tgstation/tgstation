/datum/supply_pack/costumes_toys/recreation
	name = "Recreational Crate"
	desc = "For the times the Captain calls for mandatory fun."
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/item/toy/basketball = 2,
					/obj/item/melee/skateboard/pro = 2,
					/obj/item/clothing/shoes/sneakers/red = 2)
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/costumes_toys/maid
	name = "Classy Sanitation Pack"
	desc = "We are surprised there is a market for these, considering your station's cleanliness record."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/clothing/head/costume/maidheadband = 3,
					/obj/item/clothing/under/costume/maid = 3,
					/obj/item/clothing/accessory/maidapron = 3,
					/obj/item/reagent_containers/spray/cleaner = 2,
					/obj/item/reagent_containers/cup/rag = 2)
	crate_name = "Maid Uniforms"
