/datum/supply_pack/medical/serverlink_implant
	name = "Serverlink Implant Set"
	desc = "A crate containing two implants, which can be surgically implanted to download advanced surgical knowledge into the user's brain."
	cost = CARGO_CRATE_VALUE * 8
	access = ACCESS_SURGERY
	contains = list(/obj/item/organ/internal/cyberimp/brain/linked_surgery = 2)
	crate_name = "serverlink implant crate"
