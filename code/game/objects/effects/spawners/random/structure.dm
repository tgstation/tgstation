obj/effect/spawner/random/structure
	name = "structure spawner"
	desc = "Now you see me, now you don't..."

/obj/effect/spawner/random/structure/crate
	name = "crate spawner"
	icon_state = "crate"
	loot = list(
		/obj/structure/closet/crate/maint = 75,
		/obj/structure/closet/crate/trashcart/filled = 7,
		/obj/effect/spawner/random/trash/moisture_trap = 5,
		/obj/effect/spawner/random/trash/hobo_squat = 3,
		/obj/structure/closet/mini_fridge = 3,
		/obj/effect/spawner/random/trash/mess = 3,
		/obj/structure/closet/crate/decorations = 1,
	)

/obj/effect/spawner/random/structure/crate_abandoned
	name = "locked crate spawner"
	icon_state = "crate_secure"
	spawn_loot_chance = 20
	loot = list(/obj/structure/closet/crate/secure/loot)

/obj/effect/spawner/random/structure/girder
	name = "girder spawner"
	icon_state = "girder"
	loot = list(
		/obj/structure/girder = 4,
		/obj/structure/girder/displaced = 1,
	)

/obj/effect/spawner/random/structure/grille
	name = "grille spawner"
	icon_state = "grille"
	loot = list(
		/obj/structure/grille = 4,
		/obj/structure/grille/broken = 1,
	)

/obj/effect/spawner/random/structure/lattice
	name = "lattice spawner"
	icon_state = "lattice"
	loot = list(
		/obj/structure/lattice = 4,
		/obj/structure/lattice/catwalk = 1,
	)

/obj/effect/spawner/random/structure/spare_parts
	name = "spare parts spawner"
	icon_state = "table_parts"
	loot = list(
		/obj/structure/table_frame,
		/obj/structure/table_frame/wood,
		/obj/item/rack_parts,
	)

/obj/effect/spawner/random/structure/table_or_rack
	name = "table or rack spawner"
	icon_state = "rack_parts"
	loot = list(
		/obj/effect/spawner/random/structure/table,
		/obj/structure/rack,
	)

/obj/effect/spawner/random/structure/table
	name = "table spawner"
	icon_state = "table"
	loot = list(
		/obj/structure/table = 40,
		/obj/structure/table/wood = 30,
		/obj/structure/table/glass = 20,
		/obj/structure/table/reinforced = 5,
		/obj/structure/table/wood/poker = 5,
	)

/obj/effect/spawner/random/structure/table_fancy
	name = "table spawner"
	icon_state = "table_fancy"
	loot_type_path = /obj/structure/showcase
	loot = list()
