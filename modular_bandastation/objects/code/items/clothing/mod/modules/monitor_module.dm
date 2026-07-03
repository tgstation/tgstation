/obj/item/mod/module/monitor
	name = "MOD crew monitor module"
	desc = "A module installed into the wrist of the suit, this presents a display of crew sensor data."
	icon_state = "scanner"
	module_type = MODULE_ACTIVE
	complexity = 1
	active_power_cost = DEFAULT_CHARGE_DRAIN * 0.3
	device = /obj/item/sensor_device
	incompatible_modules = list(/obj/item/mod/module/monitor)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_GLOVES)

/datum/design/module/mod_monitor
	name = "Crew Monitor Module"
	id = "mod_monitor"
	materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 0.75,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 1.5,
	)
	build_path = /obj/item/mod/module/monitor

/datum/techweb_node/medbay_equip/New()
	. = ..()
	design_ids += "mod_monitor"
