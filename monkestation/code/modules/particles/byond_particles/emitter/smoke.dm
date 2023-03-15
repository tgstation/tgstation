/obj/emitter/fire_smoke
	alpha = 150
	particles = new/particles/fire_smoke

/obj/emitter/fire_smoke/Initialize(mapload)
	. = ..()
	add_filter("blur", 1, list(type="blur", size=3))


/obj/emitter/flare_smoke
	particles = new/particles/smoke
	layer = OBJ_LAYER

/obj/emitter/flare_smoke/Initialize(mapload, time, _color)
	. = ..()
	add_filter("blur", 1, list(type="blur", size=1.5))
