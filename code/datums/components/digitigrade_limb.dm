/// Updates the limb id of a bodypart if the mob is wearing digitigrade squishing clothing
/datum/component/digitigrade_limb
	/// Id when wearing digitigrade squishing clothing
	var/squashed_id
	/// Id when not wearing digitigrade squishing clothing
	var/free_id

	/// Lazylist of refs that are squishing this limb
	VAR_PRIVATE/list/squashing_us

/datum/component/digitigrade_limb/Initialize(squashed_id, free_id)
	if(!istype(parent, /obj/item/bodypart/leg))
		return COMPONENT_INCOMPATIBLE

	var/obj/item/bodypart/limb = parent
	limb.bodytype |= BODYTYPE_DIGITIGRADE

	src.squashed_id = squashed_id
	src.free_id = free_id || initial(limb.limb_id)

	RegisterSignal(parent, COMSIG_BODYPART_UPDATED, PROC_REF(update_limb_id_comsig))
	RegisterSignal(parent, COMSIG_BODYPART_ATTACHED, PROC_REF(on_attach))
	RegisterSignal(parent, COMSIG_BODYPART_REMOVED, PROC_REF(on_remove))
	RegisterSignal(parent, COMSIG_BODYPART_BUTCHERED, PROC_REF(on_butchered))

	if(ishuman(limb.owner))
		on_attach(limb, limb.owner)

/datum/component/digitigrade_limb/Destroy()
	UnregisterSignal(parent, COMSIG_BODYPART_UPDATED)
	UnregisterSignal(parent, COMSIG_BODYPART_ATTACHED)
	UnregisterSignal(parent, COMSIG_BODYPART_REMOVED)

	UnregisterSignal(parent, COMSIG_BODYPART_BUTCHERED)
	var/obj/item/bodypart/limb = parent
	if(!QDELING(parent) && ishuman(limb.owner))
		on_remove(limb, limb.owner)
	limb.bodytype &= ~BODYTYPE_DIGITIGRADE
	return ..()

/datum/component/digitigrade_limb/proc/on_attach(obj/item/bodypart/limb, mob/living/carbon/new_limb_owner)
	SIGNAL_HANDLER

	RegisterSignal(new_limb_owner, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(equipped_item))
	RegisterSignal(new_limb_owner, COMSIG_MOB_DROPPED_ITEM, PROC_REF(unequipped_item))
	RegisterSignal(new_limb_owner, COMSIG_CARBON_ITEM_COVERAGE_CHANGED, PROC_REF(coverage_changed))
	for(var/obj/item/equipped as anything in new_limb_owner.get_equipped_items())
		if(equipped_item(new_limb_owner, equipped, new_limb_owner.get_slot_by_item(equipped)))
			LAZYOR(squashing_us, REF(equipped))

/datum/component/digitigrade_limb/proc/on_remove(obj/item/bodypart/limb, mob/living/carbon/old_limb_owner)
	SIGNAL_HANDLER

	UnregisterSignal(old_limb_owner, COMSIG_MOB_EQUIPPED_ITEM)
	UnregisterSignal(old_limb_owner, COMSIG_MOB_DROPPED_ITEM)
	UnregisterSignal(old_limb_owner, COMSIG_CARBON_ITEM_COVERAGE_CHANGED)
	LAZYNULL(squashing_us)
	update_limb_id()

/datum/component/digitigrade_limb/proc/equipped_item(mob/living/carbon/equipper, obj/item/equipped_item, slot)
	SIGNAL_HANDLER

	if((slot & equipped_item.slot_flags) && item_squishes_limb(equipped_item, equipper))
		LAZYOR(squashing_us, REF(equipped_item))
		update_limb_id()

/datum/component/digitigrade_limb/proc/unequipped_item(mob/living/carbon/equipper, obj/item/equipped_item)
	SIGNAL_HANDLER

	LAZYREMOVE(squashing_us, REF(equipped_item))
	update_limb_id()

// Snowflake case for updating whether our jumpsuit should squish us
/datum/component/digitigrade_limb/proc/coverage_changed(mob/living/carbon/equipper, added_slots, removed_slots)
	SIGNAL_HANDLER

	if(!((added_slots|removed_slots) & HIDEJUMPSUIT))
		return

	var/obj/item/clothing/uniform = equipper.get_item_by_slot(ITEM_SLOT_ICLOTHING)
	if(isnull(uniform))
		return

	var/uniform_ref = REF(uniform)
	if(uniform_ref in squashing_us)
		if(added_slots & HIDEJUMPSUIT)
			LAZYREMOVE(squashing_us, uniform_ref)
			update_limb_id()

	else
		if((removed_slots & HIDEJUMPSUIT) && item_squishes_limb(uniform, equipper))
			LAZYOR(squashing_us, uniform_ref)
			update_limb_id()

/datum/component/digitigrade_limb/proc/item_squishes_limb(obj/item/equipped_item, mob/living/carbon/equipper)
	if(!(equipped_item.body_parts_covered & (LEGS|FEET)))
		return FALSE

	switch(equipper.get_slot_by_item(equipped_item))
		if(ITEM_SLOT_FEET, ITEM_SLOT_OCLOTHING)
			return !(equipped_item.supports_variations_flags & DIGITIGRADE_VARIATIONS)
		if(ITEM_SLOT_ICLOTHING) // If the jumpsuit is obscured, it shouldn't contribute to squishing
			return !(equipped_item.supports_variations_flags & DIGITIGRADE_VARIATIONS) && !(equipper.obscured_slots & HIDEJUMPSUIT)

	return FALSE

/// This is just ran on update_limb() to ensure we always have the correct ID
/datum/component/digitigrade_limb/proc/update_limb_id_comsig()
	SIGNAL_HANDLER
	update_limb_id(sprite_update = FALSE)

/// Digitigrade limbs that are butchered add the component to the replacement limb
/datum/component/digitigrade_limb/proc/on_butchered(datum/source, obj/item/bodypart/replacement)
	SIGNAL_HANDLER
	squashed_id = "[initial(replacement.limb_id)]_[BODYPART_ID_DIGITIGRADE]"
	free_id = initial(replacement.limb_id)
	replacement.TakeComponent(src)

/datum/component/digitigrade_limb/proc/update_limb_id(sprite_update = TRUE)
	var/obj/item/bodypart/limb = parent
	var/old_id = limb.limb_id
	if(LAZYLEN(squashing_us))
		limb.limb_id = squashed_id
		limb.remove_bodyshape(BODYSHAPE_DIGITIGRADE)

	else
		limb.limb_id = free_id
		limb.add_bodyshape(BODYSHAPE_DIGITIGRADE)

	if(!sprite_update || old_id == limb.limb_id)
		return

	if(isnull(limb.owner))
		limb.update_icon_dropped()
		return

	// Ensures any items that with a variation are updated
	for(var/obj/item/thing as anything in limb.owner.get_equipped_items(INCLUDE_PROSTHETICS|INCLUDE_ABSTRACT))
		if(thing.supports_variations_flags & DIGITIGRADE_VARIATIONS)
			thing.update_slot_icon()
	// Updates underwear and mob sprites
	limb.owner.update_body()
