///modified IV that can be anchored and takes plumbing in- and output
/obj/machinery/iv_drip/plumbing
	name = "automated IV drip"
	desc = "A modified IV drip with plumbing connects. Reagents received from the connect are injected directly into their bloodstream, blood that is drawn goes to the internal storage and then into the ducting."
	icon_state = "plumb"
	base_icon_state = "plumb"
	density = TRUE
	use_internal_storage = TRUE
	processing_flags = START_PROCESSING_MANUALLY

/obj/machinery/iv_drip/plumbing/Initialize(mapload, bolt, layer)
	. = ..()
	AddComponent(/datum/component/plumbing/simple_demand, bolt, layer)
	AddComponent(/datum/component/simple_rotation)

/obj/machinery/iv_drip/plumbing/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(attachment)
		context[SCREENTIP_CONTEXT_RMB] = "Take needle out"
	else if(reagent_container && !use_internal_storage)
		context[SCREENTIP_CONTEXT_RMB] = "Eject container"
	else if(!inject_only)
		context[SCREENTIP_CONTEXT_RMB] = "Change direction"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/iv_drip/plumbing/plunger_act(obj/item/plunger/attacking_plunger, mob/living/user, reinforced)
	user.balloon_alert_to_viewers("furiously plunging...", "plunging iv drip...")
	if(do_after(user, 3 SECONDS, target = src))
		user.balloon_alert_to_viewers("finished plunging")
		reagents.expose(get_turf(src), TOUCH) //splash on the floor
		reagents.clear_reagents()

/obj/machinery/iv_drip/plumbing/wrench_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return NONE

	. = ITEM_INTERACT_BLOCKING
	if(default_unfasten_wrench(user, tool) == SUCCESSFUL_UNFASTEN)
		if(anchored)
			begin_processing()
		else
			end_processing()
		return ITEM_INTERACT_SUCCESS
