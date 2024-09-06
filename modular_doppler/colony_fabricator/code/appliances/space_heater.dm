/obj/machinery/space_heater/wall_mounted
	name = "mounted heater"
	desc = "A compact heating and cooling device for small scale applications, made to mount onto walls up and out of the way. \
		Like other, more free-standing space heaters however, these still require cell power to function."
	icon = 'modular_doppler/colony_fabricator/icons/space_heater.dmi'
	anchored = TRUE
	density = FALSE
	circuit = null
	heating_energy = parent_type::heating_energy * 2
	efficiency = parent_type::efficiency * 2
	display_panel = TRUE
	cell = null
	/// What this repacks into when it's wrenched off a wall
	var/repacked_type = /obj/item/wallframe/wall_heater

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/space_heater/wall_mounted, 29)

/obj/machinery/space_heater/wall_mounted/Initialize(mapload)
	. = ..()
	find_and_hang_on_wall()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	RemoveElement(/datum/element/elevation, pixel_shift = 8) //they're on the wall, you can't climb this
	RemoveElement(/datum/element/climbable)

/obj/machinery/space_heater/wall_mounted/RefreshParts()
	. = ..()
	heating_energy = src::heating_energy
	efficiency = src::efficiency

/obj/machinery/space_heater/wall_mounted/default_deconstruction_crowbar()
	return

/obj/machinery/space_heater/wall_mounted/default_unfasten_wrench(mob/living/user, obj/item/wrench, time)
	user.balloon_alert(user, "deconstructing...")
	wrench.play_tool_sound(src)
	if(wrench.use_tool(src, user, 1 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
		return

/obj/machinery/space_heater/wall_mounted/on_deconstruction(disassembled)
	if(disassembled)
		var/obj/item/wallframe/wall_heater/frame = new repacked_type(drop_location())
		frame.cell = cell
		cell?.forceMove(frame)
	else
		cell.forceMove(drop_location())
	cell = null
	return ..()

// Wallmount for creating the heaters

/obj/item/wallframe/wall_heater
	name = "unmounted wall heater"
	desc = "A compact heating and cooling device for small scale applications, made to mount onto walls up and out of the way. \
		Like other, more free-standing space heaters however, these still require cell power to function."
	icon = 'modular_doppler/colony_fabricator/icons/space_heater.dmi'
	icon_state = "sheater-off"
	w_class = WEIGHT_CLASS_NORMAL
	result_path = /obj/machinery/space_heater/wall_mounted
	pixel_shift = 29
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 4,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 1,
		/datum/material/gold = SMALL_MATERIAL_AMOUNT,
	)
	/// lazy-initialized cell stored in the actual heater (so that it can start with one without making a new one every placement)
	var/obj/item/stock_parts/power_store/cell = /obj/machinery/space_heater::cell

/obj/item/wallframe/wall_heater/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/wallframe/wall_heater/after_attach(obj/machinery/space_heater/wall_mounted/attached_to)
	. = ..()
	if(!istype(attached_to))
		return
	if(ispath(cell))
		cell = new cell
	attached_to.cell = cell
	cell?.forceMove(attached_to)
	cell = null

/obj/item/wallframe/wall_heater/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stock_parts/power_store/cell))
		return NONE
	if(ispath(cell))
		cell = new cell
	playsound(src, 'sound/machines/click.ogg', 75, TRUE)
	user.transferItemToLoc(tool, src)
	if(!isnull(cell))
		user.put_in_hands(cell)
		user.balloon_alert(user, "swapped")
	cell = tool
	return ITEM_INTERACT_SUCCESS

/obj/item/wallframe/wall_heater/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(isnull(cell))
		return SECONDARY_ATTACK_CALL_NORMAL
	if(ispath(cell))
		cell = new cell
	playsound(src, 'sound/machines/click.ogg', 75, TRUE)
	user.put_in_hands(cell)
	cell = null
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/wallframe/wall_heater/examine(mob/user)
	. = ..()
	if(cell)
		. += span_notice("It contains a [ispath(cell) ? cell::name : cell.name], which could be replaced.")
	else
		. += span_notice("It is empty. You could insert a [span_bold("cell")].")

/obj/item/wallframe/wall_heater/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(!isnull(cell) && isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Remove cell"
		. = CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/stock_parts/power_store))
		context[SCREENTIP_CONTEXT_LMB] = "Insert cell"
		. = CONTEXTUAL_SCREENTIP_SET
