/obj/effect/portal/permanent/one_way/reebe
	name = "whirring portal"
	desc = "A tall, glowing portal. A low emination of moving cogs can be heard. You don't feel like coming back will be the easiest."
	id = "reebe_entry"
	color = "#fcbe03"


/obj/effect/portal/permanent/one_way/reebe/clock_only // Portal that only lets clock cultists through, so they get their head start.
	name = "loudly whirring portal"
	/// If this prevents non-clockies from entering
	var/clock_only = TRUE


/obj/effect/portal/permanent/one_way/reebe/clock_only/teleport(atom/movable/movable, force)
	if(!ismob(movable))
		return FALSE

	var/mob/movable_mob = movable

	if(!IS_CLOCK(movable_mob) && clock_only && !isobserver(movable_mob))
		to_chat(movable_mob, span_warning("An invisble force pushes you back as you try to approach [src]!"))
		return FALSE

	return ..()


/obj/effect/portal/permanent/one_way/reebe/leaving
	desc = "For those who wish or require to leave the holy outpost."
	id = "reebe_exit"


/obj/effect/portal/permanent/one_way/reebe/leaving/set_linked()
	hard_target = get_safe_random_station_turf()


/obj/effect/portal/permanent/one_way/reebe/leaving/teleport(atom/movable/movable, force)
	to_chat(movable, span_notice("You prepare yourself to enter [src]..."))

	if(!do_after(movable, 4 SECONDS))
		return FALSE

	return ..()
