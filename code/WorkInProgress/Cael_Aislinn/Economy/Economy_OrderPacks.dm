//Similar to supply_packs

/datum/trade_goods
	var/group_name = "Uncategorised"
	var/list/contains = list()
	var/group = DEFAULT
	var/containertype = null

/datum/trade_goods/administrative
	name = "Administrative"
	group = ADMINISTRATIVE
	contains = list(
					)

/datum/trade_goods/clothing
	name = "Clothing"
	group = CLOTHING
					/obj/item/clothing/tie/blue,
					/obj/item/clothing/tie/red,
					/obj/item/clothing/tie/horrible,
					)
	cost = 10
	containertype = /obj/structure/closet
	New()
		for(var/new_type in typesof(/obj/item/clothing/tie/armband))
			contains.Add(new_type
		..()

/datum/trade_goods/clothing/suits
	name = "Overclothes"
	contains = list(/obj/item/clothing/suit/apron,
					/obj/item/clothing/suit/overalls,
					/obj/item/clothing/suit/storage/lawyer/bluejacket,
					/obj/item/clothing/suit/storage/lawyer/purpjacket,
					/obj/item/clothing/suit/storage/hazardvest,
					/obj/item/clothing/suit/storage/labcoat,
					/obj/item/clothing/suit/storage/det_suit,
					/obj/item/clothing/suit/wcoat,
					/obj/item/clothing/suit/chef,
					/obj/item/clothing/suit/chef/classic)

/datum/trade_goods/clothing/under
	name = "Jumpsuits"
	contains = list(/obj/item/clothing/under/aqua,
					/obj/item/clothing/under/blackskirt,
					/obj/item/clothing/under/darkblue,
					/obj/item/clothing/under/darkred,
					/obj/item/clothing/under/det,
					/obj/item/clothing/under/librarian,
					/obj/item/clothing/under/lightblue,
					/obj/item/clothing/under/lightbrown,
					/obj/item/clothing/under/lightgreen,
					/obj/item/clothing/under/lightpurple,
					/obj/item/clothing/under/lightred,
					/obj/item/clothing/under/overalls,
					/obj/item/clothing/under/pj/blue,
					/obj/item/clothing/under/pj/red,
					/obj/item/clothing/under/purple,
					/obj/item/clothing/under/yellowgreen,
					/obj/item/clothing/under/sundress,
					/obj/item/clothing/under/waiter)
	New()
		for(var/new_type in typesof(/obj/item/clothing/under/color) - /obj/item/clothing/under/color)
			contains.Add(new_type
		for(var/new_type in typesof(/obj/item/clothing/under/rank) - /obj/item/clothing/under/color)
			contains.Add(new_type
		for(var/new_type in typesof(/obj/item/clothing/under/lawyer) - /obj/item/clothing/under/lawyer)
			contains.Add(new_type
		for(var/new_type in typesof(/obj/item/clothing/under/suit_jacket))
			contains.Add(new_type

/datum/trade_goods/clothing/shoes
	name = "Shoes"
	contains = list(/obj/item/clothing/shoes/black,
					/obj/item/clothing/shoes/brown,
					/obj/item/clothing/shoes/green,
					/obj/item/clothing/shoes/orange,
					/obj/item/clothing/shoes/purple,
					/obj/item/clothing/shoes/red,
					/obj/item/clothing/shoes/sandal,
					/obj/item/clothing/shoes/slippers,
					/obj/item/clothing/shoes/white,
					/obj/item/clothing/shoes/yellow,
					/obj/item/clothing/shoes/blue)

/*
/datum/trade_goods/SECURITY
	name = "Security"
	group = SECURITY
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate

/datum/trade_goods/SPECIAL_SECURITY
	name = "Administrative"
	group = SPECIAL_SECURITY
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate

/datum/trade_goods/FOOD
	name = "Food"
	group = FOOD
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate

/datum/trade_goods/ANIMALS
	name = "Animals"
	group = ANIMALS
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate

/datum/trade_goods/MINERALS
	name = "Minerals"
	group = MINERALS
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate

/datum/trade_goods/EMERGENCY
	name = "Emergency"
	group = EMERGENCY
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate

/datum/trade_goods/GAS
	name = "Gas"
	group = GAS
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate

/datum/trade_goods/MAINTENANCE
	name = "Maintenance"
	group = MAINTENANCE
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate

/datum/trade_goods/electrical
	name = "Electrical"
	group = ELECTRICAL
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate

/datum/trade_goods/ROBOTICS
	name = "Robotics"
	group = ROBOTICS
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate

/datum/trade_goods/BIOMEDICAL
	name = "Biomedical"
	group = BIOMEDICAL
	contains = list(
					)
	cost = 10
	containertype = /obj/structure/closet/crate
*/