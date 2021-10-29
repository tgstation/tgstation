/obj/effect/immovablerod/Bump(atom/clong)
	var/should_self_destroy = FALSE
	if(istype(clong, /obj/machinery/rodstopper))
		should_self_destroy = TRUE
	. = ..()
	if(should_self_destroy)

		visible_message(span_boldwarning("The rod tears into the rodstopper with a reality-rending screech!"))
		playsound(src.loc,'sound/effects/supermatter.ogg', 200, TRUE)
		visible_message(span_boldwarning("You have five seconds to move away before the localized reality-collapse!"))
		new/obj/boh_tear(src.loc)
		qdel(src)
