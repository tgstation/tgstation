/obj/effect/spawner/random/vending
	name = "machinery spawner"
	desc = "Randomized electronics for extra fun."
	var/hacked = FALSE //whether it hacks the vendor on spawn (only used for mapedits)

/obj/effect/spawner/random/vending/Initialize(mapload)
	. = ..()
	if(istype(., /obj/machinery/vending))
		var/obj/machinery/vending/vending = .
		vending.extended_inventory = hacked

	return INITIALIZE_HINT_QDEL

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
