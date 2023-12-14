//Created during Divulge. Has a regenerating health pool and protects the darkspawn from harm.
/obj/structure/psionic_barrier
	name = "psionic barrier"
	desc = "Shimmering violet particles dancing in the air. They're impossible to move past."
	atom_integrity = 200
	max_integrity = 200
	icon = 'icons/effects/effects.dmi'
	icon_state = "purplesparkles"
	resistance_flags = FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	anchored = TRUE
	opacity = FALSE
	density = TRUE
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	light_color = "#21007F"
	light_power = 0.3
	light_range = 2

/obj/structure/psionic_barrier/Initialize(mapload, time = 500)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	QDEL_IN(src, time)

/obj/structure/psionic_barrier/Destroy()
	if(!atom_integrity)
		visible_message(span_warning("[src] vanishes in a burst of violet energy!"))
		playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 50, TRUE)
		new/obj/effect/temp_visual/revenant/cracks(get_turf(src))
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/psionic_barrier/process()
	atom_integrity = max(0, min(max_integrity, atom_integrity + 1))
