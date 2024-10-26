// code/modules/cargo/packs/imports.dm
/datum/supply_pack/imports/sovietvehicle
	name = "Soviet Vehicle Exports"
	desc = "The most affordable vehicle in the entire galaxy. \
		Comes with tools and something else."
	contraband = TRUE
	cost = 666666 // devil creature for devil price, not because model number is "6"
	contains = list(
		/obj/item/food/semki = 6,
		/obj/item/storage/toolbox/mechanical,
		/obj/item/reagent_containers/cup/glass/bottle/vodka = 6,
		/mob/living/basic/bear/russian = 6, // protection class "6"
		/obj/vehicle/sealed/car/cheburek
	)
	crate_name = "Top Secret"
	crate_type = /obj/structure/closet/crate/large/soviet
