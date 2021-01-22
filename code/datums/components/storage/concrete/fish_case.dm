/datum/component/storage/concrete/fish_case
	max_items = 1
	can_hold_description = "fish and aquarium equipment"

/datum/component/storage/concrete/fish_case/can_be_inserted(obj/item/I, stop_messages, mob/M)
	. = ..()
	/// Activate deferred components if any.
	SEND_SIGNAL(I,COMSIG_AQUARIUM_BEFORE_INSERT_CHECK)
	if(I.GetComponent(/datum/component/aquarium_content))
		return .
	else
		return FALSE

/datum/component/storage/concrete/fish_case/handle_item_insertion(obj/item/I, prevent_warning, mob/M, datum/component/storage/remote)
	. = ..()
	if(.)
		SEND_SIGNAL(I,COMSIG_AQUARIUM_FISH_CASE_STASIS)


