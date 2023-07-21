/// Applied to an item, allows it to grant passive damage resistance when worn
/datum/element/passive_resistance
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2

	/// Slots the item must be equipped in to grant resistance, required
	var/required_slots = NONE
	/// Amount of damage resistance to grant
	var/damage_resistance = 5

/datum/element/passive_resistance/Attach(datum/target, required_slots, damage_resistance)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	if(!required_slots || !isnum(damage_resistance))
		return ELEMENT_INCOMPATIBLE

 	src.required_slots = required_slots
	src.damage_resistance = damage_resistance
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(item_equipped))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(item_dropped))

/datum/element/passive_resistance/Detach(obj/item/source, ...)
	. = ..()
	UnregisterSignal(source, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	if(isliving(source.loc))
		var/mob/living/resisting = source.loc
		resisting.remove_status_effect(/datum/status_effect/passive_resistance, REF(source))

/datum/element/passive_resistance/proc/item_equipped(obj/item/source, mob/user, slot)
	SIGNAL_HANDLER

	if(!ishuman(user))
		return
	if(!(slot & required_slots))
		return

	var/mob/living/carbon/human/resisting = user
	resisting.apply_status_effect(/datum/status_effect/passive_resistance, REF(source), damage_resistance)

/datum/element/passive_resistance/proc/item_dropped(obj/item/source, mob/user, silent)
	SIGNAL_HANDLER

	if(!ishuman(user))
		return

	var/mob/living/carbon/human/resisting = user
	resisting.remove_status_effect(/datum/status_effect/passive_resistance, REF(source))

/// Status effect used by [/datum/element/passive_resistance]
/datum/status_effect/passive_resistance
	id = "passive_resistance_element"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	tick_interval = -1
	/// Tracks the ref to what item applied this effect
	/// So we don't accidentally remove other item's resistances
	var/source
	/// Amount of damage resistance to grant
	var/resistance_amount = 5

/datum/status_effect/passive_resistance/on_creation(mob/living/new_owner, source, resistance_amount = 5)
	. = ..()
	src.source = source
	src.resistance_amount = resistance_amount

/datum/status_effect/passive_resistance/on_apply()
	if(!ishuman(owner))
		return FALSE
	for(var/datum/status_effect/passive_resistance/other_resistance in owner.status_effects)
		if(other_resistance.source == new_source)
			return FALSE

	var/mob/living/carbon/human/holyman = owner
	holyman.physiology.damage_resistance += resistance_amount
	return TRUE

/datum/status_effect/passive_resistance/on_remove()
	if(QDELETED(owner))
		return
	var/mob/living/carbon/human/holyman = user
	holyman.physiology.damage_resistance -= resistance_amount

/datum/status_effect/passive_resistance/before_remove(source)
	return src.source == source
