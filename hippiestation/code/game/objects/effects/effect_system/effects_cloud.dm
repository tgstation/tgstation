/obj/effect/cloud
	name = "cloud"
	icon = 'hippiestation/icons/effects/32x32.dmi'
	layer = 16

/obj/effect/cloud/New()
	..(loc)
	playsound(loc, 'hippiestation/sound/voice/meeseeksspawn.ogg', 40)
	icon_state = "smoke"
	QDEL_IN(src, 12)