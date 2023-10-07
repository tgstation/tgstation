/datum/supply_pack/service/glassware
	name = "Glassware Crate"
	desc = "Printing too much trouble? Buy our bulk glassware package today!"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/storage/box/beakers,
					/obj/item/storage/box/drinkingglasses = 2,
					/obj/item/reagent_containers/cup/glass/shaker,
					/obj/item/reagent_containers/cup/glass/flask = 2)
	crate_name = "glassware crate"

/datum/supply_pack/service/janitor/janicart
	name = "Janicart Crate"
	desc = "You'd better not have wrecked the last one joyriding."
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/vehicle/ridden/janicart,
					/obj/item/key/janitor)
	crate_name = "janicart crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/service/birthday
	name = "Birthday Bash Pack"
	desc = "This is for that corgi, isn't it..."
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/toy/balloon = 5,
					/obj/item/reagent_containers/spray/chemsprayer/party = 3,
					/obj/item/clothing/head/costume/party = 5,
					/obj/item/food/cake/birthday,
					/obj/item/plate/small = 5,
					/obj/item/a_gift/anything)
	crate_name = "Birthday Crate"
