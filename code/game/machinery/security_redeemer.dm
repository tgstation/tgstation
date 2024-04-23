/obj/machinery/sec_redeemer
	name = "Redeemer"
	desc = "A large crushing machine used to recycle small items inefficiently. There are lights on the side."
	icon = 'icons/obj/medical/cryogenics.dmi'
	icon_state = "pod-off"
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/redeemer


/obj/machinery/sec_redeemer/Initialize(mapload)
	. = ..()

	register_context()


/obj/machinery/sec_redeemer/Destroy()
	on = FALSE

	vis_contents.Cut()
	QDEL_NULL(occupant_vis)


/obj/machinery/cryo_cell/on_deconstruction(disassembled)
	if(isnull(occupant))
		return

	occupant.vis_flags &= ~VIS_INHERIT_PLANE
	REMOVE_TRAIT(occupant, TRAIT_IMMOBILIZED, CRYO_TRAIT)
	REMOVE_TRAIT(occupant, TRAIT_FORCED_STANDING, CRYO_TRAIT)


/obj/machinery/sec_redeemer/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_LMB] = "Drag insert"

	return CONTEXTUAL_SCREENTIP_SET


/obj/machinery/sec_redeemer/update_icon()
	SET_PLANE_IMPLICIT(src, initial(plane))
	return ..()


/obj/machinery/sec_redeemer/update_icon_state()
	icon_state = state_open ? "pod-open" : ((on && is_operational) ? "pod-on" : "pod-off")
	return ..()


/obj/machinery/sec_redeemer/update_overlays()
	. = ..()
	if(panel_open)
		. += "pod-panel"
	if(state_open)
		return
	. += mutable_appearance('icons/obj/medical/cryogenics.dmi', "cover-[on && is_operational ? "on" : "off"]", ABOVE_ALL_MOB_LAYER, src, plane = ABOVE_GAME_PLANE)


/obj/machinery/sec_redeemer/set_occupant(atom/movable/new_occupant)
	. = ..()
	update_appearance()


/obj/machinery/cryo_cell/open_machine(drop = TRUE, density_to_set = FALSE)
	if(!state_open && !panel_open)
		set_on(FALSE)
	flick("pod-open-anim", src)
	return ..()


/obj/machinery/cryo_cell/close_machine(mob/living/carbon/user, density_to_set = TRUE)
	treating_wounds = FALSE
	if(state_open && !panel_open)
		flick("pod-close-anim", src)
		. = ..()
		if(!QDELETED(occupant)) //auto on if an occupant is inside
			set_on(TRUE)


/obj/machinery/sec_redeemer/proc/grind(mob/living/victim)
	update_use_power(ACTIVE_POWER_USE)
	audible_message(span_hear("You hear a loud squelchy grinding sound."))
	playsound(loc, 'sound/machines/juicer.ogg', 50, TRUE)

	victim.Paralyze(3)
	if(prob(10))
		INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob/living, emote), "scream")

	var/offset = prob(50) ? -5 : 5
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 250)

	addtimer(CALLBACK(src, PROC_REF(vaporize), victim), 2 SECONDS)


/obj/machinery/sec_redeemer/proc/vaporize(mob/living/victim)
	DSsecurity.add_new_criminal(victim)

	update_use_power(IDLE_POWER_USE)
	log_combat(victim, occupant, "redeemed")
	victim.investigate_log("has been redeemed by [src].", INVESTIGATE_DEATHS)
	victim.death(TRUE)
	victim.ghostize()
	qdel(victim)
