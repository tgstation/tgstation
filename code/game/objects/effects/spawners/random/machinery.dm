/obj/effect/spawner/random/machinery
	name = "machinery spawner"
	desc = "Randomized electronics for extra fun."

/obj/effect/spawner/random/machinery/snackvend
	name = "spawn random snack vending machine"
	desc = "Automagically transforms into a random snack vendor. If you see this while in a shift, please create a bug report."
	icon_state = "snack"
	loot_type_path = /obj/machinery/vending/snack
	loot = list()

/obj/effect/spawner/random/machinery/colavend
	name = "spawn random cola vending machine"
	desc = "Automagically transforms into a random cola vendor. If you see this while in a shift, please create a bug report."
	icon_state = "cola"
	loot_type_path = /obj/machinery/vending/cola
	loot = list()

/obj/effect/spawner/random/machinery/arcade
	name = "spawn random arcade machine"
	desc = "Automagically transforms into a random arcade machine. If you see this while in a shift, please create a bug report."
	icon_state = "arcade"
	loot = list(
		/obj/machinery/computer/arcade/orion_trail = 49,
		/obj/machinery/computer/arcade/battle = 49,
		/obj/machinery/computer/arcade/amputation = 2,
	)
