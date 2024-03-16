/datum/supply_pack/medical/medkits
	name = "Basic Treament Kits Crate"
	desc = "Contains three first aid kits focused on basic types of damage in a simple way."
	cost = CARGO_CRATE_VALUE * 2.5
	contains = list(/obj/item/storage/medkit/regular = 3)
	crate_name = "basic wound treatment kits crate"

/datum/supply_pack/medical/brutekits
	name = "Bruise Treatment Kits Crate"
	desc = "Contains three first aid kits focused on healing bruises and broken bones."
	cost = CARGO_CRATE_VALUE * 2.5
	contains = list(/obj/item/storage/medkit/brute = 3)
	crate_name = "brute treatment kits crate"

/datum/supply_pack/medical/burnkits
	name = "Burn Treatment Kits Crate"
	desc = "Contains three first aid kits focused on healing severe burns."
	cost = CARGO_CRATE_VALUE * 2.5
	contains = list(/obj/item/storage/medkit/fire = 3)
	crate_name = "burn treatment kits crate"

/datum/supply_pack/medical/toxinkits
	name = "Toxin Treatment Kits Crate"
	desc = "Containts three first aid kits focused on healing damage dealt by heavy toxins."
	cost = CARGO_CRATE_VALUE * 2.5
	contains = list(/obj/item/storage/medkit/toxin = 3)
	crate_name = "toxin treatment kits crate"

/datum/supply_pack/medical/oxylosskits
	name = "Oxygen Deprivation Kits Crate"
	desc = "Contains three first aid kits focused on helping oxygen deprivation victims."
	cost = CARGO_CRATE_VALUE * 2.5
	contains = list(/obj/item/storage/medkit/o2 = 3)
	crate_name = "oxygen deprivation treatment kits crate"

/datum/supply_pack/medical/advkits
	name = "Advanced Medical Kits Crate"
	desc = "For when the basic kits don't cut it."
	cost = CARGO_CRATE_VALUE * 5
	contains = list(/obj/item/storage/medkit/advanced = 3)
	crate_name = "advanced treatment kits crate"

/datum/supply_pack/medical/randommedkit
	name = "Random Medkits Crate"
	desc = "A mishmosh of medkits for the indecisive."
	cost = CARGO_CRATE_VALUE * 5
	contains = list()
	crate_name = "Medkit Assortment Crate"

/datum/supply_pack/medical/randommedkit/fill/(obj/structure/closet/crate/C)
	for(var/i in 1 to 6)
		var/item = pick(10;/obj/item/storage/medkit/regular,
						20;/obj/item/storage/medkit/brute,
						20;/obj/item/storage/medkit/fire,
						20;/obj/item/storage/medkit/toxin,
						20;/obj/item/storage/medkit/o2,
						10;/obj/item/storage/medkit/advanced,
						10;/obj/item/storage/medkit/surgery)
		new item(C)

/datum/supply_pack/medical/maintpills
	name = "Forgotten Prescriptions Pack"
	desc = "We found some old pills in the back of the warehouse, yours for a price."
	cost = CARGO_CRATE_VALUE * 20
	contraband = TRUE
	contains = list(/obj/item/reagent_containers/pill/maintenance = 10)
	crate_name = "experimental medicine crate"
