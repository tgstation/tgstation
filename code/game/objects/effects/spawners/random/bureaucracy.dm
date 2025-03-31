/obj/effect/spawner/random/bureaucracy
	name = "bureaucracy loot spawner"
	desc = "For the exotic art of paper shuffling."

/obj/effect/spawner/random/bureaucracy/pen
	name = "pen spawner"
	icon_state = "pen"
	loot = list(
		/obj/item/pen = 30,
		/obj/item/pen/blue = 5,
		/obj/item/pen/red = 5,
		/obj/item/flashlight/pen = 5,
		/obj/item/pen/fourcolor = 2,
		/obj/item/flashlight/pen/paramedic = 2,
		/obj/item/pen/fountain = 1,
	)

/obj/effect/spawner/random/bureaucracy/stamp
	name = "stamp spawner"
	icon_state = "stamp"
	loot = list(
		/obj/item/stamp = 3,
		/obj/item/stamp/denied = 1,
	)

/obj/effect/spawner/random/bureaucracy/crayon
	name = "crayon spawner"
	icon_state = "crayon"
	loot = list(
		/obj/item/toy/crayon/red,
		/obj/item/toy/crayon/orange,
		/obj/item/toy/crayon/yellow,
		/obj/item/toy/crayon/green,
		/obj/item/toy/crayon/blue,
		/obj/item/toy/crayon/purple,
		/obj/item/toy/crayon/black,
		/obj/item/toy/crayon/white,
	)

/obj/effect/spawner/random/bureaucracy/paper
	name = "paper spawner"
	icon_state = "paper"
	loot = list(
		/obj/item/paper = 20,
		/obj/item/paper/crumpled = 2,
		/obj/item/paper/crumpled/bloody = 2,
		/obj/item/paper/crumpled/muddy = 2,
		/obj/item/paper/construction = 1,
		/obj/item/paper/carbon = 1,
	)

/obj/effect/spawner/random/bureaucracy/briefcase
	name = "briefcase spawner"
	icon_state = "briefcase"
	loot = list(
		/obj/item/storage/briefcase = 3,
		/obj/item/storage/briefcase/secure = 1,
	)

/obj/effect/spawner/random/bureaucracy/folder
	name = "folder spawner"
	icon_state = "folder"
	loot = list(
		/obj/item/folder/blue,
		/obj/item/folder/red,
		/obj/item/folder/yellow,
		/obj/item/folder/white,
		/obj/item/folder,
	)

/obj/effect/spawner/random/bureaucracy/birthday_wrap
	name = "additional wrapping paper spawner"
	icon_state = "wrapping_paper"
	spawn_all_loot = TRUE
	loot = list(
		/obj/item/stack/wrapping_paper,
		/obj/item/stack/wrapping_paper,
		/obj/item/stack/wrapping_paper,
	)

/obj/effect/spawner/random/bureaucracy/birthday_wrap/Initialize(mapload)
	if(!HAS_TRAIT(SSstation, STATION_TRAIT_BIRTHDAY))
		spawn_loot_chance = 0
	return ..()
