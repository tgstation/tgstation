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

/datum/bounty/item/engineering/gas/zauker_tank
	name = "Full Tank of Zauker"
	description = "The main planet of \[REDACTED] has been chosen as testing grounds for the new weapon that uses Zauker gas. Ship us a tank full of it. (20 Moles)"
	reward = CARGO_CRATE_VALUE * 20
	gas_type = /datum/gas/zauker

/datum/bounty/item/engineering/energy_ball
	name = "Contained Tesla Ball"
	description = "Station 24 is being overrun by hordes of angry Mothpeople. They are requesting the ultimate bug zapper."
	reward = CARGO_CRATE_VALUE * 375
	wanted_types = list(/obj/singularity/energy_ball)

/datum/bounty/item/engineering/energy_ball/applies_to(obj/O)
	if(!..())
		return FALSE
	var/obj/singularity/energy_ball/T = O
	return !T.miniball

/datum/bounty/item/engineering/emitter
	name = "Emitter"
	description = "We think there may be a defect in your station's emitter designs, based on the sheer number of delaminations your sector seems to see. Ship us one of yours."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/machinery/power/emitter = TRUE)

/datum/bounty/item/engineering/hydro_tray
	name = "Hydroponics Tray"
	description = "The lab technicians are trying to figure out how to lower the power drain of hydroponics trays, but we fried our last one. Mind building one for us?"
	reward = CARGO_CRATE_VALUE * 4
	wanted_types = list(/obj/machinery/hydroponics/constructable = TRUE)

/datum/bounty/item/engineering/cyborg_charger
	name = "Recharging Station"
	description = "We don't have enough rechargers to fit all of our MODsuits. Ship us one of yours."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/machinery/recharge_station = TRUE)

/datum/bounty/item/engineering/smes_unit
	name = "Power Storage Unit"
	description = "We need to store more power. Get us a SMES unit."
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/obj/machinery/power/smes = TRUE)

/datum/bounty/item/engineering/pacman
	name = "P.A.C.M.A.N. Generator"
	description = "Our backup generator blew a fuse, we need a new one ASAP."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/machinery/power/port_gen/pacman = TRUE)

/datum/bounty/item/engineering/field_gen
	name = "Field Generator"
	description = "One of our protective generator's warranties has expired, we need a new one to replace it."
	reward = CARGO_CRATE_VALUE * 6
	wanted_types = list(/obj/machinery/field/generator = TRUE)

/datum/bounty/item/engineering/tesla_coil
	name = "Tesla Coil"
	description = "Our electricity bill is too high, get us a tesla coil to offset this."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/machinery/power/energy_accumulator/tesla_coil = TRUE)

/datum/bounty/item/engineering/welding_tank
	name = "Welding Fuel Tank"
	description = "We need more welding fuel for the engineering team, send us a tank."
	reward = CARGO_CRATE_VALUE * 5
	wanted_types = list(/obj/structure/reagent_dispensers/fueltank = TRUE)

/datum/bounty/item/engineering/reflector
	name = "Reflector"
	description = "We want to make our emitters take a longer route, get us a reflector to make this happen."
	reward = CARGO_CRATE_VALUE * 7
	wanted_types = list(/obj/structure/reflector = TRUE)
