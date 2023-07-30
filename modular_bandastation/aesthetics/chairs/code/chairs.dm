/obj/structure/chair/comfy
	icon = 'modular_bandastation/aesthetics/chairs/icons/chairs.dmi'

/obj/structure/chair/comfy/GetArmrest()
	return mutable_appearance('modular_bandastation/aesthetics/chairs/icons/chairs.dmi', "[icon_state]_armrest")

/obj/structure/chair/comfy/corp
	icon = 'icons/obj/chairs.dmi'

/obj/structure/chair/comfy/shuttle
	icon = 'icons/obj/chairs.dmi'

/obj/structure/chair/office/dark
	icon = 'modular_bandastation/aesthetics/chairs/icons/chairs.dmi'

/obj/structure/chair/office/light
	icon = 'modular_bandastation/aesthetics/chairs/icons/chairs.dmi'

/obj/structure/chair/e_chair
	icon = 'modular_bandastation/aesthetics/chairs/icons/chairs.dmi'

//TODO: Support or chairs

/obj/item/chair/stool/bar/dark
	icon = 'modular_bandastation/aesthetics/chairs/icons/chairs.dmi'
	icon_state = "bar_toppled_dark"
	item_state = "stool_bar_dark"
	origin_type = /obj/structure/chair/stool/bar/dark
	lefthand_file = 'modular_bandastation/aesthetics/chairs/icons/chairs_lefthand.dmi'
	righthand_file = 'modular_bandastation/aesthetics/chairs/icons/chairs_righthand.dmi'

/obj/structure/chair/stool/bar/dark
	icon = 'modular_bandastation/aesthetics/chairs/icons/chairs.dmi'
	icon_state = "bar_dark"
	item_chair = /obj/item/chair/stool/bar/dark
