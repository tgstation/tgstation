#define MAX_PLASMA_SHEETS 50
#define MIN_PLASMA_SHEETS_TO_WORK (MAX_PLASMA_SHEETS / 2)

/obj/machinery/weather_remover
	name = "plasma-fuelled weather barrier"
	desc = "A top-of-the-line experiment using plasma as fuel to surgically cut holes in the atmospheric layer to suck ash storms away."
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "plasmabarrier"
	base_icon_state = "plasmabarrier"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/weather_remover
	use_power = NO_POWER_USE

	///Boolean on whether the machine is currently working.
	var/activated = FALSE
	///Amount of sheets of plasma is currently in the machine.
	var/sheets_of_plasma

/obj/machinery/weather_remover/Initialize(mapload)
	. = ..()
	register_context()

/obj/machinery/weather_remover/Destroy(force)
	if(activated)
		UnregisterSignal(SSdcs, list(COMSIG_WEATHER_TELEGRAPH(/datum/weather/ash_storm)))
	return ..()

/obj/machinery/weather_remover/examine(mob/user)
	. = ..()
	. += span_notice("It has [sheets_of_plasma] sheets of plasma stored in it. It costs 25 sheets of plasma per storm.")

/obj/machinery/weather_remover/on_set_is_operational(was_operational)
	if(was_operational && activated)
		deactivate()

/obj/machinery/weather_remover/update_appearance(updates=ALL)
	. = ..()
	if((machine_stat & BROKEN) || !activated)
		set_light(0)
		return
	set_light(l_range = 1.5, l_power = 2, l_color = COLOR_THEME_PLASMAFIRE)

/obj/machinery/weather_remover/update_overlays()
	. = ..()
	if((machine_stat & BROKEN) || !activated)
		return
	. += "[base_icon_state]-on"
	return .

/obj/machinery/weather_remover/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_LMB] = activated ? "Deactivate" : "Activate"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/stack/sheet/mineral/plasma))
		context[SCREENTIP_CONTEXT_LMB] = "Insert Plasma Sheets"

	if(panel_open)
		switch(held_item.tool_behaviour)
			if(TOOL_SCREWDRIVER)
				context[SCREENTIP_CONTEXT_LMB] = "Close Panel"
			if(TOOL_WRENCH)
				context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unanchor" : "Anchor"
			if(TOOL_CROWBAR)
				context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
	else if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "Open Panel"

	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/weather_remover/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(panel_open)
		balloon_alert(user, "close panel first!")
		return
	if(!anchored)
		balloon_alert(user, "unanchored!")
		return
	if(sheets_of_plasma < MIN_PLASMA_SHEETS_TO_WORK)
		balloon_alert(user, "not enough plasma!")
		return
	activated = !activated
	if(activated)
		balloon_alert(user, "activated")
		RegisterSignal(SSdcs, COMSIG_WEATHER_TELEGRAPH(/datum/weather/ash_storm), PROC_REF(on_storm_start))
	else
		balloon_alert(user, "deactivated")
		UnregisterSignal(SSdcs, list(COMSIG_WEATHER_TELEGRAPH(/datum/weather/ash_storm)))
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/weather_remover/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stack/sheet/mineral/plasma) || user.combat_mode || tool.flags_1 & HOLOGRAM_1 || tool.item_flags & ABSTRACT)
		return ITEM_INTERACT_SKIP_TO_ATTACK
	if(sheets_of_plasma >= MAX_PLASMA_SHEETS)
		balloon_alert(user, "machine full!")
		return ITEM_INTERACT_BLOCKING
	var/obj/item/stack/sheet/mineral/plasma/attacking_plasma = tool
	var/amount_used
	for(var/i in 1 to attacking_plasma.amount)
		if((sheets_of_plasma + amount_used) >= MAX_PLASMA_SHEETS) //maxed out
			break
		amount_used++
	if(attacking_plasma.use(amount_used))
		sheets_of_plasma += amount_used
	playsound(src, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
	balloon_alert(user, "sheets inserted")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/weather_remover/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/weather_remover/can_be_unfasten_wrench(mob/user, silent)
	if(activated)
		balloon_alert(user, "turn off first!")
		return FAILED_UNFASTEN
	if(!panel_open)
		balloon_alert(user, "open panel first!")
		return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN //don't call parent as they won't let us anchor onto basalt.

/obj/machinery/weather_remover/screwdriver_act(mob/living/user, obj/item/tool)
	if(activated)
		balloon_alert(user, "turn off first!")
		return ITEM_INTERACT_BLOCKING
	if(default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/weather_remover/crowbar_act(mob/living/user, obj/item/tool)
	if(activated)
		balloon_alert(user, "turn off first!")
		return ITEM_INTERACT_BLOCKING
	if(default_deconstruction_crowbar(tool))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/weather_remover/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	playsound(src, SFX_SPARKS, 50, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/weather_remover/proc/on_storm_start(datum/controller/subsystem/processing/dcs/source, datum/weather/ash_storm/storm)
	SIGNAL_HANDLER
	if(!(z in storm.impacted_z_levels) || (obj_flags & EMAGGED))
		return
	if(!activated)
		CRASH("[src] called on_storm_start but isn't activated, they shouldn't be listening to any signal to call this!")
	playsound(src, 'sound/items/night_vision_on.ogg', 30, TRUE, -3) //honestly just a cool sfx that i thought fit
	Shake(duration = 2 SECONDS)
	sheets_of_plasma -= MIN_PLASMA_SHEETS_TO_WORK
	if(sheets_of_plasma < MIN_PLASMA_SHEETS_TO_WORK) //not enough to go a second time.
		deactivate()
	return CANCEL_WEATHER_TELEGRAPH

/obj/machinery/weather_remover/proc/deactivate()
	UnregisterSignal(SSdcs, list(COMSIG_WEATHER_TELEGRAPH(/datum/weather/ash_storm)))
	activated = FALSE
	update_appearance(UPDATE_OVERLAYS)

#undef MAX_PLASMA_SHEETS
#undef MIN_PLASMA_SHEETS_TO_WORK
