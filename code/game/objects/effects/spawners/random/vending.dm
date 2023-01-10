/obj/effect/spawner/random/vending
	name = "machinery spawner"
	desc = "Randomized electronics for extra fun."
	/// whether it hacks the vendor on spawn (only used for mapedits)
	var/hacked = FALSE

/obj/effect/spawner/random/vending/make_item(spawn_loc, type_path_to_make)
	var/obj/machinery/vending/vending = ..()
	if(istype(vending))
		vending.extended_inventory = hacked

	return vending

/obj/effect/spawner/random/vending/snackvend
	name = "spawn random snack vending machine"
	desc = "Automagically transforms into a random snack vendor. If you see this while in a shift, please create a bug report."
	icon_state = "snack"
	loot_type_path = /obj/machinery/vending/snack
	loot = list()

/obj/effect/spawner/random/vending/colavend
	name = "spawn random cola vending machine"
	desc = "Automagically transforms into a random cola vendor. If you see this while in a shift, please create a bug report."
	icon_state = "cola"
	loot_type_path = /obj/machinery/vending/cola
	loot = list()
