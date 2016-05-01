/obj/effect/overlay/temp/point
	name = "pointer"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "arrow"
	layer = 16
	duration = 25

/obj/effect/overlay/temp/point/New(loc, set_invis = 0)
	..()
	invisibility = set_invis

// Used for spray that you spray at walls, tables, hydrovats etc
/obj/effect/decal/spraystill
	density = 0
	layer = 50

//Used by spraybottles.
/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE
	layer = 5