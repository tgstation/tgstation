/datum/supply_pack/materials
	group = "Canisters & Materials"

/datum/supply_pack/materials/cardboard50
	name = "50 Cardboard Sheets"
	desc = "Create a bunch of boxes."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/stack/sheet/cardboard/fifty)
	crate_name = "cardboard sheets crate"

/datum/supply_pack/materials/license50
	name = "50 Empty License Plates"
	desc = "Create a bunch of license plates."
	cost = CARGO_CRATE_VALUE * 2  // 50 * 25 + 700 - 1000 = 950 credits profit
	access_view = ACCESS_BRIG_ENTRANCE
	contains = list(/obj/item/stack/license_plates/empty/fifty)
	crate_name = "empty license plate crate"

/datum/supply_pack/materials/glass50
	name = "50 Glass Sheets"
	desc = "Let some nice light in with fifty glass sheets!"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/stack/sheet/glass/fifty)
	crate_name = "glass sheets crate"

/datum/supply_pack/materials/iron50
	name = "50 Iron Sheets"
	desc = "Any construction project begins with a good stack of fifty iron sheets!"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/stack/sheet/iron/fifty)
	crate_name = "iron sheets crate"

/datum/supply_pack/materials/plasteel20
	name = "20 Plasteel Sheets"
	desc = "Reinforce the station's integrity with twenty plasteel sheets!"
	cost = CARGO_CRATE_VALUE * 15
	contains = list(/obj/item/stack/sheet/plasteel/twenty)
	crate_name = "plasteel sheets crate"

/datum/supply_pack/materials/plasteel50
	name = "50 Plasteel Sheets"
	desc = "For when you REALLY have to reinforce something."
	cost = CARGO_CRATE_VALUE * 33
	contains = list(/obj/item/stack/sheet/plasteel/fifty)
	crate_name = "plasteel sheets crate"

/datum/supply_pack/materials/plastic50
	name = "50 Plastic Sheets"
	desc = "Build a limitless amount of toys with fifty plastic sheets!"
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/stack/sheet/plastic/fifty)
	crate_name = "plastic sheets crate"

/datum/supply_pack/materials/sandstone30
	name = "30 Sandstone Blocks"
	desc = "Neither sandy nor stoney, these thirty blocks will still get the job done."
	cost = CARGO_CRATE_VALUE * 2
	contains = list(/obj/item/stack/sheet/mineral/sandstone/thirty)
	crate_name = "sandstone blocks crate"

/datum/supply_pack/materials/wood50
	name = "50 Wood Planks"
	desc = "Turn cargo's boring metal groundwork into beautiful \
		panelled flooring and much more with fifty wooden planks!"
	cost = CARGO_CRATE_VALUE * 4
	contains = list(/obj/item/stack/sheet/mineral/wood/fifty)
	crate_name = "wood planks crate"

/datum/supply_pack/materials/foamtank
	name = "Firefighting Foam Tank Crate"
	desc = "Contains a tank of firefighting foam. Also known as \"plasmaman's bane.\""
	cost = CARGO_CRATE_VALUE * 3
	contains = list(/obj/structure/reagent_dispensers/foamtank)
	crate_name = "foam tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/fueltank
	name = "Fuel Tank Crate"
	desc = "Contains a welding fuel tank. Caution, highly flammable."
	cost = CARGO_CRATE_VALUE * 1.6
	contains = list(/obj/structure/reagent_dispensers/fueltank)
	crate_name = "fuel tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/hightank
	name = "Large Water Tank Crate"
	desc = "Contains a high-capacity water tank. Useful for botany or other service jobs."
	cost = CARGO_CRATE_VALUE * 2.4
	contains = list(/obj/structure/reagent_dispensers/watertank/high)
	crate_name = "high-capacity water tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/hightankfuel
	name = "Large Fuel Tank Crate"
	desc = "Contains a high-capacity fuel tank. Keep contents away from open flame."
	cost = CARGO_CRATE_VALUE * 4
	access_view = ACCESS_ENGINEERING
	contains = list(/obj/structure/reagent_dispensers/fueltank/large)
	crate_name = "high-capacity fuel tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/watertank
	name = "Water Tank Crate"
	desc = "Contains a tank of dihydrogen monoxide... sounds dangerous."
	cost = CARGO_CRATE_VALUE * 1.2
	contains = list(/obj/structure/reagent_dispensers/watertank)
	crate_name = "water tank crate"
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/gas_canisters
	cost = CARGO_CRATE_VALUE * 0.05
	contains = list(/obj/machinery/portable_atmospherics/canister)
	crate_type = /obj/structure/closet/crate/large

/datum/supply_pack/materials/gas_canisters/generate_supply_packs()
	var/list/canister_packs = list()

	var/obj/machinery/portable_atmospherics/canister/fakeCanister = /obj/machinery/portable_atmospherics/canister
	// This is the amount of moles in a default canister
	var/moleCount = (initial(fakeCanister.maximum_pressure) * initial(fakeCanister.filled)) * initial(fakeCanister.volume) / (R_IDEAL_GAS_EQUATION * T20C)

	for(var/gasType in GLOB.meta_gas_info)
		var/datum/gas/gas = gasType
		var/name = initial(gas.name)
		if(!initial(gas.purchaseable))
			continue
		var/datum/supply_pack/materials/pack = new
		pack.name = "[name] Canister"
		pack.desc = "Contains a canister of [name]."
		if(initial(gas.dangerous))
			pack.access = ACCESS_ATMOSPHERICS
			pack.access_view = ACCESS_ATMOSPHERICS
		pack.crate_name = "[name] canister crate"
		pack.id = "[type]([name])"

		pack.cost = cost + moleCount * initial(gas.base_value) * 1.6
		pack.cost = CEILING(pack.cost, 10)

		pack.contains = list(GLOB.gas_id_to_canister[initial(gas.id)])

		pack.crate_type = crate_type

		canister_packs += pack

	return canister_packs
