#define WIP_CUFFABLE_ITEM_TRAIT "wip_cuff"

/datum/element/cuffable_item

/datum/element/cuffable_item/Attach(datum/target)
	. = ..()

	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))
	RegisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(item_interaction))

	var/atom/atom_target = target
	atom_target.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(atom_target, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

///signal called on parent being examined
/datum/element/cuffable_item/proc/on_examine_more(obj/item/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if(length(living_owner.held_items) < 0 || isrobot(user) || source.anchored)
		return
	examine_list += span_smallnotice("You could bind [target.p_they()] to your wrist with a pair of handcuffs...")

/datum/element/cuffable_item/proc/on_requesting_context_from_item(datum/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	if (istype(held_item, /obj/item/restraints/handcuffs))
		context[SCREENTIP_CONTEXT_RMB] = "Cuff to your wrist"
		return CONTEXTUAL_SCREENTIP_SET

/datum/element/cuffable_item/proc/item_interaction(obj/item/source, mob/user, obj/item/tool, modifiers)
	if(!istype(tool, /obj/item/restraints/handcuffs) || isrobot(user) || source.anchored)
		return NONE

	if(HAS_TRAIT_FROM(source, TRAIT_NODROP, WIP_CUFFABLE_ITEM_TRAIT))
		to_chat(user, span_warning("[source] is already cuffed to your wrist!"))
		return ITEM_INTERACT_BLOCKING

	return ITEM_INTERACT_SUCCESS

#undef WIP_CUFFABLE_ITEM_TRAIT
