/datum/storage/fish_case
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_HUGE
	can_hold_trait = TRAIT_FISH_CASE_COMPATIBILE
	can_hold_description = "fish and aquarium equipment"

///Requires the user to have it outside of storage and equipment slots so they can't just shove a tuna in their pockets.
/datum/storage/fish_case/can_insert(obj/item/to_insert, mob/living/user, messages = TRUE, force = FALSE)
	. = ..()
	if(!. || force)
		return .
	var/obj/item/resolve_parent = parent?.resolve()
	if(resolve_parent.item_flags & IN_STORAGE)
		if(messages && user)
			to_chat(user, span_warning("Take [resolve_parent] out of [resolve_parent.loc] first!"))
		return FALSE
	if(user && (resolve_parent in user.get_equipped_items(TRUE)) && !user.is_holding(resolve_parent))
		if(messages)
			to_chat(user, span_warning("Either hold [resolve_parent] or place it nearby first!"))
		return FALSE

/datum/storage/fish_case/handle_enter(obj/item/storage/fish_case/source, obj/item/arrived)
	. = ..()
	if(istype(arrived))
		source.w_class = arrived.w_class

/datum/storage/fish_case/handle_exit(obj/item/storage/fish_case/source, obj/item/gone)
	. = ..()
	if(istype(gone))
		source.w_class = initial(source.w_class)
