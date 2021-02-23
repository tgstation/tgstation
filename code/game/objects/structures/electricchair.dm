#define ELECTRIC_BUCKLE_WAIT_TIME 5

/obj/structure/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair0"
	var/last_time = 1
	item_chair = null

/obj/structure/chair/e_chair/Initialize()
	. = ..()
	if(!stored_kit)
		stored_kit = new(src)
		stored_kit.master = src
		AddComponent(/datum/component/electrified_buckle, stored_kit)

/obj/structure/chair/e_chair/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WRENCH)
		var/obj/structure/chair/C = new /obj/structure/chair(loc)
		W.play_tool_sound(src)
		C.setDir(dir)
		stored_kit.forceMove(loc)
		stored_kit.master = null
		stored_kit = null
		qdel(src)


/datum/component/electrified_buckle
	///the shock kit attached to parent_chair
	var/obj/item/assembly/shock_kit/used_shock_kit
	///the mob buckled to parent_chair, if any
	var/mob/living/guinea_pig
	///the guinea pig can only be shocked if this reaches 5 seconds
	var/time_since_last_shock = 0
	///this is casted to the overlay we put on parent_chair TODO: make this an argument for initialize
	var/image/requested_overlay

/datum/component/electrified_buckle/Initialize(obj/item/assembly/shock_kit/input_shock_kit)
	if(!istype(parent, /obj/structure/chair) || !istype(input_shock_kit, /obj/item/assembly/shock_kit))
		return COMPONENT_INCOMPATIBLE
	var/atom/movable/parent_as_movable = parent
	used_shock_kit = input_shock_kit
	RegisterSignal(used_shock_kit, COMSIG_PARENT_PREQDELETED, .proc/delete_self)

	RegisterSignal(parent, COMSIG_MOVABLE_BUCKLE, .proc/on_buckle)
	RegisterSignal(parent, COMSIG_ATOM_EXIT, .proc/check_shock_kit)

	requested_overlay = image('icons/obj/chairs.dmi', "echair_over", OBJ_LAYER)
	parent_as_movable.add_overlay(requested_overlay)
	parent_as_movable.name = "electrified [initial(parent_as_movable.name)]"

	if(parent_as_movable.has_buckled_mobs())
		for(var/mob/living/possible_guinea_pig as anything() in parent_as_movable.buckled_mobs)
			if(on_buckle(src, possible_guinea_pig, FALSE))
				break

/datum/component/electrified_buckle/UnregisterFromParent()
	var/atom/movable/parent_as_movable = parent

	parent_as_movable.cut_overlay(list(requested_overlay))
	parent_as_movable.name = initial(parent_as_movable.name)

	if(parent)
		UnregisterSignal(parent, list(COMSIG_MOVABLE_BUCKLE, COMSIG_MOVABLE_UNBUCKLE, COMSIG_ATOM_EXIT))
	if(used_shock_kit)
		UnregisterSignal(used_shock_kit, list(COMSIG_PARENT_PREQDELETED))
	if(guinea_pig)
		UnregisterSignal(guinea_pig, list(COMSIG_PARENT_PREQDELETED))
	used_shock_kit = null
	guinea_pig  = null
	STOP_PROCESSING(SSprocessing, src)

/datum/component/electrified_buckle/proc/delete_self()
	SIGNAL_HANDLER
	qdel(src)

///checks if the shock kit connected to parent is still there and unregisters if it isnt
/datum/component/electrified_buckle/proc/check_shock_kit(datum/source, atom/movable/AM, atom/newLoc)
	SIGNAL_HANDLER
	var/atom/movable/parent_as_movable = parent
	if(used_shock_kit == AM && newLoc != parent_as_movable)
		delete_self()

/datum/component/electrified_buckle/proc/on_buckle(datum/source, mob/living/mob_to_buckle, _force)
	SIGNAL_HANDLER
	if(!istype(mob_to_buckle) || guinea_pig)
		return FALSE
	guinea_pig = mob_to_buckle
	RegisterSignal(guinea_pig, COMSIG_PARENT_PREQDELETED, .proc/nullify_guinea_pig)
	RegisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE, .proc/nullify_guinea_pig)
	START_PROCESSING(SSprocessing, src)
	return TRUE

///for whatever reason the guinea pig is gone so we cant shock them anymore
/datum/component/electrified_buckle/proc/nullify_guinea_pig()
	SIGNAL_HANDLER
	UnregisterSignal(guinea_pig, COMSIG_PARENT_PREQDELETED)
	UnregisterSignal(parent, COMSIG_MOVABLE_UNBUCKLE)
	guinea_pig = null
	STOP_PROCESSING(SSprocessing, src)

///where the guinea pig is actually shocked if possible
/datum/component/electrified_buckle/process(delta_time)
	if(QDELETED(guinea_pig) || QDELETED(used_shock_kit) || QDELETED(parent))
		time_since_last_shock = 0
		return PROCESS_KILL
	var/atom/movable/parent_as_movable = parent
	if(time_since_last_shock < ELECTRIC_BUCKLE_WAIT_TIME)
		time_since_last_shock += delta_time
		return
	time_since_last_shock = 0

	var/turf/our_turf = get_turf(parent_as_movable)
	var/obj/structure/cable/live_cable = our_turf.get_cable_node()

	if(parent_as_movable.has_buckled_mobs() && guinea_pig in parent_as_movable.buckled_mobs)
		if(!live_cable || !live_cable.powernet || live_cable.powernet.avail < 10)
			return
		var/shock_damage = round(live_cable.powernet.avail/5000)
		guinea_pig.electrocute_act(shock_damage, parent_as_movable, 1)
		to_chat(guinea_pig, "<span class='userdanger'>You feel a deep shock course through your body!</span>")
	else
		nullify_guinea_pig()
		time_since_last_shock = 0
		return PROCESS_KILL

	parent_as_movable.visible_message("<span class='danger'>The electric chair went off!</span>", "<span class='hear'>You hear a deep sharp shock!</span>")

#undef ELECTRIC_BUCKLE_WAIT_TIME
