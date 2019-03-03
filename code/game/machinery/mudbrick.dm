/obj/structure/mudbricks
	name = "mud brick wall"
	desc = "Made out of clods like you."
	icon = 'icons/obj/structures.dmi'
	icon_state = "mudbrick"
	CanAtmosPass = ATMOS_PASS_NO
	anchored = TRUE
	density = TRUE
	opacity = TRUE
	var/hastorch = FALSE

/obj/structure/mudbricks/attackby(obj/item/I, mob/user)
	if(istype(I,/obj/item/flashlight/flare/torch) && hastorch == FALSE)
		hastorch = TRUE
		icon_state = "mudbrick-torch"
		set_light(l_range = 7, l_power =1)
		qdel(I)
		user.regenerate_icons()
	else
		..()

/obj/structure/mudbricks/torch
	hastorch = TRUE
	icon_state = "mudbrick-torch"

obj/structure/mudbricks/torch/Initialize()
	..()
	set_light(l_range = 7, l_power =1)

/obj/structure/mudbricks/Destroy()
	new /obj/item/stack/sheet/mineral/mudbrick(get_turf(src), rand(3,5))
	if(hastorch == TRUE)
		new /obj/item/flashlight/flare/torch(get_turf(src))
	return ..()