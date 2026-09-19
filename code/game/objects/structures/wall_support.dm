/**
 * Wall supports are designed to help you safely deconstruct walls, without fear
 * of all wall-mounted equipment like APCs or light fixtures falling off.
 * All of the logic for handling wall-mounted equipment is in `atom_mounted.dm`
 * (/datum/component/atom_mounted)
**/
/obj/structure/wall_support
	desc = "A temporary support structure for wall-mounted equipment. Allows you to safely deconstruct walls."
	name = "Wall Support"
	icon = 'icons/obj/structures.dmi'
	icon_state = "wall_support"
	base_icon_state = "wall_support"
	layer = WALL_OBJ_LAYER - 0.1
	density = FALSE
	anchored = TRUE
	pass_flags_self = NONE
	obj_flags = CONDUCTS_ELECTRICITY | CAN_BE_HIT | IGNORE_DENSITY
	pressure_resistance = 5*ONE_ATMOSPHERE
	armor_type = /datum/armor/structure_grille
	max_integrity = 50
	integrity_failure = 0.4
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	var/rods_type = /obj/item/stack/rods
	var/rods_amount = 2

/obj/structure/wall_support/Initialize(mapload)
	. = ..()
	register_context()

/obj/structure/wall_support/examine(mob/user)
	. = ..()
	if(resistance_flags & INDESTRUCTIBLE)
		return
	if(anchored)
		. += span_notice("It's secured in place with [EXAMINE_HINT("screws")]. The rods look like they could be [EXAMINE_HINT("cut")] through.")
	else
		. += span_notice("The anchoring screws are [EXAMINE_HINT("unscrewed")]. The rods look like they could be [EXAMINE_HINT("cut")] through.")

/obj/structure/wall_support/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(held_item?.tool_behaviour == TOOL_WIRECUTTER)
		context[SCREENTIP_CONTEXT_RMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET
	if(held_item?.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[anchored ? "Unanchor" : "Anchor"]"
		return CONTEXTUAL_SCREENTIP_SET
	return .

/obj/structure/wall_support/wirecutter_act_secondary(mob/living/user, obj/item/tool)
	add_fingerprint(user)
	tool.play_tool_sound(src, 100)
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/wall_support/screwdriver_act(mob/living/user, obj/item/tool)
	if(!isturf(loc))
		return FALSE
	add_fingerprint(user)
	if(!tool.use_tool(src, user, 0, volume=100))
		return FALSE
	set_anchored(!anchored)
	user.visible_message(span_notice("[user] [anchored ? "fastens" : "unfastens"] [src]."), \
		span_notice("You [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/wall_support/play_attack_sound(...)
	return call(src, /obj/structure/grille::play_attack_sound())(arglist(args))

/obj/structure/wall_support/atom_deconstruct(disassembled = TRUE)
	var/obj/rods = new rods_type(drop_location(), rods_amount)
	transfer_fingerprints_to(rods)

/obj/structure/wall_support/atom_break()
	. = ..()
	if(broken)
		return
	atom_integrity = 20
	broken = TRUE
	rods_amount = 1
	var/obj/item/dropped_rods = new rods_type(drop_location(), rods_amount)
	transfer_fingerprints_to(dropped_rods)
	update_appearance()

/obj/structure/wall_support/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > T0C + 1500 && !broken

/obj/structure/wall_support/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(1, BURN, 0, 0)
