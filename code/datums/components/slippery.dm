/// Slippery component, for making anything slippery. Of course.
/datum/component/slippery
	/// If the slip forces you to drop held items.
	var/force_drop_items = FALSE
	/// How long the slip keeps you knocked down.
	var/knockdown_time = 0
	/// How long the slip paralyzes for.
	var/paralyze_time = 0
	/// Flags for how slippery the parent is.
	var/lube_flags
	/// A proc callback to call on slip.
	var/datum/callback/callback
	/// If parent is an item, this is the person currently holding/wearing the parent (or the parent if no one is holding it)
	var/mob/living/holder
	/// Whitelist of item slots the parent can be equipped in that make the holder slippery. If null or empty, it will always make the holder slippery.
	var/list/slot_whitelist

/datum/component/slippery/Initialize(_knockdown, _lube_flags = NONE, datum/callback/_callback, _paralyze, _force_drop = FALSE, _slot_whitelist)
	knockdown_time = max(_knockdown, 0)
	paralyze_time = max(_paralyze, 0)
	force_drop_items = _force_drop
	lube_flags = _lube_flags
	callback = _callback
	slot_whitelist = _slot_whitelist
	RegisterSignal(parent, COMSIG_MOVABLE_CROSSED, .proc/Slip)
	if(isitem(parent))
		holder = parent
		RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
		RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_drop)
	else
		RegisterSignal(parent, COMSIG_ATOM_ENTERED, .proc/Slip)

/datum/component/slippery/proc/Slip(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	var/mob/victim = AM
	if(istype(victim) && !(victim.movement_type & FLYING) && victim.slip(knockdown_time, parent, lube_flags, paralyze_time, force_drop_items) && callback)
		callback.Invoke(victim)

///gets called when COMSIG_ITEM_EQUIPPED is sent to parent
/datum/component/slippery/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if((!LAZYLEN(slot_whitelist) || (slot in slot_whitelist)) && isliving(equipper))
		holder = equipper
		RegisterSignal(holder, COMSIG_MOVABLE_CROSSED, .proc/Slip_on_wearer)
		RegisterSignal(holder, COMSIG_PARENT_PREQDELETED, .proc/holder_deleted)

/datum/component/slippery/proc/holder_deleted(datum/source, datum/possible_holder)
	SIGNAL_HANDLER

	if(possible_holder == holder)
		holder = null

///gets called when COMSIG_ITEM_DROPPED is sent to parent
/datum/component/slippery/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	holder = null
	UnregisterSignal(user, COMSIG_MOVABLE_CROSSED)

/datum/component/slippery/proc/Slip_on_wearer(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(holder.body_position == LYING_DOWN && !holder.buckled)
		Slip(source, AM)

/datum/component/slippery/clowning //used for making the clown PDA only slip if the clown is wearing his shoes and the elusive banana-skin belt

/datum/component/slippery/clowning/Slip_on_wearer(datum/source, atom/movable/AM)
	var/obj/item/I = holder.get_item_by_slot(ITEM_SLOT_FEET)
	if(holder.body_position == LYING_DOWN && !holder.buckled)
		if(istype(I, /obj/item/clothing/shoes/clown_shoes))
			Slip(source, AM)
		else
			to_chat(holder,"<span class='warning'>[parent] failed to slip anyone. Perhaps I shouldn't have abandoned my legacy...</span>")
