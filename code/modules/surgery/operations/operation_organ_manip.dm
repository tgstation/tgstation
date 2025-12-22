#define OPERATION_REMOVED_ORGAN "removed_organ"

/// Adding or removing specific organs
/datum/surgery_operation/limb/organ_manipulation
	name = "organ manipulation"
	abstract_type = /datum/surgery_operation/limb/organ_manipulation
	operation_flags = OPERATION_MORBID | OPERATION_NOTABLE
	required_bodytype = ~BODYTYPE_ROBOTIC
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

/datum/surgery_operation/limb/organ_manipulation/get_default_radial_image()
	return image('icons/obj/medical/surgery_ui.dmi', "surgery_any")

/// Checks that the passed organ can be inserted/removed
/datum/surgery_operation/limb/organ_manipulation/proc/organ_check(obj/item/bodypart/limb, obj/item/organ/organ)
	return TRUE

/// Checks that the passed organ can be inserted/removed in the specified zones
/datum/surgery_operation/limb/organ_manipulation/proc/zone_check(obj/item/organ/organ, limb_zone, operated_zone)
	SHOULD_CALL_PARENT(TRUE)

	if(LAZYLEN(organ.valid_zones))
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

/// Get a list of organs that can be removed from the limb in the specified zone
/datum/surgery_operation/limb/organ_manipulation/proc/get_removable_organs(obj/item/bodypart/limb, operated_zone)
	var/list/removable_organs = list()
	for(var/obj/item/organ/organ in limb)
		if(!organ_check(limb, organ) || (organ.organ_flags & ORGAN_UNREMOVABLE))
			continue
		if(!zone_check(organ, limb.body_zone, operated_zone))
			continue
		removable_organs += organ

	return removable_organs

/// Check if removing an organ is possible
/datum/surgery_operation/limb/organ_manipulation/proc/is_remove_available(obj/item/bodypart/limb, operated_zone)
	return length(get_removable_organs(limb, operated_zone)) > 0

/// Check if inserting an organ is possible
/datum/surgery_operation/limb/organ_manipulation/proc/is_insert_available(obj/item/bodypart/limb, obj/item/organ/organ, operated_zone)
	if(!organ_check(limb, organ) || (organ.organ_flags & ORGAN_UNUSABLE))
		return FALSE

	for(var/obj/item/organ/other_organ in limb)
		if(other_organ.slot == organ.slot)
			return FALSE

	if(!zone_check(organ, limb.body_zone, operated_zone))
		return FALSE

	return TRUE

/datum/surgery_operation/limb/organ_manipulation/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, operated_zone)
	return isorgan(tool) ? is_insert_available(limb, tool, operated_zone) : is_remove_available(limb, operated_zone)

/datum/surgery_operation/limb/organ_manipulation/get_radial_options(obj/item/bodypart/limb, obj/item/tool, operating_zone)
	return isorgan(tool) ? get_insert_options(limb, tool, operating_zone) : get_remove_options(limb, operating_zone)

/datum/surgery_operation/limb/organ_manipulation/proc/get_remove_options(obj/item/bodypart/limb, operating_zone)
	var/list/options = list()
	for(var/obj/item/organ/organ as anything in get_removable_organs(limb, operating_zone))
		var/datum/radial_menu_choice/option = LAZYACCESS(cached_organ_manipulation_options, "[organ.type]_remove")
		if(!option)
			option = new()
			option.image = get_generic_limb_radial_image(limb.body_zone)
			option.image.overlays += add_radial_overlays(organ.type)
			option.name = "remove [initial(organ.name)]"
			option.info = "Remove [initial(organ.name)] from the patient."
			LAZYSET(cached_organ_manipulation_options, "[organ.type]_remove", option)

		options[option] = list("[OPERATION_ACTION]" = "remove", "[OPERATION_REMOVED_ORGAN]" = organ)

	return options

/datum/surgery_operation/limb/organ_manipulation/proc/get_insert_options(obj/item/bodypart/limb, obj/item/organ/organ)
	var/datum/radial_menu_choice/option = LAZYACCESS(cached_organ_manipulation_options, "[organ.type]_insert")
	if(!option)
		option = new()
		option.image = get_generic_limb_radial_image(limb.body_zone)
		option.image.overlays += add_radial_overlays(list(image('icons/hud/screen_gen.dmi', "arrow_large_still"), organ.type))
		option.name = "insert [initial(organ.name)]"
		option.info = "insert [initial(organ.name)] into the patient."
		LAZYSET(cached_organ_manipulation_options, "[organ.type]_insert", option)

	var/list/result = list()
	result[option] = list("[OPERATION_ACTION]" = "insert")
	return result

/datum/surgery_operation/limb/organ_manipulation/operate_check(mob/living/patient, obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	if(!..())
		return FALSE

	switch(operation_args[OPERATION_ACTION])
		if("remove")
			var/obj/item/organ/organ = operation_args[OPERATION_REMOVED_ORGAN]
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
			var/obj/item/organ = operation_args[OPERATION_REMOVED_ORGAN]
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
			on_success_remove_organ(limb, surgeon, operation_args[OPERATION_REMOVED_ORGAN], tool)
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
	desc = "Manipulate a patient's internal organs."
	replaced_by = /datum/surgery_operation/limb/organ_manipulation/internal/abductor
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

	var/bone_locked_organs = "the brain or any chest organs"

/datum/surgery_operation/limb/organ_manipulation/internal/organ_check(obj/item/bodypart/limb, obj/item/organ/organ)
	if(organ.organ_flags & ORGAN_EXTERNAL)
		return FALSE
	// chest organs and the brain require bone sawed
	if(organ.zone == BODY_ZONE_CHEST || organ.slot == ORGAN_SLOT_BRAIN)
		return !LIMB_HAS_BONES(limb) || LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED)
	return TRUE

/datum/surgery_operation/limb/organ_manipulation/internal/any_required_strings()
	return ..() + list(
		"if operating on [bone_locked_organs], the bone MUST be sawed",
		"otherwise, the state of the bone doesn't matter",
	)

/datum/surgery_operation/limb/organ_manipulation/internal/mechanic
	name = "prosthetic organ manipulation"
	required_bodytype = BODYTYPE_ROBOTIC
	remove_implements = list(
		TOOL_CROWBAR = 1,
		TOOL_HEMOSTAT = 1,
		/obj/item/kitchen/fork = 2.85,
	)
	operation_flags = parent_type::operation_flags | OPERATION_SELF_OPERABLE | OPERATION_MECHANIC

/// Abductor subtype that works through clothes and lets you extract the heart without sawing bones
/datum/surgery_operation/limb/organ_manipulation/internal/abductor
	name = "experimental organ manipulation"
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED | OPERATION_NO_WIKI
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED
	bone_locked_organs = "the brain or any chest organs EXCLUDING the heart"

/datum/surgery_operation/limb/organ_manipulation/internal/abductor/organ_check(obj/item/bodypart/limb, obj/item/organ/organ)
	return (organ.slot == ORGAN_SLOT_HEART) || ..() // Hearts can always be removed, it doesn't check for bone state

// All external organ manipulation requires bones sawed
/datum/surgery_operation/limb/organ_manipulation/external
	name = "feature manipulation"
	desc = "Manipulate features of the patient, such as a moth's wings or a lizard's tail."
	replaced_by = /datum/surgery_operation/limb/organ_manipulation/external/abductor
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED|SURGERY_BONE_SAWED

/datum/surgery_operation/limb/organ_manipulation/external/organ_check(obj/item/bodypart/limb, obj/item/organ/organ)
	return (organ.organ_flags & ORGAN_EXTERNAL)

/datum/surgery_operation/limb/organ_manipulation/external/mechanic
	name = "prosthetic feature manipulation"
	required_bodytype = BODYTYPE_ROBOTIC
	remove_implements = list(
		TOOL_CROWBAR = 1,
		TOOL_HEMOSTAT = 1,
		/obj/item/kitchen/fork = 2.85,
	)
	operation_flags = parent_type::operation_flags | OPERATION_SELF_OPERABLE
	replaced_by = null

/// Abductor subtype that works through clothes
/datum/surgery_operation/limb/organ_manipulation/external/abductor
	name = "experimental feature manipulation"
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED | OPERATION_NO_WIKI
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED

#undef OPERATION_REMOVED_ORGAN
