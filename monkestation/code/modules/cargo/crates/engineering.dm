/datum/supply_pack/engineering/radios
	name = "Telecommunications Starter Pack crate"
	desc = "Contains everything you need to get a basic stationwide radio network established!"
	cost = CARGO_CRATE_VALUE * 1.5
	contraband = TRUE
	contains = list(/obj/item/radio = 10)
	crate_name = "telecommunications starter pack crate"

/datum/supply_pack/engineering/cones
	name = "Engineering hat crate"
	desc = "A complete set of headwear to fit the heads of an entire engineering crew. Includes six cones."
	cost = CARGO_CRATE_VALUE * 1.5
	contains = list(/obj/item/clothing/head/cone = 6)
	crate_name = "engineering hat crate"

/datum/supply_pack/engineering/stompers
	name = "Hotspot Stomping Kit"
	desc = "Everything you need to stomp hotspots."
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/obj/machinery/power/stomper = 3, /obj/item/dousing_rod = 3)
	crate_name = "engineering stomping crate"

/datum/supply_pack/engineering/vent_kit
	name = "Hotspot Vent Kit"
	desc = "A pack of 5 vents for hotspots."
	cost = CARGO_CRATE_VALUE * 10
	contains = list(/obj/item/vent_package = 5)
	crate_name = "engineering vent crate"
