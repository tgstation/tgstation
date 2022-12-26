/obj/effect/spawner/random/decoration
	name = "decoration loot spawner"
	desc = "Time for some bling bling."
	icon_state = "lamp"

/obj/effect/spawner/random/decoration/material
	name = "decoration material spawner"
	icon_state = "tile"
	loot = list(
		/obj/item/stack/sheet/sandblock{amount = 30} = 25,
		/obj/item/stack/sheet/mineral/wood{amount = 30} = 25,
		/obj/item/stack/sheet/bronze/thirty = 20,
		/obj/item/stack/tile/noslip{amount = 20} = 10,
		/obj/item/stack/sheet/plastic{amount = 30} = 10,
		/obj/item/stack/tile/pod{amount = 20} = 4,
		/obj/item/stack/tile/pod/light{amount = 20} = 3,
		/obj/item/stack/tile/pod/dark{amount = 20} = 3,
	)

/obj/effect/spawner/random/decoration/carpet
	name = "carpet spawner"
	icon_state = "carpet"
	loot = list(
		/obj/item/stack/tile/carpet{amount = 30} = 35,
		/obj/item/stack/tile/carpet/black{amount = 30} = 20,
		/obj/item/stack/tile/carpet/donk/thirty = 15,
		/obj/item/stack/tile/carpet/stellar/thirty = 15,
		/obj/item/stack/tile/carpet/executive/thirty = 15,
	)

/obj/effect/spawner/random/decoration/ornament
	name = "ornament spawner"
	icon_state = "lamp"
	loot = list(
		/obj/item/flashlight/lamp = 35,
		/obj/item/flashlight/lamp/green = 35,
		/obj/item/flashlight/lantern = 10,
		/obj/item/phone = 10,
		/obj/item/flashlight/lantern/jade = 5,
		/obj/item/flashlight/lamp/bananalamp = 5,
	)

/obj/effect/spawner/random/decoration/generic
	name = "generic decoration spawner"
	icon_state = "sandstone"
	loot = list(
		/obj/effect/spawner/random/decoration/ornament = 35,
		/obj/effect/spawner/random/decoration/carpet = 25,
		/obj/effect/spawner/random/decoration/material = 25,
	)

/obj/effect/spawner/random/decoration/statue
	name = "statue spawner"
	icon_state = "statue"
	loot = list(
		/obj/structure/statue/bronze/marx = 50,
		/obj/item/statuebust = 50,
		/obj/item/statuebust/hippocratic = 50,
		/obj/structure/statue/sandstone/assistant = 50,
		/obj/structure/statue/sandstone/venus = 50,
		/obj/structure/statue/silver/md = 20,
		/obj/structure/statue/silver/janitor = 20,
		/obj/structure/statue/silver/sec = 20,
		/obj/structure/statue/silver/secborg = 20,
		/obj/structure/statue/silver/medborg = 20,
		/obj/structure/statue/plasma/scientist = 15,
		/obj/structure/statue/plasma/xeno = 15,
		/obj/structure/statue/gold/hos = 5,
		/obj/structure/statue/gold/hop = 5,
		/obj/structure/statue/gold/cmo = 5,
		/obj/structure/statue/gold/ce = 5,
		/obj/structure/statue/gold/rd = 5,
		/obj/structure/statue/gold/qm = 5,
		/obj/structure/statue/bananium/clown = 1,
		/obj/structure/statue/elder_atmosian = 1,
		/obj/structure/statue/uranium/nuke = 1,
		/obj/structure/statue/uranium/eng = 1,
		/obj/structure/statue/diamond/captain = 1,
		/obj/structure/statue/diamond/ai1 = 1,
		/obj/structure/statue/diamond/ai2 = 1,
	)

/obj/effect/spawner/random/decoration/statue/make_item(spawn_loc, type_path_to_make)
	var/obj/structure/statue/statue = ..()
	if(istype(statue))
		statue.set_anchored(TRUE)

	return statue

/obj/effect/spawner/random/decoration/showcase
	name = "showcase spawner"
	icon_state = "showcase"
	loot_type_path = /obj/structure/showcase
	loot = list()

/obj/effect/spawner/random/decoration/glowstick
	name = "random colored glowstick"
	icon_state = "glowstick"
	loot = list(
		/obj/item/flashlight/glowstick,
		/obj/item/flashlight/glowstick/red,
		/obj/item/flashlight/glowstick/blue,
		/obj/item/flashlight/glowstick/cyan,
		/obj/item/flashlight/glowstick/orange,
		/obj/item/flashlight/glowstick/yellow,
		/obj/item/flashlight/glowstick/pink,
	)

/obj/effect/spawner/random/decoration/paint
	name = "paint spawner"
	icon_state = "paint"
	loot_subtype_path = /obj/item/paint
	loot = list()

/obj/effect/spawner/random/decoration/flower
	name = "random flower spawner"
	icon_state = "flower"
	loot = list(
		/obj/item/food/grown/poppy,
		/obj/item/food/grown/harebell,
		/obj/item/food/grown/trumpet,
		/obj/item/food/grown/sunflower,
		/obj/item/food/grown/rose,
	)
