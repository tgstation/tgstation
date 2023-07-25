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

/datum/supply_pack/engineering/servicefab
	name = "Service Techfab Replacement"
	desc = "You're telling me botany broke it with a lemon?"
	cost = CARGO_CRATE_VALUE * 50
	access = ACCESS_HOP
	contains = list(/obj/item/circuitboard/machine/protolathe/department/service,
					/obj/item/stock_parts/matter_bin/adv = 2,
					/obj/item/stock_parts/manipulator/nano = 2,
					/obj/item/reagent_containers/cup/beaker = 2,
					/obj/item/stack/sheet/iron/five,
					/obj/item/stack/cable_coil/five)
	crate_name = "Replacement Service Techfab"
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/supply_pack/engineering/secfab
	name = "Security Techfab Replacement"
	desc = "This is coming out of the donut budget."
	cost = CARGO_CRATE_VALUE * 50
	access = ACCESS_HOS
	contains = list(/obj/item/circuitboard/machine/protolathe/department/security,
					/obj/item/stock_parts/matter_bin/adv = 2,
					/obj/item/stock_parts/manipulator/nano = 2,
					/obj/item/reagent_containers/cup/beaker = 2,
					/obj/item/stack/sheet/iron/five,
					/obj/item/stack/cable_coil/five
					)
	crate_name = "Replacement Security Techfab"
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/supply_pack/engineering/cargofab
	name = "Cargo Techfab Replacement"
	desc = "You better not lodge a mosin bullet in this one too."
	cost = CARGO_CRATE_VALUE * 50
	access = ACCESS_QM
	contains = list(/obj/item/circuitboard/machine/protolathe/department/cargo,
					/obj/item/stock_parts/matter_bin/adv = 2,
					/obj/item/stock_parts/manipulator/nano = 2,
					/obj/item/reagent_containers/cup/beaker = 2,
					/obj/item/stack/sheet/iron/five,
					/obj/item/stack/cable_coil/five)
	crate_name = "Replacement Cargo Techfab"
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/supply_pack/engineering/medfab
	name = "Medical Techfab Replacement"
	desc = "The chemist you say. Meth you say."
	cost = CARGO_CRATE_VALUE * 50
	access = ACCESS_CMO
	contains = list(/obj/item/circuitboard/machine/protolathe/department/medical,
					/obj/item/stock_parts/matter_bin/adv = 2,
					/obj/item/stock_parts/manipulator/nano = 2,
					/obj/item/reagent_containers/cup/beaker = 2,
					/obj/item/stack/sheet/iron/five,
					/obj/item/stack/cable_coil/five)
	crate_name = "Replacement Medical Techfab"
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/supply_pack/engineering/engilathe
	name = "Engineering Protolathe Replacement"
	desc = "You said the atmospherics department melted the last one?"
	cost = CARGO_CRATE_VALUE * 50
	access = ACCESS_CE
	contains = list(/obj/item/circuitboard/machine/protolathe/department/engineering,
					/obj/item/stock_parts/matter_bin/adv = 2,
					/obj/item/stock_parts/manipulator/nano = 2,
					/obj/item/reagent_containers/cup/beaker = 2,
					/obj/item/stack/sheet/iron/five,
					/obj/item/stack/cable_coil/five)
	crate_name = "Replacement Engineering Protolathe"
	crate_type = /obj/structure/closet/crate/secure/engineering

/datum/supply_pack/engineering/scilathe
	name = "Science Protolathe Replacement"
	desc = "Try not to feed this one into the E.X.P.E.R.I.M.E.N.T.O.R. yeah?"
	cost = CARGO_CRATE_VALUE * 50
	access = ACCESS_RD
	contains = list(/obj/item/circuitboard/machine/protolathe/department/science,
					/obj/item/stock_parts/matter_bin/adv = 2,
					/obj/item/stock_parts/manipulator/nano = 2,
					/obj/item/reagent_containers/cup/beaker = 2,
					/obj/item/stack/sheet/iron/five,
					/obj/item/stack/cable_coil/five
					)
	crate_name = "Replacement Science Protolathe"
	crate_type = /obj/structure/closet/crate/secure/engineering
