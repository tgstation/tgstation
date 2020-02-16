/obj/machinery/sheetifier
	name = "Sheet-meister 2000"
	desc = "A very sheety machine"
	icon_state = "autolathe"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 10
	active_power_usage = 100
	circuit = /obj/item/circuitboard/machine/sheetifier
	layer = BELOW_OBJ_LAYER

/obj/machinery/sheetifier/Initialize()
	. = ..()
	AddComponent(/datum/component/material_container, list(/datum/material/meat), MINERAL_MATERIAL_AMOUNT * MAX_STACK_SIZE * 2, TRUE,
	/obj/item/reagent_containers/food/snacks/meat/slab)

/obj/machinery/sheetifier/attack_hand(mob/user)
	. = ..()
	var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
	materials.retrieve_all() //Returns all as sheets
