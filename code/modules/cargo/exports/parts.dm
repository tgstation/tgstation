// Circuit boards, spare parts, etc.

/datum/export/solar/assembly
	cost = 50
	unit_name = "solar panel assembly"
	export_types = list(/obj/item/solar_assembly)

/datum/export/solar/tracker_board
	cost = 100
	unit_name = "solar tracker board"
	export_types = list(/obj/item/weapon/electronics/tracker)

/datum/export/solar/control_board
	cost = 150
	unit_name = "solar panel control board"
	export_types = list(/obj/item/weapon/circuitboard/computer/solar_control)



/datum/export/swarmer
	cost = 2000
	unit_name = "deactivated alien deconstruction drone"
	export_types = list(/obj/item/device/unactivated_swarmer)

/datum/export/swarmer/applies_to(obj/O, contr = 0, emag = 0)
	if(!..())
		return FALSE

	var/obj/item/device/unactivated_swarmer/S = O
	if(!S.crit_fail)
		return FALSE
	return TRUE

/datum/export/fusion_cell
	cost = 500
	unit_name = "fusion cell"
	export_types = list(/obj/item/fusion_cell)

/datum/export/fusion_cell/get_cost(obj/O)
	var/obj/item/fusion_cell/F = O
	return ..() * F.rating