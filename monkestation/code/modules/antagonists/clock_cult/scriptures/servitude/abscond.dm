/datum/scripture/abscond
	name = "Abscond"
	desc = "Recalls you and anyone you are dragging to reebe."
	tip = "If using this with a prisoner dont forget to cuff them first."
	button_icon_state = "Abscond"
	invocation_time = 3 SECONDS
	invocation_text = list("Return to our home, the city of cogs.")
	category = SPELLTYPE_SERVITUDE
	power_cost = 5

/datum/scripture/abscond/invoke_success()
	try_servant_warp(invoker, get_turf(pick(GLOB.abscond_markers)))

/proc/try_servant_warp(mob/living/servant, turf/target_turf)
	var/mob/living/pulled = servant.pulling
	playsound(servant, 'sound/magic/magic_missile.ogg', 50, TRUE) //doing this manually for sound volume reasons
	playsound(target_turf, 'sound/magic/magic_missile.ogg', 50, TRUE)
	do_sparks(3, TRUE, servant)
	do_sparks(3, TRUE, target_turf)
	do_teleport(servant, target_turf, 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
	if(ishuman(servant)) //looks weird on non-humanoids
		new /obj/effect/temp_visual/ratvar/warp(target_turf)
	to_chat(servant, "You warp to [get_area(target_turf)].")
	if(istype(pulled))
		do_teleport(pulled, target_turf, 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
		if(!IS_CLOCK(pulled))
			pulled.Paralyze(3 SECONDS)
			to_chat(pulled, span_warning("You feel sick and confused."))
