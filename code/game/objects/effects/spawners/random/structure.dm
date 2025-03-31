/obj/effect/spawner/random/structure
	name = "structure spawner"
	desc = "Now you see me, now you don't..."

///12% chance to spawn a ouija board, or a potted plant. Btw, Wawastation has a guaranteed board.
/obj/effect/spawner/random/structure/twelve_percent_spirit_board
	name = "12% spirit board"
	icon_state = "spirit_board"
	loot = list(
		/obj/structure/spirit_board = 3,
		/obj/item/kirbyplants/random = 22,
	)

/obj/effect/spawner/random/structure/crate
	name = "crate spawner"
	icon_state = "crate_secure"
	loot = list(
		/obj/effect/spawner/random/structure/crate_loot = 744,
		/obj/structure/closet/crate/trashcart/filled = 75,
		/obj/effect/spawner/random/trash/moisture_trap = 50,
		/obj/effect/spawner/random/trash/hobo_squat = 30,
		/obj/structure/closet/mini_fridge = 35,
		/obj/effect/spawner/random/trash/mess = 30,
		/obj/item/kirbyplants/fern = 20,
		/obj/structure/closet/crate/decorations = 15,
		/obj/effect/decal/remains/human/smokey/maintenance = 7,
		/obj/structure/destructible/cult/pants_altar = 1,
	)

/obj/effect/spawner/random/structure/crate_abandoned
	name = "locked crate spawner"
	icon_state = "crate_secure"
	spawn_loot_chance = 20
	loot = list(/obj/structure/closet/crate/secure/loot)

/obj/effect/spawner/random/structure/girder
	name = "girder spawner"
	icon_state = "girder"
	spawn_loot_chance = 90
	loot = list( // 80% chance normal girder, 10% chance of displaced, 10% chance of nothing
		/obj/structure/girder = 8,
		/obj/structure/girder/displaced = 1,
	)

/obj/effect/spawner/random/structure/grille
	name = "grille spawner"
	icon_state = "grille"
	spawn_loot_chance = 90
	loot = list( // 80% chance normal grille, 10% chance of broken, 10% chance of nothing
		/obj/structure/grille = 8,
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

/obj/effect/spawner/random/structure/closet_empty
	name = "empty closet spawner"
	icon_state = "locker"
	loot = list(
		/obj/structure/closet = 850,
		/obj/structure/closet/cabinet = 150,
		/obj/structure/closet/acloset = 1,
	)

/obj/effect/spawner/random/structure/closet_empty/make_item(spawn_loc, type_path_to_make)
	var/obj/structure/closet/peek_a_boo = ..()
	if(istype(peek_a_boo) && prob(50))
		peek_a_boo.open(special_effects = FALSE) //the crate appears immediatly out of thin air so no need to animate anything

	return peek_a_boo

/obj/effect/spawner/random/structure/closet_empty/crate
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

/obj/effect/spawner/random/structure/closet_empty/crate/with_loot
	name = "crate spawner with maintenance loot"
	icon_state = "crate"

/obj/effect/spawner/random/structure/closet_empty/crate/with_loot/make_item(spawn_loc, type_path_to_make)
	var/obj/structure/closet/closet_to_fill = ..()
	closet_to_fill.RegisterSignal(closet_to_fill, COMSIG_CLOSET_CONTENTS_INITIALIZED, TYPE_PROC_REF(/obj/structure/closet/, populate_with_random_maint_loot))

	return closet_to_fill

/obj/effect/spawner/random/structure/crate_loot
	name = "lootcrate spawner"
	icon_state = "crate"
	loot = list(
		/obj/effect/spawner/random/structure/closet_empty/crate/with_loot = 15,
		/obj/effect/spawner/random/structure/closet_empty/crate = 4,
		/obj/structure/closet/crate/secure/loot = 1,
	)

/obj/effect/spawner/random/structure/closet_private
	name = "private closet spawner"
	icon_state = "cabinet"
	loot = list(
		/obj/structure/closet/secure_closet/personal,
		/obj/structure/closet/secure_closet/personal/cabinet,
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
		/obj/structure/closet/mini_fridge/grimy = 1,
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
	spawn_loot_chance = 80
	loot = list(
		/obj/structure/barricade/wooden,
		/obj/structure/barricade/wooden/crude,
	)

/obj/effect/spawner/random/structure/billboard
	name = "billboard spawner"
	icon = 'icons/obj/fluff/billboard.dmi'
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
		/obj/structure/billboard/lizards_gas = 75,
		/obj/structure/billboard/lizards_gas/defaced = 25,
	)

/obj/effect/spawner/random/structure/billboard/roadsigns //also pretty much only unifunctionally useful for gas stations
	name = "\improper Gas Station billboard spawner"
	loot = list(
		/obj/structure/billboard/roadsign/two,
		/obj/structure/billboard/roadsign/twothousand,
		/obj/structure/billboard/roadsign/twomillion,
		/obj/structure/billboard/roadsign/error,
	)

/obj/effect/spawner/random/structure/steam_vent
	name = "steam vent spawner"
	loot = list(
		/obj/structure/steam_vent,
		/obj/structure/steam_vent/fast,
	)

/obj/effect/spawner/random/structure/musician/piano/random_piano
	name = "random piano spawner"
	icon_state = "piano"
	loot = list(
		/obj/structure/musician/piano,
		/obj/structure/musician/piano/minimoog,
	)

/obj/effect/spawner/random/structure/shipping_container
	name = "random shipping container spawner"
	icon = 'icons/obj/fluff/containers.dmi'
	icon_state = "random_container"
	loot = list(
		/obj/structure/shipping_container = 3,
		/obj/structure/shipping_container/amsco = 3,
		/obj/structure/shipping_container/blue = 3,
		/obj/structure/shipping_container/conarex = 3,
		/obj/structure/shipping_container/deforest = 3,
		/obj/structure/shipping_container/defaced = 3,
		/obj/structure/shipping_container/great_northern = 3,
		/obj/structure/shipping_container/green = 3,
		/obj/structure/shipping_container/kahraman = 2,
		/obj/structure/shipping_container/kahraman/alt = 1,
		/obj/structure/shipping_container/kosmologistika = 3,
		/obj/structure/shipping_container/magenta = 3,
		/obj/structure/shipping_container/nakamura = 3,
		/obj/structure/shipping_container/nanotrasen = 3,
		/obj/structure/shipping_container/ntfid = 2,
		/obj/structure/shipping_container/ntfid/defaced = 1,
		/obj/structure/shipping_container/nthi = 1,
		/obj/structure/shipping_container/nthi/minor = 1,
		/obj/structure/shipping_container/nthi/precious = 1,
		/obj/structure/shipping_container/orange = 3,
		/obj/structure/shipping_container/purple = 3,
		/obj/structure/shipping_container/red = 3,
		/obj/structure/shipping_container/sunda = 3,
		/obj/structure/shipping_container/vitezstvi = 2,
		/obj/structure/shipping_container/vitezstvi/flags = 1,
		/obj/structure/shipping_container/yellow = 3,
		/obj/structure/shipping_container/biosustain = 3,
		/obj/structure/shipping_container/cybersun = 2,
		/obj/structure/shipping_container/cybersun/defaced = 1,
		/obj/structure/shipping_container/donk_co = 3,
		/obj/structure/shipping_container/exagon = 1,
		/obj/structure/shipping_container/exagon/minor = 1,
		/obj/structure/shipping_container/exagon/precious = 1,
		/obj/structure/shipping_container/gorlex = 2,
		/obj/structure/shipping_container/gorlex/red = 1,
		/obj/structure/shipping_container/interdyne = 3,
		/obj/structure/shipping_container/oms = 3,
		/obj/structure/shipping_container/tiger_coop = 2,
		/obj/structure/shipping_container/tiger_coop = 1,
	)

/obj/effect/spawner/random/structure/shipping_container/blank
	name = "random blank shipping container spawner"
	loot = list(
		/obj/structure/shipping_container = 3,
		/obj/structure/shipping_container/blue = 3,
		/obj/structure/shipping_container/green = 3,
		/obj/structure/shipping_container/magenta = 3,
		/obj/structure/shipping_container/orange = 3,
		/obj/structure/shipping_container/purple = 3,
		/obj/structure/shipping_container/red = 3,
		/obj/structure/shipping_container/yellow = 3,
	)

/obj/effect/spawner/random/structure/syndicate //syndicate containers only
	name = "random syndicate shipping container spawner"
	loot = list(
		/obj/structure/shipping_container/biosustain = 3,
		/obj/structure/shipping_container/cybersun = 2,
		/obj/structure/shipping_container/cybersun/defaced = 1,
		/obj/structure/shipping_container/donk_co = 3,
		/obj/structure/shipping_container/exagon = 1,
		/obj/structure/shipping_container/exagon/minor = 1,
		/obj/structure/shipping_container/exagon/precious = 1,
		/obj/structure/shipping_container/gorlex = 2,
		/obj/structure/shipping_container/gorlex/red = 1,
		/obj/structure/shipping_container/interdyne = 3,
		/obj/structure/shipping_container/oms = 3,
		/obj/structure/shipping_container/tiger_coop = 2,
		/obj/structure/shipping_container/tiger_coop = 1,
	)

/obj/effect/spawner/random/structure/shipping_container/station_appropriate //places extra emphasis on NT containers, excludes syndicate companies (except Donk. Co.) entirely
	name = "station-appropriate shipping container spawner"
	loot = list(
		/obj/structure/shipping_container/nanotrasen = 5,
		/obj/structure/shipping_container/nthi = 1,
		/obj/structure/shipping_container/nthi/minor = 1,
		/obj/structure/shipping_container/nthi/precious = 1,
		/obj/structure/shipping_container/ntfid = 3,
		/obj/structure/shipping_container/nakamura = 2,
		/obj/structure/shipping_container/deforest = 2,
		/obj/structure/shipping_container/kosmologistika = 2,
		/obj/structure/shipping_container/donk_co = 2,
		/obj/structure/shipping_container/amsco = 1,
		/obj/structure/shipping_container/conarex = 1,
		/obj/structure/shipping_container/kahraman = 1,
		/obj/structure/shipping_container/kahraman/alt = 1,
		/obj/structure/shipping_container/sunda = 1,
		/obj/structure/shipping_container/vitezstvi = 1,
	)

/obj/effect/spawner/random/structure/shipping_container/reefer //reefers only
	name = "random reefer container spawner"
	loot = list(
		/obj/structure/shipping_container/reefer = 3,
		/obj/structure/shipping_container/reefer/biosustain = 3,
		/obj/structure/shipping_container/reefer/deforest = 3,
		/obj/structure/shipping_container/reefer/interdyne = 3,
	)

/obj/effect/spawner/random/structure/shipping_container/gas //gas cisterns only
	name = "random gas cistern spawner"
	loot = list(
		/obj/structure/shipping_container/gas = 3,
		/obj/structure/shipping_container/gas/apda = 3,
		/obj/structure/shipping_container/gas/apda/hydrogen = 3,
		/obj/structure/shipping_container/gas/exagon = 3,
		/obj/structure/shipping_container/gas/nthi = 3,
	)
