/obj/machinery/primitive_stove
	name = "stone stove"
	desc = "You think you'll stick to just putting pots on this, the grill part looks very unsanitary."
	icon = 'modular_doppler/hearthkin/primitive_cooking_additions/icons/stone_kitchen_machines.dmi'
	icon_state = "stove_off"
	base_icon_state = "stove"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	layer = BELOW_OBJ_LAYER
	use_power = FALSE
	circuit = null
	resistance_flags = FIRE_PROOF

/obj/machinery/primitive_stove/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/cup/soup_pot/mapload_container
	if(mapload)
		mapload_container = new(loc)

	AddComponent(/datum/component/stove/primitive, container_x = -7, container_y = 7, spawn_container = mapload_container)

/obj/machinery/primitive_stove/examine(mob/user)
	. = ..()

	. += span_notice("It can be taken apart with a <b>crowbar</b>.")

// formerly NO_DECONSTRUCTION
/obj/machinery/primitive_stove/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/screwdriver)
	return NONE

/obj/machinery/primitive_stove/default_deconstruction_crowbar(obj/item/crowbar, ignore_panel, custom_deconstruct)
	return NONE

/obj/machinery/primitive_stove/crowbar_act(mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/primitive_stove/on_deconstruction(disassembled)
	new /obj/item/stack/sheet/mineral/stone(drop_location(), 5)

/// Stove component subtype with changed visuals and not much else
/datum/component/stove/primitive
	flame_color = "#ff9900"

/datum/component/stove/primitive/on_overlay_update(obj/machinery/source, list/overlays)
	update_smoke()

	var/obj/real_parent = parent

	if(!on)
		real_parent.icon_state = "[real_parent.base_icon_state]_off" // Not an overlay but do you really want me to override a second proc? I don't
		real_parent.set_light(0, 0)
		return

	real_parent.icon_state = "[real_parent.base_icon_state]_on"
	real_parent.set_light(3, 1, LIGHT_COLOR_FIRE)

	overlays += emissive_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_fire_emissive", real_parent, alpha = real_parent.alpha)

	if(!container)
		overlays += emissive_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_hole_emissive", real_parent, alpha = real_parent.alpha)

	// Flames around the pot
	var/mutable_appearance/flames = mutable_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_flame", alpha = real_parent.alpha)
	flames.color = flame_color
	overlays += flames
	overlays += emissive_appearance(real_parent.icon, "[real_parent.base_icon_state]_on_flame", real_parent, alpha = real_parent.alpha)
