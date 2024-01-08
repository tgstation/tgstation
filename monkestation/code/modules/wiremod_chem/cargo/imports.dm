/datum/supply_pack/medical/chemical_manufacturer
	name = "Replacement Chemical Manufacturer"
	desc = "Incase you've lost or broken the manufacturer we gave you."
	cost = CARGO_CRATE_VALUE * 10

	contains = list(
		/obj/structure/chemical_manufacturer,
		)

/datum/supply_pack/medical/precursor_canister
	name = "Precursor Canister"
	desc = "Useful for your chemical manufacturer to not cause the engineers to cry."
	cost = CARGO_CRATE_VALUE * 4

	contains = list(
		/obj/item/precursor_tank,
		)

/datum/supply_pack/medical/medical_circuits
	name = "Three pack of medical circuits"
	desc = "Used to make some cool bluespace chemical factories."
	cost = CARGO_CRATE_VALUE * 15

	contains = list(
		/obj/item/integrated_circuit/chemical,
		/obj/item/integrated_circuit/chemical,
		/obj/item/integrated_circuit/chemical,
	)
