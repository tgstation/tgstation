/// This is what controls whether a limb should be digitigrade based on dna. This doesn't stop legs from having the digitigrade_limb component added in some other way though.
/datum/element/digitigrade_compatible
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/digi_footprint_sprite
	var/digi_footstep_type

/datum/element/digitigrade_compatible/Attach(obj/item/bodypart/leg/target, digi_footprint_sprite, digi_footstep_type,)
	. = ..()
	if(!istype(target))
		return ELEMENT_INCOMPATIBLE
	target.bodypart_flags |= BODYPART_DIGITIGRADE_COMPATIBLE
	RegisterSignal(target, COMSIG_BODYPART_UPDATED, PROC_REF(on_limb_updated))
	RegisterSignal(target, COMSIG_COMPONENT_ADDED, PROC_REF(on_component_added))
	RegisterSignal(target, COMSIG_COMPONENT_REMOVING, PROC_REF(on_component_removed))

	src.digi_footprint_sprite = digi_footprint_sprite
	src.digi_footstep_type = digi_footstep_type

/datum/element/digitigrade_compatible/Detach(obj/item/bodypart/leg/source)
	UnregisterSignal(source, list(COMSIG_BODYPART_UPDATED, COMSIG_COMPONENT_ADDED, COMSIG_COMPONENT_REMOVING))
	source.bodypart_flags &= ~BODYPART_DIGITIGRADE_COMPATIBLE
	revert_to_normal(source)
	return ..()

///Add or remove the digitigrade limb component depending on the dna and species
/datum/element/digitigrade_compatible/proc/on_limb_updated(obj/item/bodypart/leg/source, dropping_limb, is_creating)
	SIGNAL_HANDLER
	if(!is_creating || !source.owner?.dna) //This more or less ensures the rest of this proc is only run by species/replace_body() and regenerate_limbs()
		return

	var/datum/dna/dna = source.owner.dna
	if(dna.features[FEATURE_LEGS] == DIGITIGRADE_LEGS)
		if(source.bodytype & BODYTYPE_DIGITIGRADE) //already digitigrade, likely because the component was added to the new bodypart from the old one.
			return
		source.AddComponent(/datum/component/digitigrade_limb, "[initial(source.limb_id)]_[BODYPART_ID_DIGITIGRADE]", source.limb_id)
	else if(source.bodytype & BODYTYPE_DIGITIGRADE) //was digitigrade, shouldn't be digitigrade any longer
		qdel(GetComponent(/datum/component/digitigrade_limb))

/datum/element/digitigrade_compatible/proc/on_component_added(obj/item/bodypart/leg/source, datum/component/new_component)
	SIGNAL_HANDLER
	if(!istype(new_component, /datum/component/digitigrade_limb))
		return

	if(digi_footprint_sprite)
		source.footprint_sprite = digi_footprint_sprite
	if(digi_footstep_type)
		source.footstep_type = digi_footstep_type

/datum/element/digitigrade_compatible/proc/on_component_removed(obj/item/bodypart/leg/source, datum/component/old_component)
	SIGNAL_HANDLER
	if(istype(old_component, /datum/component/digitigrade_limb))
		revert_to_normal(source)

/datum/element/digitigrade_compatible/proc/revert_to_normal(obj/item/bodypart/leg/source)
	source.footprint_sprite = initial(source.footprint_sprite)
	source.footstep_type = initial(source.footstep_type)
