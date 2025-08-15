/datum/export/large/crate
	cost = CARGO_CRATE_VALUE
	k_elasticity = 0
	unit_name = "crate"
	export_types = list(/obj/structure/closet/crate)
	exclude_types = list(
		/obj/structure/closet/crate/coffin,
		/obj/structure/closet/crate/large,
		/obj/structure/closet/crate/mail,
		/obj/structure/closet/crate/wooden,
		)

/datum/export/large/crate/total_printout(datum/export_report/ex, notes = TRUE) // That's why a goddamn metal crate costs that much.
	. = ..()
	if(. && notes)
		. += " Thanks for participating in Nanotrasen Crates Recycling Program."

/datum/export/large/crate/wooden
	cost = CARGO_CRATE_VALUE/5
	unit_name = "large wooden crate"
	export_types = list(/obj/structure/closet/crate/large)
	exclude_types = list()

/datum/export/large/crate/wooden/ore
	unit_name = "ore box"
	export_types = list(/obj/structure/ore_box)

/datum/export/large/crate/wood
	cost = CARGO_CRATE_VALUE * 0.48
	unit_name = "wooden crate"
	export_types = list(/obj/structure/closet/crate/wooden)
	exclude_types = list()

/datum/export/large/crate/coffin
	cost = CARGO_CRATE_VALUE/2 //50 wooden crates cost 800 credits, and you can make 10 coffins in seconds with those planks. Each coffin selling for 100 means you can make a net gain of 200 credits for wasting your time making coffins.
	unit_name = "coffin"
	export_types = list(/obj/structure/closet/crate/coffin)

/datum/export/large/reagent_dispenser
	cost = CARGO_CRATE_VALUE * 0.5 // +0-400 depending on amount of reagents left
	var/contents_cost = CARGO_CRATE_VALUE * 0.8

/datum/export/large/reagent_dispenser/get_cost(obj/structure/reagent_dispensers/dispenser)
	var/ratio = dispenser.reagents.total_volume / dispenser.reagents.maximum_volume

	return ..() + round(contents_cost * ratio)

/datum/export/large/reagent_dispenser/water
	unit_name = "watertank"
	export_types = list(/obj/structure/reagent_dispensers/watertank)
	contents_cost = CARGO_CRATE_VALUE * 0.4

/datum/export/large/reagent_dispenser/fuel
	unit_name = "fueltank"
	export_types = list(/obj/structure/reagent_dispensers/fueltank)

/datum/export/large/reagent_dispenser/beer
	unit_name = "beer keg"
	contents_cost = CARGO_CRATE_VALUE * 3.5
	export_types = list(/obj/structure/reagent_dispensers/beerkeg)

/datum/export/large/pipedispenser
	cost = CARGO_CRATE_VALUE * 2.5
	unit_name = "pipe dispenser"
	export_types = list(/obj/machinery/pipedispenser)

/datum/export/large/emitter
	cost = CARGO_CRATE_VALUE * 2.75
	unit_name = "emitter"
	export_types = list(/obj/machinery/power/emitter)

/datum/export/large/field_generator
	cost = CARGO_CRATE_VALUE * 2.75
	unit_name = "field generator"
	export_types = list(/obj/machinery/field/generator)

/datum/export/large/tesla_coil
	cost = CARGO_CRATE_VALUE * 2.25
	unit_name = "tesla coil"
	export_types = list(/obj/machinery/power/energy_accumulator/tesla_coil)

/datum/export/large/supermatter
	cost = CARGO_CRATE_VALUE * 16
	unit_name = "supermatter shard"
	export_types = list(/obj/machinery/power/supermatter_crystal/shard)

/datum/export/large/grounding_rod
	cost = CARGO_CRATE_VALUE * 1.2
	unit_name = "grounding rod"
	export_types = list(/obj/machinery/power/energy_accumulator/grounding_rod)

/datum/export/large/iv
	cost = CARGO_CRATE_VALUE * 0.25
	unit_name = "iv drip"
	export_types = list(/obj/machinery/iv_drip)

/datum/export/large/barrier
	cost = CARGO_CRATE_VALUE * 0.25
	unit_name = "security barrier"
	export_types = list(/obj/item/grenade/barrier, /obj/structure/barricade/security)

/**
 * Gas canister exports.
 * I'm going to put a quick aside here as this has been a pain to balance for several years now, and I'd like to at least break how to keep gas exports tame.
 * So: Gasses are sold in canisters below, which have a variable amount of maximum pressure before they start to break. The largest of which is 9.2e13 kPa.
 * This means we can determine a theoretical maximum value for gas sale prices using the ideal gas laws, as we know we have a minimum gas temperature of 2.7 kelvin.
 *
 * Additional note on base value. Gasses are soft capped to limit how much they're worth at large quantities, and time and time again players will find new ways to break your gasses.
 * so please, *PLEASE* try not to go too much further past 10.

 * * AUTHORS NOTE: This means the theoretical, insane madman number of moles of a single gas in a can sits at a horrifying 4,098,150,709.4 moles.
 * * Use this as you will, and when someone makes a quinquadrillion credits using gas exports, use these metrics as a way to balance the bejesus out of them.
 * * For more information, see code\modules\atmospherics\machinery\portable\canister.dm.
 */
/datum/export/large/gas_canister
	cost = CARGO_CRATE_VALUE * 0.05 //Base cost of canister. You get more for nice gases inside.
	unit_name = "Gas Canister"
	export_types = list(/obj/machinery/portable_atmospherics/canister)
	k_elasticity = 0.00033

/datum/export/large/gas_canister/get_cost(obj/machinery/portable_atmospherics/canister/canister)
	var/worth = cost
	var/datum/gas_mixture/canister_mix = canister.return_air()
	var/canister_gas = canister_mix.gases
	var/list/gases_to_check = list(
		/datum/gas/bz,
		/datum/gas/nitrium,
		/datum/gas/hypernoblium,
		/datum/gas/miasma,
		/datum/gas/tritium,
		/datum/gas/pluoxium,
		/datum/gas/freon,
		/datum/gas/hydrogen,
		/datum/gas/healium,
		/datum/gas/proto_nitrate,
		/datum/gas/zauker,
		/datum/gas/helium,
		/datum/gas/antinoblium,
		/datum/gas/halon,
	)

	for(var/gasID in gases_to_check)
		canister_mix.assert_gas(gasID)
		if(canister_gas[gasID][MOLES] > 0)
			worth += get_gas_value(gasID, canister_gas[gasID][MOLES])

	canister_mix.garbage_collect()
	return worth

/datum/export/large/gas_canister/proc/get_gas_value(datum/gas/gasType, moles)
	var/baseValue = initial(gasType.base_value)
	return round((baseValue/k_elasticity) * (1 - NUM_E**(-1 * k_elasticity * moles)))
