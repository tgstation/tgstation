/datum/export/crate
	cost = CARGO_CRATE_VALUE
	k_elasticity = 0
	unit_name = "crate"
	export_types = list(/obj/structure/closet/crate)
	exclude_types = list(
		/obj/structure/closet/crate/coffin,
		/obj/structure/closet/crate/large,
		/obj/structure/closet/crate/mail,
		/obj/structure/closet/crate/wooden,
		/obj/structure/closet/crate/cardboard,
		)

/datum/export/crate/total_printout(datum/export_report/ex, notes = TRUE) // That's why a goddamn metal crate costs that much.
	. = ..()
	if(. && notes)
		. += " Thanks for participating in Nanotrasen Crates Recycling Program."

/datum/export/crate/wooden
	cost = CARGO_CRATE_VALUE / 5
	unit_name = "large wooden crate"
	export_types = list(/obj/structure/closet/crate/large)
	exclude_types = list()

/datum/export/crate/wooden/ore
	unit_name = "ore box"
	export_types = list(/obj/structure/ore_box)

/datum/export/crate/wood
	cost = CARGO_CRATE_VALUE * 0.48
	unit_name = "wooden crate"
	export_types = list(/obj/structure/closet/crate/wooden)
	exclude_types = list()

/datum/export/crate/coffin
	cost = CARGO_CRATE_VALUE/2 //50 wooden crates cost 800 credits, and you can make 10 coffins in seconds with those planks. Each coffin selling for 100 means you can make a net gain of 200 credits for wasting your time making coffins.
	unit_name = "coffin"
	export_types = list(/obj/structure/closet/crate/coffin)

/datum/export/crate/cardboard
	cost = CARGO_CRATE_VALUE/5
	unit_name = "cardboard box"
	export_types = list(/obj/structure/closet/crate/cardboard, /obj/structure/closet/cardboard)

/datum/export/reagent_dispenser
	abstract_type = /datum/export/reagent_dispenser
	cost = CARGO_CRATE_VALUE * 0.5 // +0-400 depending on amount of reagents left
	///cost for an full holder of reagents
	var/contents_cost = CARGO_CRATE_VALUE * 0.8

/datum/export/reagent_dispenser/get_base_cost(obj/structure/reagent_dispensers/dispenser)
	return ..() + round(contents_cost * (dispenser.reagents.total_volume / dispenser.reagents.maximum_volume))

/datum/export/reagent_dispenser/water
	unit_name = "watertank"
	export_types = list(/obj/structure/reagent_dispensers/watertank)
	contents_cost = CARGO_CRATE_VALUE * 0.4

/datum/export/reagent_dispenser/fuel
	unit_name = "fueltank"
	export_types = list(/obj/structure/reagent_dispensers/fueltank)

/datum/export/reagent_dispenser/beer
	unit_name = "beer keg"
	contents_cost = CARGO_CRATE_VALUE * 3.5
	export_types = list(/obj/structure/reagent_dispensers/beerkeg)

/datum/export/pipedispenser
	cost = CARGO_CRATE_VALUE * 2.5
	unit_name = "pipe dispenser"
	export_types = list(/obj/machinery/pipedispenser)

/datum/export/emitter
	cost = CARGO_CRATE_VALUE * 2.75
	unit_name = "emitter"
	export_types = list(/obj/machinery/power/emitter)

/datum/export/field_generator
	cost = CARGO_CRATE_VALUE * 2.75
	unit_name = "field generator"
	export_types = list(/obj/machinery/field/generator)

/datum/export/tesla_coil
	cost = CARGO_CRATE_VALUE * 2.25
	unit_name = "tesla coil"
	export_types = list(/obj/machinery/power/energy_accumulator/tesla_coil)

/datum/export/supermatter
	cost = CARGO_CRATE_VALUE * 16
	unit_name = "supermatter shard"
	export_types = list(/obj/machinery/power/supermatter_crystal/shard)

/datum/export/grounding_rod
	cost = CARGO_CRATE_VALUE * 1.2
	unit_name = "grounding rod"
	export_types = list(/obj/machinery/power/energy_accumulator/grounding_rod)

/datum/export/iv
	cost = CARGO_CRATE_VALUE * 0.25
	unit_name = "iv drip"
	export_types = list(/obj/machinery/iv_drip)

/datum/export/barrier
	cost = CARGO_CRATE_VALUE * 0.25
	unit_name = "security barrier"
	export_types = list(/obj/item/grenade/barrier, /obj/structure/barricade/security)

///Maximum number of credits you can earn from selling your gas canister cause its theoritically infinite
#define MAX_GAS_CREDITS 15000

/**
 * Maximum pressure a canister can withstand is 9.2e13 kPa at a minimum of 2.7K which would contain a horrifying 4,098,150,709.4 moles.
 * We don't want players making that much credits so we limit the total amount earned to MAX_GAS_CREDITS
*/
/datum/export/gas_canister
	cost = CARGO_CRATE_VALUE * 0.05 //Base cost of canister. You get more for nice gases inside.
	unit_name = "Gas Canister"
	export_types = list(/obj/machinery/portable_atmospherics/canister)

/datum/export/gas_canister/get_base_cost(obj/machinery/portable_atmospherics/canister/canister)
	var/datum/gas_mixture/canister_mix = canister.return_air()
	if(!canister_mix.total_moles())
		return 0
	var/canister_gas = canister_mix.gases

	var/static/list/gases_to_check = list(
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

	var/worth = cost
	for(var/gasID in gases_to_check)
		canister_mix.assert_gas(gasID)
		if(canister_gas[gasID][MOLES] > 0)
			worth += get_gas_value(gasID, canister_gas[gasID][MOLES])
			if(worth > MAX_GAS_CREDITS)
				worth = MAX_GAS_CREDITS
				break

	return worth

/datum/export/gas_canister/proc/get_gas_value(datum/gas/gasType, moles)
	return ROUND_UP(initial(gasType.base_value) * moles)

#undef MAX_GAS_CREDITS
