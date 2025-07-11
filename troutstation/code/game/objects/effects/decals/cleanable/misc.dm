/obj/effect/decal/cleanable/ants/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(isanteater(user))
		if(!lazy_init_reagents())
			to_chat(user, span_notice("[src] aren't worth the effort."))
			return
		user.visible_message(span_notice("[user] sticks [user.p_their()] snout in the [src]."),
							 span_notice("You stick your snout in the anthill..."),
							 span_notice("You hear an anteater snorfling and slurping."))
		if(!do_after(user, 2 SECONDS, target = src))
			return
		user.visible_message(span_notice("[user] pulls back [user.p_their()] tongue, and [src] is gone."),
							 span_notice("You slurp up all the ants you can find."),
							 span_notice("You hear an anteater's slurping come to an end."))
		reagents.trans_to(user, amount = reagent_amount, target_id = decal_reagent, methods = INGEST, show_message = FALSE)
		qdel(src)
