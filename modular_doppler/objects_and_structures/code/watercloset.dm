/obj/structure/sink/attackby(obj/item/attacking_item, mob/living/user, params)
	if(busy)
		to_chat(user, span_warning("Someone's already washing here!"))
		return

	if(istype(attacking_item, /obj/item/towel))
		if(reagents.total_volume <= 0)
			to_chat(user, span_notice("\The [src] is dry."))
			return FALSE

		busy = TRUE
		user.visible_message(span_notice("[user] starts washing [attacking_item] in [src]."), span_notice("You start washing [attacking_item] in [src]."))

		if(!do_after(user, 2 SECONDS, src))
			busy = FALSE
			to_chat(user, span_warning("You take [attacking_item] away from [src] before you're done washing it."))
			return FALSE

		var/obj/item/towel/washed_towel = attacking_item

		washed_towel.reagents.remove_all(washed_towel.reagents.total_volume)
		washed_towel.transfer_reagents_to_towel(reagents, washed_towel.reagents.maximum_volume, user)

		washed_towel.set_wet(TRUE)
		washed_towel.make_used(user, silent = TRUE)

		begin_reclamation()
		user.visible_message(span_notice("[user] finishes washing [attacking_item] in [src]."), span_notice("You finish washing [washed_towel] in [src], leaving it quite wet."))
		playsound(loc, 'sound/effects/slosh.ogg', 25, TRUE)

		busy = FALSE

	else
		return ..()

