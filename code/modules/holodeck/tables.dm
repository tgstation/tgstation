/obj/structure/table/holo
	name = "table"
	frame = null
	buildstackamount = 0
	framestackamount = 0
	canSmoothWith = null

/obj/structure/table/holo/glass
	name = "glass table"
	icon = 'icons/obj/smooth_structures/glass_table.dmi'
	icon_state = "glass_table"

/obj/structure/table/holo/wood
	name = "wood table"
	icon = 'icons/obj/smooth_structures/wood_table.dmi'
	icon_state = "wood_table"
	canSmoothWith = list(/obj/structure/table/holo/wood, /obj/structure/table/holo/poker)

/obj/structure/table/holo/poker
	name = "poker table"
	icon = 'icons/obj/smooth_structures/poker_table.dmi'
	icon_state = "poker_table"
	canSmoothWith = list(/obj/structure/table/holo/wood, /obj/structure/table/holo/poker)

