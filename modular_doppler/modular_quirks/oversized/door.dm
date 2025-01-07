/obj/machinery/door/airlock/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/machinery/door/airlock/proc/on_entered(datum/source, atom/movable/crossed_atom)
	SIGNAL_HANDLER
	if(!HAS_TRAIT(crossed_atom, TRAIT_OVERSIZED))
		return
	if(!ishuman(crossed_atom))
		return
	var/mob/living/carbon/human/crossing_human = crossed_atom
	if(crossing_human.move_intent != MOVE_INTENT_WALK && crossing_human.body_position == STANDING_UP)
		//We gonna bamf you, you tall fucker
		var/affecting = crossing_human.get_bodypart(BODY_ZONE_HEAD)
		crossing_human.apply_damage(15, BRUTE, affecting)
		crossing_human.Knockdown(20)
		crossing_human.visible_message(span_warning("[crossing_human] slams their head into the frame of [src] with a sickening thud!"), \
			span_userdanger("You slam your head against [src]!"))
		playsound(crossed_atom, 'sound/effects/bang.ogg', 50, TRUE)
