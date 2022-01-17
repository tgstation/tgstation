/obj/effect/spawner/random/structure
	name = "structure spawner"
	desc = "Now you see me, now you don't..."

/obj/effect/spawner/random/structure/crate
	name = "crate spawner"
	icon_state = "crate_secure"
	loot = list(
		/obj/effect/spawner/random/structure/crate_loot = 745,
		/obj/structure/closet/crate/trashcart/filled = 75,
		/obj/effect/spawner/random/trash/moisture_trap = 50,
		/obj/effect/spawner/random/trash/hobo_squat = 30,
		/obj/structure/closet/mini_fridge = 35,
		/obj/effect/spawner/random/trash/mess = 30,
		/obj/item/kirbyplants/fern = 20,
		/obj/structure/closet/crate/decorations = 15,
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

/obj/effect/spawner/random/structure/furniture_parts
	name = "furniture parts spawner"
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
	loot_type_path = /obj/structure/table/wood/fancy
	loot = list()

/obj/effect/spawner/random/structure/tank_holder
	name = "tank holder spawner"
	icon_state = "tank_holder"
	loot = list(
		/obj/structure/tank_holder/oxygen = 40,
		/obj/structure/tank_holder/extinguisher = 40,
		/obj/structure/tank_holder = 20,
		/obj/structure/tank_holder/extinguisher/advanced = 1,
	)

/obj/effect/spawner/random/structure/crate_empty
	name = "empty crate spawner"
	icon_state = "crate"
	loot = list(
		/obj/structure/closet/crate = 20,
		/obj/structure/closet/crate/wooden = 1,
		/obj/structure/closet/crate/internals = 1,
		/obj/structure/closet/crate/medical = 1,
		/obj/structure/closet/crate/freezer = 1,
		/obj/structure/closet/crate/radiation = 1,
		/obj/structure/closet/crate/hydroponics = 1,
		/obj/structure/closet/crate/engineering = 1,
		/obj/structure/closet/crate/engineering/electrical = 1,
		/obj/structure/closet/crate/science = 1,
	)

/obj/effect/spawner/random/structure/crate_loot
	name = "lootcrate spawner"
	icon_state = "crate"
	loot = list(
		/obj/structure/closet/crate/maint = 15,
		/obj/effect/spawner/random/structure/crate_empty = 4,
		/obj/structure/closet/crate/secure/loot = 1,
	)

/obj/effect/spawner/random/structure/closet_private
	name = "private closet spawner"
	icon_state = "cabinet"
	loot = list(
		/obj/structure/closet/secure_closet/personal,
		/obj/structure/closet/secure_closet/personal/cabinet,
	)

/obj/effect/spawner/random/structure/closet_empty
	name = "empty closet spawner"
	icon_state = "locker"
	loot = list(
		/obj/structure/closet = 850,
		/obj/structure/closet/cabinet = 150,
		/obj/structure/closet/acloset = 1,
	)

/obj/effect/spawner/random/structure/closet_maintenance
	name = "maintenance closet spawner"
	icon_state = "locker"
	loot = list( // use these for maintenance areas
		/obj/effect/spawner/random/structure/closet_empty = 10,
		/obj/structure/closet/emcloset = 2,
		/obj/structure/closet/firecloset = 2,
		/obj/structure/closet/toolcloset = 2,
		/obj/structure/closet/l3closet = 1,
		/obj/structure/closet/radiation = 1,
		/obj/structure/closet/bombcloset = 1,
		/obj/structure/closet/mini_fridge = 1,
	)

/obj/effect/spawner/random/structure/chair_flipped
	name = "flipped chair spawner"
	icon_state = "chair"
	loot = list(
		/obj/item/chair/wood,
		/obj/item/chair/stool/bar,
		/obj/item/chair/stool,
		/obj/item/chair,
	)

/obj/effect/spawner/random/structure/chair_comfy
	name = "comfy chair spawner"
	icon_state = "chair"
	loot_type_path = /obj/structure/chair/comfy
	loot = list()

/obj/effect/spawner/random/structure/chair_maintenance
	name = "maintenance chair spawner"
	icon_state = "chair"
	loot = list(
		/obj/structure/chair = 200,
		/obj/structure/chair/stool = 200,
		/obj/structure/chair/stool/bar = 200,
		/obj/effect/spawner/random/structure/chair_flipped = 150,
		/obj/structure/chair/wood = 100,
		/obj/effect/spawner/random/structure/chair_comfy = 50,
		/obj/structure/chair/office/light = 50,
		/obj/structure/chair/office = 50,
		/obj/structure/chair/wood/wings = 1,
		/obj/structure/chair/old = 1,
	)

/obj/effect/spawner/random/structure/barricade
	name = "barricade spawner"
	icon_state = "barricade"
	loot = list(
		/obj/structure/barricade/wooden,
		/obj/structure/barricade/wooden/crude,
	)

/obj/effect/spawner/random/structure/billboard
	name = "billboard spawner"
	icon = 'icons/obj/billboard.dmi'
	icon_state = "billboard_random"
	loot = list(
		/obj/structure/billboard/azik = 50,
		/obj/structure/billboard/donk_n_go = 50,
		/obj/structure/billboard/space_cola = 50,
		/obj/structure/billboard/nanotrasen = 35,
		/obj/structure/billboard/nanotrasen/defaced = 15,
	)

/obj/effect/spawner/random/structure/billboard/nanotrasen //useful for station maps- NT isn't the sort to advertise for competitors
	name = "\improper Nanotrasen billboard spawner"
	loot = list(
		/obj/structure/billboard/nanotrasen = 35,
		/obj/structure/billboard/nanotrasen/defaced = 15,
	)

/obj/effect/spawner/random/structure/billboard/lizardsgas //for the space ruin, The Lizard's Gas. I don't see much use for the sprites below anywhere else since they're unifunctional.
	name = "\improper The Lizards Gas billboard spawner"
	loot = list(
		/obj/structure/billboard/lizards_gas = 50,
		/obj/structure/billboard/lizards_gas/shit = 35,
		/obj/structure/billboard/lizards_gas/shit/defaced = 15,
	)
