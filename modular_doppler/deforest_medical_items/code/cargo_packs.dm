/datum/supply_pack/medical/civil_defense
	name = "Civil Defense Medical Kit Crate"
	crate_name = "civil defense medical kit crate"
	desc = "Contains ten civil defense medical kits, small packs of injectors meant to be passed out to the public in case of emergency."
	access = ACCESS_MEDICAL
	cost = CARGO_CRATE_VALUE * 10 // 2000
	contains = list(
		/obj/item/storage/medkit/civil_defense/stocked = 10,
	)

/datum/supply_pack/medical/civil_defense/comfort
	name = "\improper Civil Defense Symptom Support Kit Crate"
	crate_name = "civil defense symptom support kit crate"
	desc = "Contains five civil defense symptom support kits stocked with three pens of psifinil and a tube containing 5 pills of alifil, two proprietary DeForest mixes designed to provide long-lasting relief from chronic disease and syndromes like gravity sickness."
	access = ACCESS_MEDICAL
	cost = CARGO_CRATE_VALUE * 5 // 2000
	contains = list(
		/obj/item/storage/medkit/civil_defense/comfort/stocked = 10,
	)

/datum/supply_pack/medical/frontier_first_aid
	name = "Frontier First Aid Crate"
	crate_name = "frontier first aid crate"
	desc = "Contains two of each of frontier medical kits, and combat surgeon medical kits."
	access = ACCESS_MEDICAL
	cost = CARGO_CRATE_VALUE * 10
	contains = list(
		/obj/item/storage/medkit/frontier/stocked = 3,
		/obj/item/storage/medkit/combat_surgeon/stocked = 3,
	)

/datum/supply_pack/medical/kit_technician
	name = "Heavy Duty Medical Kit Crate - Technician"
	crate_name = "technician kit crate"
	desc = "Contains a pink medical technician kit."
	access = ACCESS_MEDICAL
	cost = CARGO_CRATE_VALUE * 5.5
	contains = list(
		/obj/item/storage/backpack/duffelbag/deforest_paramedic/stocked,
	)

/datum/supply_pack/medical/kit_surgical
	name = "Heavy Duty Medical Kit Crate - Surgical"
	crate_name = "surgical kit crate"
	desc = "Contains a grey first responder surgical kit."
	access = ACCESS_MEDICAL
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/storage/backpack/duffelbag/deforest_surgical/stocked,
	)

/datum/supply_pack/medical/kit_medical
	name = "Heavy Duty Medical Kit Crate - Medical"
	crate_name = "medical kit crate"
	desc = "Contains an orange satchel medical kit."
	access = ACCESS_MEDICAL
	cost = CARGO_CRATE_VALUE * 4.5
	contains = list(
		/obj/item/storage/backpack/duffelbag/deforest_medkit/stocked,
	)

/datum/supply_pack/medical/deforest_vendor_refill
	name = "DeForest Med-Vend Resupply Crate"
	crate_name = "\improper DeForest Med-Vend resupply crate"
	desc = "Contains a restocking canister for DeForest Med-Vendors."
	access = ACCESS_MEDICAL
	cost = CARGO_CRATE_VALUE * 5
	contains = list(
		/obj/item/vending_refill/medical_deforest,
	)
