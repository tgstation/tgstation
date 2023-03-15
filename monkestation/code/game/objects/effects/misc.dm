/obj/effect/holy
	name = "holy"
	icon = 'monkestation/icons/effects/96x96.dmi'
	icon_state = "beamin"
	layer = ABOVE_MOB_LAYER
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = 0

/obj/effect/holy/Initialize()
	playsound(src,'monkestation/sound/misc/adminspawn.ogg',50,1)
	QDEL_IN(src, 20)
	..()
