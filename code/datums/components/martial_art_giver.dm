/// when equipped and unequipped this item gives a martial art
/datum/component/martial_art_giver
	/// the style we give
	var/datum/martial_art/style

/datum/component/martial_art_giver/Initialize(style_type)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	style = new style_type(src)

/datum/component/martial_art_giver/Destroy()
	QDEL_NULL(style)
	return ..()

/datum/component/martial_art_giver/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(dropped))

	var/obj/item/item = parent
	var/mob/living/wearer = item.loc
	if(istype(wearer))
		equipped(item, wearer, wearer.get_slot_by_item(item))

/datum/component/martial_art_giver/UnregisterFromParent(datum/source)
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

	var/obj/item/item = parent
	var/mob/living/wearer = item.loc
	if(istype(wearer))
		dropped(item, wearer)

/datum/component/martial_art_giver/proc/equipped(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER
	if(!(source.slot_flags & slot))
		return
	style.teach(user)

/datum/component/martial_art_giver/proc/dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	style.unlearn(user)
