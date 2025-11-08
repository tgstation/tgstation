///This element allows the item it's attached to be bound to oneself's arm with a pair of handcuffs (sold separately). Borgs need not to apply
/datum/element/cuffable_item

/datum/element/cuffable_item/Attach(datum/target)
	. = ..()

	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))
	RegisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION_SECONDARY, PROC_REF(item_interaction))

	var/atom/atom_target = target
	atom_target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(atom_target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

///Tell the player about the interaction if they examine the item twice.
/datum/element/cuffable_item/proc/on_examine_more(obj/item/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(length(user.held_items) < 0 || iscyborg(user) || source.anchored)
		return
	examine_list += span_smallnotice("You could bind [source.p_them()] to your wrist with a pair of handcuffs...")

///Give context to players holding a pair of handcuffs when hovering the item
/datum/element/cuffable_item/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	if (!istype(held_item, /obj/item/restraints/handcuffs))
		return NONE
	var/obj/item/restraints/handcuffs/cuffs = held_item
	if(!cuffs.used)
		context[SCREENTIP_CONTEXT_RMB] = "Cuff to your wrist"
		return CONTEXTUAL_SCREENTIP_SET

/datum/element/cuffable_item/proc/item_interaction(obj/item/source, mob/living/user, obj/item/tool, modifiers)
	SIGNAL_HANDLER

	if(!istype(tool, /obj/item/restraints/handcuffs) || iscyborg(user) || source.anchored || !source.IsReachableBy(user))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(apply_cuffs), source, user, tool)
	return ITEM_INTERACT_SUCCESS

///The proc responsible for adding the status effect to the player and all...
/datum/element/cuffable_item/proc/apply_cuffs(obj/item/source, mob/living/user, obj/item/restraints/handcuffs/cuffs)
	if(cuffs.used || DOING_INTERACTION_WITH_TARGET(user, source))
		return

	if(HAS_TRAIT_FROM(source, TRAIT_NODROP, CUFFED_ITEM_TRAIT))
		to_chat(user, span_warning("[source] is already cuffed to your wrist!"))
		return

	if(cuffs.handcuffs_clumsiness_check(user))
		return

	source.balloon_alert(user, "cuffing item...")
	playsound(source, cuffs.cuffsound, 30, TRUE, -2)
	if(!do_after(user, cuffs.get_handcuff_time(user), source))
		return

	playsound(source, cuffs.cuffsuccesssound, 30, TRUE, -2)

	if(user.apply_status_effect(/datum/status_effect/cuffed_item, source, cuffs))
		source.balloon_alert(user, "item cuffed to wrist")
		return

	source.balloon_alert(user, "couldn't cuff to wrist!")
	return
