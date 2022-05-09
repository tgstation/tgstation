/datum/bounty/item/atmospherics
	name = "Gas Parent"
	description = "Shit's broken if you see this."
	reward = CARGO_CRATE_VALUE * 15
	wanted_types = list(/obj/item/tank = TRUE)
	/// How many moles are needed to fufill the bounty?
	var/moles_required = 20
	/// Typepath of the gas datum required to fufill the bounty
	var/gas_type

/datum/bounty/item/atmospherics/applies_to(obj/applied_obj)
	if(!..())
		return FALSE
	var/obj/item/tank/applied_tank = applied_obj
	var/datum/gas_mixture/our_mix = applied_tank.return_air()
	if(!our_mix.gases[gas_type])
		return FALSE
	return our_mix.gases[gas_type][MOLES] >= moles_required

/datum/bounty/item/atmospherics/pluox_tank
	name = "Full Tank of Pluoxium"
	description = "CentCom RnD is researching extra compact internals. Ship us a tank full of Pluoxium and you'll be compensated. (20 Moles)"
	gas_type = /datum/gas/pluoxium

/datum/bounty/item/atmospherics/nitrium_tank
	name = "Full Tank of Nitrium"
	description = "The non-human staff of Station 88 has been volunteered to test performance enhancing drugs. Ship them a tank full of Nitrium so they can get started. (20 Moles)"
	gas_type = /datum/gas/nitrium

/datum/bounty/item/atmospherics/freon_tank
	name = "Full Tank of Freon"
	description = "The Supermatter of station 33 has started the delamination process. Deliver a tank of Freon gas to help them stop it! (20 Moles)"
	gas_type = /datum/gas/freon

/datum/bounty/item/atmospherics/tritium_tank
	name = "Full Tank of Tritium"
	description = "Station 49 is looking to kickstart their research program. Ship them a tank full of Tritium. (20 Moles)"
	gas_type = /datum/gas/tritium

/datum/bounty/item/atmospherics/hydrogen_tank
	name = "Full Tank of Hydrogen"
	description = "Our R&D department is working on the development of more efficient electrical batteries using hydrogen as a catalyst. Ship us a tank full of it. (20 Moles)"
	gas_type = /datum/gas/hydrogen

/datum/bounty/item/atmospherics/zauker_tank
	name = "Full Tank of Zauker"
	description = "The main planet of \[REDACTED] has been chosen as testing grounds for the new weapon that uses Zauker gas. Ship us a tank full of it. (20 Moles)"
	reward = CARGO_CRATE_VALUE * 20
	gas_type = /datum/gas/zauker
