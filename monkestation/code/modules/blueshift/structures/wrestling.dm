/obj/structure/railing/wrestling
	name = "wrestling ropes"
	desc = "Ropes that are meant to go around a wrestling ring."
	icon = 'monkestation/code/modules/blueshift/icons/wrestling.dmi'
	icon_state = "ropes"
	climbable = FALSE
	standard_smoothing = FALSE

/obj/structure/railing/wrestling/CanPass(atom/movable/mover, border_dir)
	..()
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(!(living_mover.body_position == STANDING_UP)) //if youre laying down, you can crawl through
			return TRUE

	if(dir == NORTH || dir == SOUTH) //if top/bottom sprites
		return . || mover.throwing || mover.movement_type & (FLYING | FLOATING)

	if(border_dir == dir)
		return . || mover.throwing || mover.movement_type & (FLYING | FLOATING)

	return TRUE

/obj/structure/railing/wrestling/on_exit(datum/source, atom/movable/leaving, direction)
	..()

	if(leaving == src)
		return // Let's not block ourselves.

	if(!(direction & dir))
		return

	if (!density)
		return

	if (leaving.throwing)
		return

	if (leaving.movement_type & (PHASING | FLYING | FLOATING))
		return

	if (leaving.move_force >= MOVE_FORCE_EXTREMELY_STRONG)
		return

	if (dir == NORTH || dir == SOUTH)
		return

	if(isliving(leaving))
		var/mob/living/living_mover = leaving
		if(!(living_mover.body_position == STANDING_UP)) //if youre laying down, you can crawl through
			return

	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

//
//TURNBUCKLES
//

/obj/structure/wrestling_corner
	name = "wrestling turnbuckle"
	icon = 'monkestation/code/modules/blueshift/icons/wrestling.dmi'
	icon_state = "turnbuckle"
	density = TRUE
	anchored = TRUE
	armor_type = /datum/armor/structure_wrestling_corner
	max_integrity = 75
	var/ini_dir

/datum/armor/structure_wrestling_corner
	melee = 50
	bullet = 70
	laser = 70
	energy = 100
	bomb = 10
	bio = 100

/obj/structure/wrestling_corner/Initialize(mapload)
	. = ..()
	ini_dir = dir

	AddElement(/datum/element/climbable, climb_time = 20, climb_stun = 0)
	AddComponent(/datum/component/simple_rotation, ROTATION_NEEDS_ROOM)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_enter),
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/wrestling_corner/attackby(obj/item/I, mob/living/user, params)
	..()
	add_fingerprint(user)

	if(I.tool_behaviour == TOOL_WELDER && !(user.istate & ISTATE_HARM))
		if(atom_integrity < max_integrity)
			if(!I.tool_start_check(user, amount=0))
				return

			to_chat(user, span_notice("You begin repairing [src]..."))
			if(I.use_tool(src, user, 40, volume=50))
				atom_integrity = max_integrity
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return

/obj/structure/wrestling_corner/wirecutter_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!anchored)
		to_chat(user, span_warning("You cut apart the turnbuckle."))
		tool.play_tool_sound(src, 100)
		deconstruct()
		return TRUE

/obj/structure/wrestling_corner/deconstruct(disassembled)
	. = ..()
	var/obj/item/stack/sheet/iron/iron_sheets = new /obj/item/stack/sheet/iron(drop_location(), 3)
	transfer_fingerprints_to(iron_sheets)

///Implements behaviour that makes it possible to unanchor the railing.
/obj/structure/wrestling_corner/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	to_chat(user, span_notice("You begin to [anchored ? "unfasten the turnbuckle from":"fasten the turnbuckle to"] the floor..."))
	if(tool.use_tool(src, user, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
		set_anchored(!anchored)
		to_chat(user, span_notice("You [anchored ? "fasten the turnbuckle to":"unfasten the turnbuckle from"] the floor."))
	return TRUE

/obj/structure/wrestling_corner/CanPass(atom/movable/mover, border_dir)
	. = ..()
	if(isliving(mover))
		var/mob/living/living_mover = mover
		if(!(living_mover.body_position == STANDING_UP)) //if youre laying down, you can crawl through
			return TRUE
	return . || mover.throwing || mover.movement_type & (FLYING | FLOATING)


/obj/structure/wrestling_corner/proc/check_anchored(checked_anchored)
	return anchored == checked_anchored

/obj/structure/wrestling_corner/proc/on_enter(datum/source, atom/movable/movable)
	SIGNAL_HANDLER
	if(ishuman(movable))
		var/mob/living/carbon/human/H = movable
		H.AddComponent(/datum/component/tackler, stamina_cost=25, base_knockdown = 1 SECONDS, range = 4, speed = 1, skill_mod = 0, min_distance = 0)

/obj/structure/wrestling_corner/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER

	if(ishuman(leaving))
		var/mob/living/carbon/human/H = leaving
		var/datum/component/tackler/wrestling_tackler = H.GetComponent(/datum/component/tackler)
		wrestling_tackler.Destroy()
