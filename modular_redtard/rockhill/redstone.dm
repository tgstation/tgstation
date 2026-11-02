#define ROCKHILL_PLATE_HIDDEN_ALPHA 35
#define ROCKHILL_PLATE_SOUND_RANGE 2

GLOBAL_LIST_EMPTY(rockhill_redstone)

/obj/structure/rockhill
	var/redstone_id

/obj/structure/rockhill/proc/register_redstone()
	if(redstone_id)
		LAZYADDASSOCLIST(GLOB.rockhill_redstone, "[redstone_id]", src)

/obj/structure/rockhill/proc/unregister_redstone()
	if(redstone_id)
		LAZYREMOVEASSOC(GLOB.rockhill_redstone, "[redstone_id]", src)

/obj/structure/rockhill/proc/send_redstone(mob/user)
	if(!redstone_id)
		return
	for(var/obj/structure/linked as anything in GLOB.rockhill_redstone["[redstone_id]"])
		if(linked != src)
			INVOKE_ASYNC(linked, PROC_REF(redstone_triggered), user)

/obj/structure/rockhill/proc/redstone_triggered(mob/user)
	return

/obj/structure/lever
	var/toggled = FALSE

/obj/structure/lever/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_warning("[user] pulls [src]."))
	user.log_message("pulled the lever with redstone id \"[redstone_id]\"", LOG_GAME)
	if(ROCKHILL_LEVER_TIME > 0 && !do_after(user, ROCKHILL_LEVER_TIME, target = user))
		return TRUE
	toggled = !toggled
	icon_state = "[copytext(icon_state, 1, -1)][toggled]"
	playsound(src, 'modular_redtard/rockhill/sound/foley/lever.ogg', 100, extrarange = 3)
	send_redstone(user)
	return TRUE

/obj/structure/bars/passage/redstone_triggered(mob/user)
	set_density(!density)
	icon_state = "[copytext(icon_state, 1, -1)][density ? 0 : 1]"

/obj/structure/bars/passage/shutter/redstone_triggered(mob/user)
	. = ..()
	set_opacity(density)

/obj/structure/bars/passage/shutter/hidden/redstone_triggered(mob/user)
	. = ..()
	alpha = density ? 255 : 60

/obj/structure/floordoor
	var/togg = FALSE
	var/base_state = "floorhatch"

/obj/structure/floordoor/redstone_triggered(mob/user)
	set_hatch(!togg)

/obj/structure/floordoor/proc/set_hatch(opened)
	togg = opened
	icon_state = "[base_state][opened ? 0 : 1]"
	if(!opened)
		obj_flags |= BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
		return
	obj_flags &= ~(BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP)
	var/turf/open/openspace/hole = loc
	if(!istype(hole))
		return
	for(var/atom/movable/thing in hole)
		hole.zfall_if_on_turf(thing)

/obj/structure/floordoor/gatehatch
	var/changing_state = FALSE
	var/delay2open = 0
	var/delay2close = 0

/obj/structure/floordoor/gatehatch/redstone_triggered(mob/user)
	if(changing_state)
		return
	changing_state = TRUE
	addtimer(CALLBACK(src, PROC_REF(set_hatch), !togg), togg ? delay2close : delay2open)
	addtimer(VARSET_CALLBACK(src, changing_state, FALSE), ROCKHILL_HATCH_CYCLE)

/obj/structure/kybraxor
	var/openn = FALSE
	var/changing_state = FALSE

/obj/structure/kybraxor/redstone_triggered(mob/user)
	if(changing_state)
		return
	changing_state = TRUE
	openn = !openn
	playsound(src, openn ? 'modular_redtard/rockhill/sound/misc/kybraxorop.ogg' : 'modular_redtard/rockhill/sound/misc/kybraxor.ogg', 100, FALSE)
	flick(openn ? "kybraxoropening" : "kybraxorclosing", src)
	addtimer(CALLBACK(src, PROC_REF(finish_turn)), ROCKHILL_HATCH_CYCLE)

/obj/structure/kybraxor/proc/finish_turn()
	icon_state = openn ? "kybraxor0" : "kybraxor1"
	changing_state = FALSE

/// Ratwood's pressure plate (roguetown/redstone.dm, Vanderlin's): a living thing stepping on it clicks it, and the mechanisms
/// of its redstone_id answer. A clod of dirt hides it, a cloth wipes the dirt away.
/obj/structure/pressure_plate/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	var/static/list/loc_connections = list(COMSIG_ATOM_ENTERED = PROC_REF(on_entered))
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/pressure_plate/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER
	if(!anchored || !isliving(arrived))
		return
	var/mob/living/stepper = arrived
	to_chat(stepper, span_info("I feel something click beneath me."))
	stepper.log_message("has activated a pressure plate with redstone id \"[redstone_id]\"", LOG_GAME)
	playsound(src, 'modular_redtard/rockhill/sound/misc/pressurepad_down.ogg', 35, extrarange = ROCKHILL_PLATE_SOUND_RANGE)
	trigger_plate(stepper)

/obj/structure/pressure_plate/proc/trigger_plate(mob/living/stepper)
	playsound(src, 'modular_redtard/rockhill/sound/misc/pressurepad_up.ogg', 35, extrarange = ROCKHILL_PLATE_SOUND_RANGE)
	send_redstone(stepper)

/obj/structure/pressure_plate/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/natural/cloth) && alpha <= ROCKHILL_PLATE_HIDDEN_ALPHA)
		to_chat(user, span_warning("I wipe away the dirt concealing the [name]"))
		INVOKE_ASYNC(src, PROC_REF(set_hidden), user, null)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/natural/dirtclod))
		if(alpha <= ROCKHILL_PLATE_HIDDEN_ALPHA)
			to_chat(user, span_warning("[name] is already concealed"))
			return ITEM_INTERACT_BLOCKING
		to_chat(user, span_warning("I begin to conceal the [name]"))
		INVOKE_ASYNC(src, PROC_REF(set_hidden), user, tool)
		return ITEM_INTERACT_SUCCESS
	return NONE

/// Covers the plate with the clod given, or wipes it clean without one.
/obj/structure/pressure_plate/proc/set_hidden(mob/living/user, obj/item/natural/dirtclod/clod)
	if(!do_after(user, rogue_value("pressure_plate_conceal_time"), target = src))
		return
	if(!clod)
		alpha = 255
		return
	if(QDELETED(clod) || !user.is_holding(clod))
		return
	alpha = ROCKHILL_PLATE_HIDDEN_ALPHA
	qdel(clod)

#undef ROCKHILL_PLATE_HIDDEN_ALPHA
#undef ROCKHILL_PLATE_SOUND_RANGE
