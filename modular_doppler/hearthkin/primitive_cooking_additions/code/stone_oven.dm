#define OVEN_TRAY_Y_OFFSET -12

/obj/machinery/oven/stone
	name = "stone oven"
	desc = "Sorry buddy, all this stone used up the budget that would have normally gone to garfield comic jokes."
	icon = 'modular_doppler/hearthkin/primitive_cooking_additions/icons/stone_kitchen_machines.dmi'
	circuit = null
	use_power = FALSE

	/// A list of the different oven trays we can spawn with
	var/static/list/random_oven_tray_types = list(
		/obj/item/plate/oven_tray/material/fake_copper,
		/obj/item/plate/oven_tray/material/fake_brass,
		/obj/item/plate/oven_tray/material/fake_tin,
	)

/obj/machinery/oven/stone/Initialize(mapload)
	. = ..()

	if(!mapload)
		return

	if(used_tray) // We have to get rid of normal generic tray that normal ovens spawn with
		QDEL_NULL(used_tray)

	var/new_tray_type_to_use = pick(random_oven_tray_types)
	add_tray_to_oven(new new_tray_type_to_use(src))

/obj/machinery/oven/stone/examine(mob/user)
	. = ..()

	. += span_notice("It can be taken apart with a <b>crowbar</b>.")

// formerly NO_DECONSTRUCTION
/obj/machinery/oven/stone/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/oven/stone/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/oven/stone/default_pry_open(obj/item/crowbar, close_after_pry, open_density, closed_density)
	return NONE

/obj/machinery/oven/stone/add_tray_to_oven(obj/item/plate/oven_tray, mob/baker)
	used_tray = oven_tray

	if(!open)
		oven_tray.vis_flags |= VIS_HIDE
	vis_contents += oven_tray
	oven_tray.flags_1 |= IS_ONTOP_1
	oven_tray.vis_flags |= VIS_INHERIT_PLANE
	oven_tray.pixel_y = OVEN_TRAY_Y_OFFSET

	RegisterSignal(used_tray, COMSIG_MOVABLE_MOVED, PROC_REF(on_tray_moved))
	update_baking_audio()
	update_appearance()

/obj/machinery/oven/stone/set_smoke_state(new_state)
	. = ..()

	if(particles)
		particles.position = list(0, 10, 0)

/obj/machinery/oven/stone/crowbar_act(mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/oven/stone/on_deconstruction(disassembled)
	new /obj/item/stack/sheet/mineral/stone(drop_location(), 5)

#undef OVEN_TRAY_Y_OFFSET
