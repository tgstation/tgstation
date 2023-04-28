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

/datum/supply_pack/engine/tesla_gen
	name = "Tesla Generator Crate"
	desc = "The key to unlocking the power of the Tesla energy ball. Particle Accelerator not included."
	cost = 5000
	contains = list(/obj/machinery/the_singularitygen/tesla)
	crate_name = "tesla generator crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engine/sing_gen
	name = "Singularity Generator Crate"
	desc = "The key to unlocking the power of Lord Singuloth. Particle Accelerator not included."
	cost = 4700
	contains = list(/obj/machinery/the_singularitygen)
	crate_name = "singularity generator crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/engine/PA
	name = "Particle Accelerator Crate"
	desc = "A supermassive black hole or hyper-powered teslaball are the perfect way to spice up any party! This \"My First Apocalypse\" kit contains everything you need to build your own Particle Accelerator! Ages 10 and up."
	cost = 2700
	contains = list(/obj/structure/particle_accelerator/fuel_chamber,
					/obj/machinery/particle_accelerator/control_box,
					/obj/structure/particle_accelerator/particle_emitter/center,
					/obj/structure/particle_accelerator/particle_emitter/left,
					/obj/structure/particle_accelerator/particle_emitter/right,
					/obj/structure/particle_accelerator/power_box,
					/obj/structure/particle_accelerator/end_cap)
	crate_name = "particle accelerator crate"
	crate_type = /obj/structure/closet/crate/secure/engineering
	dangerous = TRUE

/datum/supply_pack/goody/monkestation_stickers
	name = "Three Pack of Monkestation Stickers"
	desc = "Stickers for all!"
	cost = 2500
	contains = list(/obj/item/storage/box/monkestation_stickers,
					/obj/item/storage/box/monkestation_stickers,
					/obj/item/storage/box/monkestation_stickers)
	crate_name = "collectable stickers crate"
	crate_type = /obj/structure/closet/crate

/datum/supply_pack/emergency/spatialriftnullifier
	name = "Spatial Rift Nullifier Pack"
	desc = "Everything that the crew needs to take down a rogue Singularity or Tesla."
	cost = 5000
	contains = list(/obj/item/gun/ballistic/SRN_rocketlauncher = 4)
	crate_name = "Spatial Rift Nullifier (SRN)"
	crate_type = /obj/structure/closet/crate/secure
