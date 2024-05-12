/// when equipped and unequipped this item gives a martial art
/datum/component/martial_art_giver
	/// the style we give
	var/datum/martial_art/style

/datum/component/martial_art_giver/Initialize(style_type)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	style = new style_type()
	style.allow_temp_override = FALSE

/datum/component/martial_art_giver/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(dropped))

/datum/component/martial_art_giver/UnregisterFromParent(datum/source)
	UnregisterSignal(parent, list(COMSIG_ITEM_POST_EQUIPPED, COMSIG_ITEM_POST_UNEQUIP))
	var/obj/item/parent_item = parent
	if(ismob(parent_item?.loc))
		UnregisterSignal(parent, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_INITIALIZED, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF))
	QDEL_NULL(style)

/datum/component/martial_art_giver/proc/equipped(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	if(!(source.slot_flags & slot))
		return
	RegisterSignals(user, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_INITIALIZED), PROC_REF(teach))
	RegisterSignal(user, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF, PROC_REF(forget))
	teach(user)

/datum/component/martial_art_giver/proc/dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	forget(user)
	UnregisterSignal(user, list(COMSIG_MOB_MIND_TRANSFERRED_INTO, COMSIG_MOB_MIND_INITIALIZED, COMSIG_MOB_MIND_TRANSFERRED_OUT_OF))

/datum/component/martial_art_giver/proc/teach(mob/source)
	if(isnull(style))
		return
	style.teach(source, TRUE)

/datum/component/martial_art_giver/proc/forget(mob/source)
	if(isnull(style))
		return
	style.fully_remove(source)
