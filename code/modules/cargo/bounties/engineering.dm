/datum/bounty/item/engineering/gas
	name = "Full Tank of Pluoxium"
	description = "CentCom RnD is researching extra compact internals. Ship us a tank full of Pluoxium and you'll be compensated."
	reward = CARGO_CRATE_VALUE * 15
	wanted_types = list(/obj/item/tank)
	var/moles_required = 20 // A full tank is 28 moles, but CentCom ignores that fact.
	var/gas_type = /datum/gas/pluoxium

/datum/bounty/item/engineering/gas/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/item/tank/T = O
	var/datum/gas_mixture/our_mix = T.return_air()
	if(!our_mix.gases[gas_type])
		return FALSE
	return our_mix.gases[gas_type][MOLES] >= moles_required

/datum/bounty/item/engineering/gas/nitrium_tank
	name = "Full Tank of Nitrium"
	description = "The non-human staff of Station 88 has been volunteered to test performance enhancing drugs. Ship them a tank full of Nitrium so they can get started. (20 Moles)"
	gas_type = /datum/gas/nitrium

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

/datum/bounty/item/engineering/gas/zauker_tank
	name = "Full Tank of Zauker"
	description = "The main planet of \[REDACTED] has been chosen as testing grounds for the new weapon that uses Zauker gas. Ship us a tank full of it. (20 Moles)"
	reward = CARGO_CRATE_VALUE * 20
	gas_type = /datum/gas/zauker

/datum/bounty/item/engineering/emitter
	name = "Emitter"
	description = "We think there may be a defect in your station's emitter designs, based on the sheer number of delaminations your sector seems to see. Ship us one of yours."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/machinery/power/emitter)

/datum/bounty/item/engineering/hydro_tray
	name = "Hydroponics Tray"
	description = "The lab technicians are trying to figure out how to lower the power drain of hydroponics trays, but we fried our last one. Mind building one for us?"
	reward = CARGO_CRATE_VALUE * 4
	wanted_types = list(/obj/machinery/hydroponics/constructable)
