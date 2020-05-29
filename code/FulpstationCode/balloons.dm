/obj/item/toy/balloon/syndicate/gold
	name = "gold syndicate balloon"
	desc = "This is a balloon made out of pure gold. How it floats, nobody knows."
	random_color = FALSE
	icon = 'icons/fulpicons/phoenix_nest/balloon.dmi'
	icon_state = "syndballoongold"
	inhand_icon_state = "syndballoongold"
	lefthand_file = 'icons/fulpicons/phoenix_nest/balloons_lefthand.dmi'
	righthand_file = 'icons/fulpicons/phoenix_nest/balloons_righthand.dmi'

/obj/item/storage/box/syndieballoons
	name = "syndicate box"
	desc = "A sleek, sturdy box."
	icon_state = "syndiebox"

/obj/item/storage/box/syndieballoons/PopulateContents()
 new /obj/item/toy/balloon/syndicate/gold(src)
 new /obj/item/toy/balloon/syndicate/gold(src)
 new /obj/item/toy/balloon/syndicate/gold(src)
