///modified IV that can be anchored and takes plumbing in- and output
/obj/machinery/iv_drip/plumbing
	name = "automated IV drip"
	desc = "A modified IV drip with plumbing connects. Reagents received from the connect are injected directly into their bloodstream, blood that is drawn goes to the internal storage and then into the ducting."
	icon_state = "plumb"
	base_icon_state = "plumb"
	density = TRUE
	use_internal_storage = TRUE

/obj/machinery/iv_drip/plumbing/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/plumbing/iv_drip, anchored)
	AddComponent(/datum/component/simple_rotation)

/obj/machinery/iv_drip/plumbing/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(attached)
		context[SCREENTIP_CONTEXT_RMB] = "Take needle out"
	else if(reagent_container && !use_internal_storage)
		context[SCREENTIP_CONTEXT_RMB] = "Eject container"
	else if(!inject_only)
		context[SCREENTIP_CONTEXT_RMB] = "Change direction"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/iv_drip/plumbing/plunger_act(obj/item/plunger/P, mob/living/user, reinforced)
	to_chat(user, span_notice("You start furiously plunging [name]."))
	if(do_after(user, 30, target = src))
		to_chat(user, span_notice("You finish plunging the [name]."))
		reagents.expose(get_turf(src), TOUCH) //splash on the floor
		reagents.clear_reagents()

/obj/machinery/iv_drip/plumbing/can_use_alt_click(mob/user)
	return FALSE //Alt click is used for rotation

/obj/machinery/iv_drip/plumbing/wrench_act(mob/living/user, obj/item/tool)
	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		return ITEM_INTERACT_SUCCESS

/obj/machinery/iv_drip/plumbing/deconstruct(disassembled = TRUE)
	qdel(src)
