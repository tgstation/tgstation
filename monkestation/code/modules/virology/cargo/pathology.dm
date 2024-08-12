/datum/supply_pack/medical/growth_dishes
	name = "Random Virus Samples"
	desc = "A pack of 5 random virus samples"
	cost = CARGO_CRATE_VALUE * 10
	access = ACCESS_VIROLOGY
	contains = list(
		/obj/item/weapon/virusdish/random,
		/obj/item/weapon/virusdish/random,
		/obj/item/weapon/virusdish/random,
		/obj/item/weapon/virusdish/random,
		/obj/item/weapon/virusdish/random,
	)
	crate_name = "virus samples crates"
	crate_type = /obj/structure/closet/crate/secure/science

/datum/supply_pack/medical/rat_cubes
	name = "Crate of Rat Cube Boxes"
	desc = "A pack of 5 boxes of rat-cubes"
	cost = CARGO_CRATE_VALUE * 4
	contains = list(
		/obj/item/storage/box/monkeycubes/mousecubes,
		/obj/item/storage/box/monkeycubes/mousecubes,
		/obj/item/storage/box/monkeycubes/mousecubes,
		/obj/item/storage/box/monkeycubes/mousecubes,
		/obj/item/storage/box/monkeycubes/mousecubes,
	)
	crate_name = "rat cube crates"
	crate_type = /obj/structure/closet/crate
