/// An element that allows objects to be right clicked and turned into another item after a delay
/datum/element/repackable
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// The path to spawn when the repacking operation is complete
	var/item_to_pack_into
	/// How long will repacking the attachee take
	var/repacking_time
	/// Do we tell objects destroyed that we disassembled them?
	var/disassemble_objects

/datum/element/repackable/Attach(datum/target, item_to_pack_into = /obj/item, repacking_time = 1 SECONDS, disassemble_objects = TRUE)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.item_to_pack_into = item_to_pack_into
	src.repacking_time = repacking_time
	src.disassemble_objects = disassemble_objects

	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(examine))
	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_right_click))
	RegisterSignal(target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

/datum/element/repackable/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(target, COMSIG_ATOM_ATTACK_HAND_SECONDARY)
	UnregisterSignal(target, list(COMSIG_ATOM_ATTACKBY, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM))

/datum/element/repackable/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("It can be <b>repacked</b> with <b>right click</b>.")

/// Checks if the user can actually interact with the structures in question, then invokes the proc to make it repack
/datum/element/repackable/proc/on_right_click(atom/source, mob/user)
	SIGNAL_HANDLER

	if(!user.can_perform_action(source, NEED_DEXTERITY))
		return

	INVOKE_ASYNC(src, PROC_REF(repack), source, user)

/// Removes the element target and spawns a new one of whatever item_to_pack_into is
/datum/element/repackable/proc/repack(atom/source, mob/user)
	source.balloon_alert_to_viewers("repacking...")
	if(!do_after(user, 3 SECONDS, target = source))
		return

	playsound(source, 'sound/items/ratchet.ogg', 50, TRUE)

	new item_to_pack_into(source.drop_location())

	if(istype(source, /obj))
		var/obj/source_object = source
		source_object.deconstruct(TRUE)
	else
		qdel(source)

/// Adds screen context for hovering over the repackable items with your mouse
/datum/element/repackable/proc/on_requesting_context_from_item(atom/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Repack"
		. = CONTEXTUAL_SCREENTIP_SET

	return NONE
