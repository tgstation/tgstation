/datum/bounty/item/engineering/gas
	name = "Full Tank of Pluoxium"
	description = "CentCom RnD is researching extra compact internals. Ship us a tank full of Pluoxium and you'll be compensated."
	reward = 7500
	wanted_types = list(/obj/item/tank)
	var/moles_required = 20 // A full tank is 28 moles, but CentCom ignores that fact.
	var/gas_type = /datum/gas/pluoxium

/datum/bounty/item/engineering/gas/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/item/tank/T = O
	if(!T.air_contents.gases[gas_type])
		return FALSE
	return T.air_contents.gases[gas_type][MOLES] >= moles_required

/datum/bounty/item/engineering/gas/nitryl_tank
	name = "Full Tank of Nitryl"
	description = "The non-human staff of Station 88 has been volunteered to test performance enhancing drugs. Ship them a tank full of Nitryl so they can get started. (20 Moles)"
	gas_type = /datum/gas/nitryl

/datum/bounty/item/engineering/gas/freon_tank
	name = "Full Tank of Freon"
	description = "The Supermatter of station 33 has started the delamination process. Deliver a tank of Freon gas to help them stop it! (20 Moles)"
	gas_type = /datum/gas/freon

/datum/bounty/item/engineering/gas/tritium_tank
	name = "Full Tank of Tritium"
	description = "Station 49 is looking to kickstart their research program. Ship them a tank full of Tritium. (20 Moles)"
	gas_type = /datum/gas/tritium

/datum/bounty/item/engineering/gas/hydrogen_tank
	name = "Full Tank of Hydrogen"
	description = "Our R&D department is working on the development of more efficient electrical batteries using hydrogen as a catalyst. Ship us a tank full of it. (20 Moles)"
	gas_type = /datum/gas/hydrogen

/datum/bounty/item/engineering/energy_ball
	name = "Contained Tesla Ball"
	description = "Station 24 is being overrun by hordes of angry Mothpeople. They are requesting the ultimate bug zapper."
	reward = 75000 //requires 14k credits of purchases, not to mention cooperation with engineering/heads of staff to set up inside the cramped shuttle
	wanted_types = list(/obj/singularity/energy_ball)

/datum/bounty/item/engineering/energy_ball/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/singularity/energy_ball/T = O
	return !T.miniball

/datum/bounty/item/engineering/emitter
	name = "Emitter"
	description = "We think there may be a defect in your station's emitter designs, based on the sheer number of delaminations your sector seems to see. Ship us one of yours."
	reward = 2500
	wanted_types = list(/obj/machinery/power/emitter)

/datum/bounty/item/engineering/hydro_tray
	name = "Hydroponics Tray"
	description = "The lab technicians are trying to figure out how to lower the power drain of hydroponics trays, but we fried our last one. Mind building one for us?"
	reward = 2000
	wanted_types = list(/obj/machinery/hydroponics/constructable)
