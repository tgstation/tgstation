/obj/effect/decal/cleanable/ants/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(isanteater(user))
		var/mob/living/carbon/anteater = user
		if(anteater.is_mouth_covered())
			anteater.balloon_alert(anteater, "snout is covered!")
			return FALSE
		if(!lazy_init_reagents())
			to_chat(anteater, span_notice("[src] aren't worth the effort."))
			return
		anteater.visible_message(span_notice("[anteater] sticks [anteater.p_their()] snout in the [src]."),
							 span_notice("You stick your snout in the anthill..."),
							 span_notice("You hear an anteater snorfling and slurping."))
		if(!do_after(user, 2 SECONDS, target = src))
			return
		anteater.visible_message(span_notice("[anteater] pulls back [anteater.p_their()] tongue, and [src] is gone."),
							 span_notice("You slurp up all the ants you can find."),
							 span_notice("You hear an anteater's slurping come to an end."))
		reagents.trans_to(anteater, amount = reagent_amount, target_id = decal_reagent, methods = INGEST, show_message = FALSE)
		qdel(src)
