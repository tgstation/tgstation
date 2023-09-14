/obj/machinery/power/stomper
	name = "mechanical stomping unit"
	desc = "The power of techtonic shifts, in machine form."

	icon = 'goon/icons/obj/large/32x48.dmi'
	icon_state = "stomper0"
	base_icon_state = "stomper"

	density = TRUE
	anchored = FALSE

	use_power = FALSE // we suck power ourselves by either checking cell charge or wire connection

	///our inserted cell
	var/obj/item/stock_parts/cell/installed_cell
	///are we currently opened
	var/opened = FALSE
	///are we currently active
	var/on = FALSE
	///are we powered via a wire?
	var/powered = FALSE
	///the charge up time between stomps if set to automatic mode
	var/charge_up_time = 3 SECONDS
	///the cell power usage per stomp
	var/cell_usage = 30
	///are we in automatic mode
	var/automatic_mode = FALSE

	COOLDOWN_DECLARE(stomp_cd)


/obj/machinery/power/stomper/Initialize(mapload)
	. = ..()
	installed_cell = new(src)
	register_context()

/obj/machinery/power/stomper/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item)
		if(held_item.tool_behaviour == TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unsecure" : "Secure"
		if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = opened ? "Open Panel" : "Close Panel"

	if(!held_item && anchored)
		context[SCREENTIP_CONTEXT_LMB] = on ? "Turn On" : "Turn Off"

/obj/machinery/power/stomper/should_have_node()
	return anchored

/obj/machinery/power/stomper/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	opened = !opened
	to_chat(user, span_notice("You [opened ? "Open" : "Close"] the access panel on the [src]."))
	toggle_power(FALSE)
	return TRUE

/obj/machinery/power/stomper/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	set_anchored(!anchored)
	return TRUE

/obj/machinery/power/stomper/proc/toggle_power(state)
	on = state
	if(on)
		START_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSmachines, src)
	update_appearance()

/obj/machinery/power/stomper/update_icon_state()
	. = ..()
	icon_state = "stomper[on]"

/obj/machinery/power/stomper/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!opened && anchored)
		to_chat(user, span_notice("You turn the [src] [on ? "Off" : "On"]"))
		toggle_power(!on)

/obj/machinery/power/stomper/crowbar_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!opened || !installed_cell)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	installed_cell.forceMove(get_turf(src))
	installed_cell = null
	to_chat(user, span_notice("You remove the [installed_cell] from the [src]."))
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/power/stomper/attacked_by(obj/item/attacking_item, mob/living/user)
	if(!opened || installed_cell)
		return ..()
	if(!istype(attacking_item, /obj/item/stock_parts/cell))
		return ..()
	attacking_item.forceMove(src)
	installed_cell = attacking_item

/obj/machinery/power/stomper/process()
	if(!on || !anchored)
		toggle_power(FALSE)
		return

	if(!powered && !installed_cell)
		return

	if(powered)
		if((surplus() >= cell_usage) && !installed_cell)
			add_load(cell_usage)

		if(surplus() < cell_usage)
			toggle_power(FALSE)
			if(!installed_cell)
				return

	if(!COOLDOWN_FINISHED(src, stomp_cd))
		return

	if(installed_cell)
		if(!installed_cell.use(cell_usage))
			toggle_power(FALSE)
			return

	COOLDOWN_START(src, stomp_cd, 10 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(stomp)), charge_up_time)


/obj/machinery/power/stomper/proc/stomp()
	flick("stomper2", src)
	var/turf/source_turf = get_turf(src)

	///we missed center here
	if(SShotspots.stomp(source_turf))
		playsound(src, 'goon/sounds/impact_sounds/Metal_Hit_Heavy_1.ogg', 100, 1)

	for(var/datum/hotspot/listed_hotspot as anything in SShotspots.retrieve_hotspot_list(source_turf))
		if(BOUNDS_DIST(src, listed_hotspot.center.return_turf()) > 1)///giving a 1 tile leeway on stomps
			continue
		say("Hotspot Pinned")
	playsound(src, 'goon/sounds/impact_sounds/Metal_Hit_Lowfi_1.ogg', 50, 1)

	for(var/mob/any_mob in viewers(src))
		shake_camera(any_mob, 4, 6)

	if(!automatic_mode)
		STOP_PROCESSING(SSmachines, src)
