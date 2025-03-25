/// Quartic Reliquary board
/obj/item/circuitboard/machine/quartic_reliquary
	name = "Quartic Reliquary"
	greyscale_colors = CIRCUIT_COLOR_SCIENCE
	build_path = /obj/machinery/quartic_reliquary
	req_components = list(
		/datum/stock_part/servo = 3,
		/datum/stock_part/scanning_module = 3,
		/obj/item/stack/sheet/cardboard = 9)

/// The Quartic Reliquary takes in 3 cubes of the same rarity and outputs one cube a rarity higher.
/obj/machinery/quartic_reliquary
	name = "quartic reliquary"
	desc = "A machine capable of utilizing 4th dimensional mathematical formulas to fold some 3rd dimensional objects into higher quality ones."
	icon = 'icons/obj/cubes.dmi'
	base_icon_state = "quartic_reliquary"
	icon_state = "quartic_reliquary"
	density = TRUE
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION
	circuit = /obj/item/circuitboard/machine/quartic_reliquary
	/// Reference for the possible items we'll get when we create a new cube. Common is there just in case someone SOMEHOW combines something with 0 rarity
	var/static/list/all_possible_cube_returns = list(
		GLOB.common_cubes,
		GLOB.uncommon_cubes,
		GLOB.rare_cubes,
		GLOB.epic_cubes,
		GLOB.legendary_cubes,
		GLOB.mythical_cubes,
		)
	/// The speed at which we upgrade our cube. Affected by servos.
	var/upgrade_speed = 10 SECONDS
	/// The added chance to get a cube 1 stage higher than we were going for. Affected by scanners.
	var/bonus_chance = 0

/obj/machinery/quartic_reliquary/RefreshParts()
	. = ..()
	var/new_bonus_chance = 0
	for(var/datum/stock_part/scanning_module/new_scanner in component_parts)
		new_bonus_chance += new_scanner.tier
	bonus_chance = new_bonus_chance

	var/upgrade_speed_mod = 1
	for(var/datum/stock_part/servo/new_servo in component_parts)
		upgrade_speed_mod += new_servo.tier
	upgrade_speed = round(30 SECONDS / upgrade_speed_mod)
