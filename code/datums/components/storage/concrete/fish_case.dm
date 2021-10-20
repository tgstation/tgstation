/datum/component/storage/concrete/fish_case
	max_items = 1
	can_hold_trait = TRAIT_FISH_CASE_COMPATIBILE
	can_hold_description = "fish and aquarium equipment"

/datum/component/storage/concrete/fish_case/can_be_inserted(obj/item/I, stop_messages, mob/M)
	/// Activate deferred components if any.
	SEND_SIGNAL(I, COMSIG_AQUARIUM_BEFORE_INSERT_CHECK)
	. = ..()

