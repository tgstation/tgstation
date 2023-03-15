//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Miscellaneous ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////
/datum/supply_pack/misc/sticker_set
	name = "Sticker Set"
	desc = "Seven superior selected sticker sets shipped swiftly soon to a station that which you stand. Shaking, shivering, so stimulated! Sticky satisfaction secured, shall someone ship some specialty stickables?"
	cost = 500
	small_item = TRUE
	contains = list(/obj/item/storage/box/stickers)
	crate_name = "Specialty Sticker Set"

/datum/supply_pack/emergency/spatialriftnullifier
	name = "Spatial Rift Nullifier Pack"
	desc = "Everything that the crew needs to take down a rogue Singularity or Tesla."
	cost = 5000
	contains = list(/obj/item/gun/ballistic/SRN_rocketlauncher = 4)
	crate_name = "Spatial Rift Nullifier (SRN)"
	crate_type = /obj/structure/closet/crate/secure

/datum/supply_pack/engine/fuel_rod
	name = "Uranium Fuel Rod crate"
	desc = "Two additional fuel rods for use in a reactor, requires CE access to open. Caution: Radioactive"
	cost = 4000
	access = ACCESS_CE
	contains = list(/obj/item/fuel_rod,
					/obj/item/fuel_rod)
	crate_name = "Uranium-235 Fuel Rod crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engine/funny_fuel_rod
	name = "Funny Fuel Rod crate"
	desc = "Two funny fuel rods for use in a reactor, requires CE access to open. Caution: Radioactive"
	cost = 4420
	access = ACCESS_CE
	contains = list(/obj/item/fuel_rod/material/bananium,
					/obj/item/fuel_rod/material/bananium)
	crate_name = "Funny Fuel Rod crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/medical/experimental_cloner
	name = "Experimental Cloner Crate"
	desc = "A complete circuitboard set to a Experimental Cloner Pod and Scanner. Caution: Highly Experimental"
	cost = 5000
	access = ACCESS_CARGO
	contains = list(/obj/item/circuitboard/machine/clonepod/experimental,
					/obj/item/circuitboard/machine/clonescanner,
					/obj/item/circuitboard/computer/cloning)
	crate_name = "Experimental Cloner Crate"
	crate_type = /obj/structure/closet/crate/medical
	dangerous = TRUE
