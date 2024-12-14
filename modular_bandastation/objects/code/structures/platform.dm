// Almost copypaste from railings
/obj/structure/platform
	name = "platform"
	desc = "A metal platform."
	icon = 'modular_bandastation/objects/icons/obj/structures/platform.dmi'
	icon_state = "metal"
	flags_1 = ON_BORDER_1
	obj_flags = CAN_BE_HIT | IGNORE_DENSITY
	pass_flags_self = LETPASSTHROW | PASSSTRUCTURE
	density = TRUE
	anchored = TRUE
	armor_type = /datum/armor/platform
	max_integrity = 200
	var/climbable = TRUE
	var/corner = FALSE
	var/material_type = /obj/item/stack/sheet/iron
	var/material_amount = 4

/datum/armor/platform
	melee = 10
	bullet = 10
	laser = 10
	energy = 50
	bomb = 20
	fire = 100
	acid = 30

/obj/structure/platform/Initialize(mapload)
	. = ..()
	if(climbable)
		AddElement(/datum/element/climbable)
	if(density && flags_1 & ON_BORDER_1) // blocks normal movement from and to the direction it's facing.
		var/static/list/loc_connections = list(
			COMSIG_ATOM_EXIT = PROC_REF(on_exit),
		)
		AddElement(/datum/element/connect_loc, loc_connections)
	var/static/list/tool_behaviors = list(
		TOOL_WELDER = list(
			SCREENTIP_CONTEXT_LMB = "Repair",
		),
		TOOL_WRENCH = list(
			SCREENTIP_CONTEXT_LMB = "Anchor/Unanchor",
		),
		TOOL_SCREWDRIVER = list(
			SCREENTIP_CONTEXT_LMB = "Deconstruct",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

	AddComponent(/datum/component/simple_rotation, ROTATION_NEEDS_ROOM)
	CheckLayer()

/obj/structure/platform/New()
	..()
	if(corner)
		density = FALSE
	CheckLayer()

/obj/structure/platform/examine(mob/user)
	. = ..()
	. += span_notice("[src] is [anchored ? "screwed" : "unscrewed"] [anchored ? "to" : "from"] the floor.")

// Repairing
/obj/structure/platform/attackby(obj/item/I, mob/living/user, params)
	..()
	add_fingerprint(user)

	if(I.tool_behaviour == TOOL_WELDER && !user.combat_mode)
		if(atom_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=1))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(I.use_tool(src, user, 40, volume = 50))
				atom_integrity = max_integrity
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return

// Anchoring
/obj/structure/platform/wrench_act(mob/user, obj/item/I)
	. = ..()
	to_chat(user, span_notice("You begin to [anchored ? "unfasten [src] from" : "fasten [src] to"] the floor..."))
	if(I.use_tool(src, user, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
		set_anchored(!anchored)
		to_chat(user, span_notice("You [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor."))
	return TRUE

// Dismantle
/obj/structure/platform/screwdriver_act(mob/user, obj/item/I)
	if(resistance_flags & INDESTRUCTIBLE)
		to_chat(user, span_warning("You try to dismantle [src], but it's too hard!"))
		I.play_tool_sound(src, 100)
		return TRUE
	to_chat(user, span_warning("You dismantle [src]."))
	I.play_tool_sound(src, 100)
	deconstruct()
	return TRUE

/obj/structure/platform/atom_deconstruct(disassembled)
	var/obj/sheet = new material_type(drop_location(), material_amount)
	transfer_fingerprints_to(sheet)

/obj/structure/platform/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(leaving == src)
		return // Let's not block ourselves.
	if(!(direction & dir))
		return
	if(!density)
		return
	if(leaving.throwing)
		return
	if(leaving.movement_type & (PHASING|MOVETYPES_NOT_TOUCHING_GROUND))
		return
	if(leaving.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return
	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/platform/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(border_dir & dir)
		return . || mover.throwing || (mover.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
	return TRUE

/obj/structure/platform/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!(to_dir & dir))
		return TRUE
	return ..()

/obj/structure/platform/setDir(newdir)
	. = ..()
	CheckLayer()

/obj/structure/platform/proc/CheckLayer()
	if(dir == SOUTH)
		layer = ABOVE_MOB_LAYER
	else if(corner || dir == NORTH)
		layer = BELOW_MOB_LAYER

/obj/structure/platform/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

// Platform types
/obj/structure/platform/reinforced
	name = "reinforced platform"
	desc = "A robust platform made of plasteel, more resistance for hazard sites."
	icon_state = "plasteel"
	material_type = /obj/item/stack/sheet/plasteel
	armor_type = /datum/armor/platform_reinforced
	max_integrity = 300

/datum/armor/platform_reinforced
	melee = 20
	bullet = 30
	laser = 30
	energy = 100
	bomb = 75
	fire = 100
	acid = 100

// Platform corners
/obj/structure/platform/corner
	name = "platform corner"
	desc = "A metal platform corner."
	icon_state = "metalcorner"
	corner = TRUE
	material_amount = 2

/obj/structure/platform/reinforced/corner
	name = "reinforced platform corner"
	desc = "A robust platform corner made of plasteel, more resistance for hazard sites."
	icon_state = "plasteelcorner"
	corner = TRUE
	material_amount = 2
