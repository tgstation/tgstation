/obj/effect/decal/point
	name = "arrow"
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "arrow"
	layer = ABSTRACT_LAYER
	anchored = 1
	mouse_opacity = 0

// Used for spray that you spray at walls, tables, hydrovats etc
/obj/effect/decal/spraystill
	density = 0
	anchored = 1
	layer = SPECIAL_EFFECT_LAYER

//Used by spraybottles.
/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE