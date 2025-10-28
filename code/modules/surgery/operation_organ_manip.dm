/// Adding or removing specific organs
/datum/surgery_operation/limb/organ_manipulation
	name = "organ manipulation"
	abstract_type = /datum/surgery_operation/limb/organ_manipulation
	operation_flags = OPERATION_MORBID
	/// Radial slice datums for every organ type we can manipulate
	VAR_PRIVATE/list/cached_organ_manipulation_options

	/// Sound played when starting to insert an organ
	var/insert_preop_sound = 'sound/items/handling/surgery/organ2.ogg'
	/// Sound played when starting to remove an organ
	var/remove_preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	/// Sound played when successfully inserting an organ
	var/insert_success_sound = 'sound/items/handling/surgery/organ1.ogg'
	/// Sound played when successfully removing an organ
	var/remove_success_sound = 'sound/items/handling/surgery/organ2.ogg'

	/// Implements used to insert organs
	var/list/insert_implements = list(
		/obj/item/organ = 1,
	)
	/// Implements used to remove organs
	var/list/remove_implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 1.8,
		/obj/item/kitchen/fork = 2.85,
	)

/datum/surgery_operation/limb/organ_manipulation/New()
	. = ..()
	implements = remove_implements + insert_implements

/datum/surgery_operation/limb/organ_manipulation/get_recommended_tool()
	return "[..()] / organ"

/// Checks that the passed organ can be inserted/removed
/datum/surgery_operation/limb/organ_manipulation/proc/organ_check(obj/item/bodypart/limb, obj/item/organ/organ)
	return TRUE

/// Checks that the passed organ can be inserted/removed in the specified zones
/datum/surgery_operation/limb/organ_manipulation/proc/zone_check(obj/item/organ/organ, limb_zone, operated_zone)
	SHOULD_CALL_PARENT(TRUE)
	if(organ.valid_zones)
		// allows arm implants to be inserted into either arm
		if(!(limb_zone in organ.valid_zones))
			return FALSE
		// but disallows arm implants from being inserted into the torso
		if(!(operated_zone in organ.valid_zones))
			return FALSE
	else
		// allows appendixes to be inserted into chest
		if(limb_zone != deprecise_zone(organ.zone))
			return FALSE
		// but disallows appendixes from being inserted into the chest cavity
		if(operated_zone != organ.zone)
			return FALSE

	return TRUE

/datum/surgery_operation/limb/organ_manipulation/proc/can_operate_on_organ(obj/item/bodypart/limb, obj/item/organ/organ, mob/living/surgeon)
	if(!organ_check(limb, organ))
		return FALSE
	if(!zone_check(organ, limb.body_zone, surgeon.zone_selected))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/organ_manipulation/get_radial_options(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool)
	if(istype(tool, /obj/item/organ))
		return get_insert_options(limb, surgeon, tool)
	return get_remove_options(limb, surgeon)

/datum/surgery_operation/limb/organ_manipulation/proc/get_remove_options(obj/item/bodypart/limb, mob/living/surgeon)
	var/list/options = list()
	for(var/obj/item/organ/organ in limb)
		if(!can_operate_on_organ(limb, organ, surgeon) || (organ.organ_flags & ORGAN_UNREMOVABLE))
			continue
		var/datum/radial_menu_choice/option = LAZYACCESS(cached_organ_manipulation_options, organ.type)
		if(!option)
			option = new()
			option.image = get_generic_limb_radial_image(limb)
			option.image.overlays += add_radial_overlays(organ)
			option.name = "remove [organ.name]"
			option.info = "Remove [organ.name] from the patient."
			LAZYSET(cached_organ_manipulation_options, organ.type, option)

		options[option] = list("[OPERATION_ACTION]" = "remove", "organ" = organ)

	return options

/datum/surgery_operation/limb/organ_manipulation/proc/get_insert_options(obj/item/bodypart/limb, mob/living/surgeon, obj/item/organ/organ)
	if(!can_operate_on_organ(limb, organ, surgeon) || !(organ.organ_flags & ORGAN_UNUSABLE))
		return null

	for(var/obj/item/organ/existing_organ in limb)
		if(existing_organ.slot == organ.slot)
			return null

	var/datum/radial_menu_choice/option = LAZYACCESS(cached_organ_manipulation_options, organ.type)
	if(!option)
		option = new()
		option.image = get_generic_limb_radial_image(limb)
		option.image.overlays += add_radial_overlays(list(image('icons/hud/screen_gen.dmi', "arrow_large_still"), organ))
		option.name = "insert [organ.name]"
		option.info = "insert [organ.name] into the patient."
		LAZYSET(cached_organ_manipulation_options, organ.type, option)

	var/list/result = list()
	result[option] = list("[OPERATION_ACTION]" = "insert")
	return result

/datum/surgery_operation/limb/organ_manipulation/operate_check(mob/living/patient, obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	if(!..())
		return FALSE

	switch(operation_args[OPERATION_ACTION])
		if("remove")
			var/obj/item/organ/organ = operation_args["organ"]
			if(QDELETED(organ) || !(organ in limb))
				return FALSE
		if("insert")
			var/obj/item/organ/organ = tool
			for(var/obj/item/organ/existing_organ in limb)
				if(existing_organ.slot == organ.slot)
					return FALSE

	return TRUE

/datum/surgery_operation/limb/organ_manipulation/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	switch(operation_args[OPERATION_ACTION])
		if("remove")
			var/obj/item/organ = operation_args["organ"]
			play_operation_sound(limb, surgeon, tool, remove_preop_sound)
			display_results(
				surgeon,
				limb.owner,
				span_notice("You begin to remove [organ.name] from [limb.owner]'s [limb.plaintext_zone]..."),
				span_notice("[surgeon] begins to remove [organ.name] from [limb.owner]."),
				span_notice("[surgeon] begins to remove something from [limb.owner]."),
			)
			display_pain(limb.owner, "You feel a tugging sensation in your [limb.plaintext_zone]!")
		if("insert")
			play_operation_sound(limb, surgeon, tool, insert_preop_sound)
			display_results(
				surgeon,
				limb.owner,
				span_notice("You begin to insert [tool.name] into [limb.owner]'s [limb.plaintext_zone]..."),
				span_notice("[surgeon] begins to insert [tool.name] into [limb.owner]."),
				span_notice("[surgeon] begins to insert something into [limb.owner]."),
			)
			display_pain(limb.owner, "You can feel something being placed in your [limb.plaintext_zone]!")

/datum/surgery_operation/limb/organ_manipulation/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	switch(operation_args[OPERATION_ACTION])
		if("remove")
			play_operation_sound(limb, surgeon, tool, remove_success_sound)
			on_success_remove_organ(limb, surgeon, operation_args["organ"], tool)
		if("insert")
			play_operation_sound(limb, surgeon, tool, insert_success_sound)
			on_success_insert_organ(limb, surgeon, tool)
	if(HAS_MIND_TRAIT(surgeon, TRAIT_MORBID))
		surgeon.add_mood_event("morbid_abominable_surgery_success", /datum/mood_event/morbid_abominable_surgery_success)

/datum/surgery_operation/limb/organ_manipulation/proc/on_success_remove_organ(obj/item/bodypart/limb, mob/living/surgeon, obj/item/organ/organ, obj/item/tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully extract [organ.name] from [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] successfully extracts [organ.name] from [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] successfully extracts something from [limb.owner]'s [limb.plaintext_zone]!"),
	)
	display_pain(limb.owner, "Your [limb.plaintext_zone] throbs with pain, you can't feel your [organ.name] anymore!")
	log_combat(surgeon, limb.owner, "surgically removed [organ.name] from")
	organ.Remove(limb.owner)
	organ.forceMove(limb.owner.drop_location())
	organ.on_surgical_removal(surgeon, limb, tool)

/datum/surgery_operation/limb/organ_manipulation/proc/on_success_insert_organ(obj/item/bodypart/limb, mob/living/surgeon, obj/item/organ/organ)
	surgeon.temporarilyRemoveItemFromInventory(organ, TRUE)
	organ.pre_surgical_insertion(surgeon, limb, limb.body_zone)
	organ.Insert(limb.owner)
	organ.on_surgical_insertion(surgeon, limb, organ)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully insert [organ.name] into [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] successfully inserts [organ.name] into [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] successfully inserts something into [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "Your [limb.plaintext_zone] throbs with pain as your new [organ.name] comes to life!")

/datum/surgery_operation/limb/organ_manipulation/internal
	name = "internal organ manipulation"
	desc = "Manipulate a patient's internal organs, such as a heart or lungs."
	abstract_type = /datum/surgery_operation/limb/organ_manipulation/internal

/datum/surgery_operation/limb/organ_manipulation/internal/organ_check(obj/item/bodypart/limb, obj/item/organ/organ)
	return !(organ.organ_flags & ORGAN_EXTERNAL)

// Operating on chest organs requires bones be sawed
/datum/surgery_operation/limb/organ_manipulation/internal/chest
	replaced_by = /datum/surgery_operation/limb/organ_manipulation/internal/chest/alien

/datum/surgery_operation/limb/organ_manipulation/internal/chest/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT|SURGERY_BONE_SAWED) && limb.body_zone == BODY_ZONE_CHEST

/datum/surgery_operation/limb/organ_manipulation/internal/chest/mechanic
	name = "prosthetic organ manipulation"
	required_bodytype = BODYTYPE_ROBOTIC
	remove_implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 1,
		/obj/item/kitchen/fork = 2.85,
	)
	operation_flags = parent_type::operation_flags | OPERATION_SELF_OPERABLE

/// Abductor subtype that works through clothes and lets you extract the heart without sawing bones
/datum/surgery_operation/limb/organ_manipulation/internal/chest/alien
	name = "experimental organ manipulation"
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED

/datum/surgery_operation/limb/organ_manipulation/internal/chest/alien/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT)

/datum/surgery_operation/limb/organ_manipulation/internal/chest/alien/can_operate_on_organ(obj/item/bodypart/limb, obj/item/organ/organ, mob/living/surgeon)
	if(!..())
		return FALSE
	if(organ.slot == ORGAN_SLOT_HEART)
		return TRUE // Hearts can be manipulated so long as we pass normal state check
	if(LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED))
		return TRUE // Other organs can only be manipulated if we also pass bone sawed check
	return FALSE

// Operating on non-chest organs requires bones be intact
/datum/surgery_operation/limb/organ_manipulation/internal/other
	name = "experimental organ manipulation"
	replaced_by = /datum/surgery_operation/limb/organ_manipulation/internal/other/alien

/datum/surgery_operation/limb/organ_manipulation/internal/other/state_check(obj/item/bodypart/limb)
	if(!LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT))
		return FALSE
	if(LIMB_HAS_ANY_SURGERY_STATE(limb, SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED) && !INNATELY_LACKING_BONES(limb))
		return FALSE
	if(limb.body_zone != BODY_ZONE_CHEST)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/organ_manipulation/internal/other/mechanic
	name = "prosthetic organ manipulation"
	required_bodytype = BODYTYPE_ROBOTIC
	remove_implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 1,
		/obj/item/kitchen/fork = 2.85,
	)
	operation_flags = parent_type::operation_flags | OPERATION_SELF_OPERABLE
	replaced_by = null

/// Abductor subtype that works through clothes
/datum/surgery_operation/limb/organ_manipulation/internal/other/alien
	name = "experimental feature manipulation"
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED

// All external organ manipulation requires bones sawed
/datum/surgery_operation/limb/organ_manipulation/external
	name = "feature manipulation"
	desc = "Manipulate features of the patient, such as a moth's wings or a lizard's tail."
	replaced_by = /datum/surgery_operation/limb/organ_manipulation/external/alien

/datum/surgery_operation/limb/organ_manipulation/external/organ_check(obj/item/bodypart/limb, obj/item/organ/organ)
	return (organ.organ_flags & ORGAN_EXTERNAL)

/datum/surgery_operation/limb/organ_manipulation/external/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED|SURGERY_BONE_SAWED)

/datum/surgery_operation/limb/organ_manipulation/external/mechanic
	name = "prosthetic feature manipulation"
	required_bodytype = BODYTYPE_ROBOTIC
	remove_implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 1,
		/obj/item/kitchen/fork = 2.85,
	)
	operation_flags = parent_type::operation_flags | OPERATION_SELF_OPERABLE
	replaced_by = null

/// Abductor subtype that works through clothes
/datum/surgery_operation/limb/organ_manipulation/external/alien
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED

/datum/surgery_operation/limb/organ_manipulation/external/alien/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
