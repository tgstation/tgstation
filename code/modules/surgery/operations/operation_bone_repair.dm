// Surgical analog to manual dislocation treatment
/datum/surgery_operation/limb/repair_dislocation
	name = "reset dislocation"
	desc = "Reset a dislocated bone in a patient's limb. \
		Similar to the field procedure, but quicker and safer due to being performed in a controlled environment."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED | OPERATION_AFFECTS_MOOD | OPERATION_STANDING_ALLOWED
	implements = list(
		TOOL_BONESET = 1,
		TOOL_CROWBAR = 2,
		IMPLEMENT_HAND = 5,
	)
	time = 2.4 SECONDS

/datum/surgery_operation/limb/repair_dislocation/get_time_modifiers(obj/item/bodypart/limb, mob/living/surgeon, tool)
	. = ..()
	for(var/datum/wound/blunt/bone/bone_wound in limb.wounds)
		if(HAS_TRAIT(bone_wound, TRAIT_WOUND_SCANNED) && (TOOL_BONESET in bone_wound.treatable_tools))
			. *= 0.5

/datum/surgery_operation/limb/repair_dislocation/get_default_radial_image()
	return image(/obj/item/bonesetter)

/datum/surgery_operation/limb/repair_dislocation/all_required_strings()
	return list("the limb must be dislocated") + ..()

/datum/surgery_operation/limb/repair_dislocation/state_check(obj/item/bodypart/limb)
	for(var/datum/wound/blunt/bone/bone_wound in limb.wounds)
		if(TOOL_BONESET in bone_wound.treatable_tools)
			return TRUE

	return FALSE

/datum/surgery_operation/limb/repair_dislocation/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to reset the dislocation in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to reset the dislocation in [FORMAT_LIMB_OWNER(limb)] with [tool]."),
		span_notice("[surgeon] begins to reset the dislocation in [FORMAT_LIMB_OWNER(limb)]."),
	)
	display_pain(limb.owner, "Your [limb.plaintext_zone] aches with pain!")

/datum/surgery_operation/limb/repair_dislocation/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	for(var/datum/wound/blunt/bone/bone_wound in limb.wounds)
		if(TOOL_BONESET in bone_wound.treatable_tools)
			qdel(bone_wound)

	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully reset the dislocation in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] successfully resets the dislocation in [FORMAT_LIMB_OWNER(limb)]!"),
		span_notice("[surgeon] successfully resets the dislocation in [FORMAT_LIMB_OWNER(limb)]!"),
	)
	display_pain(limb.owner, "Your [limb.plaintext_zone] feels much better now!")

/datum/surgery_operation/limb/repair_dislocation/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You fail to reset the dislocation in [FORMAT_LIMB_OWNER(limb)], causing further damage!"),
		span_notice("[surgeon] fails to reset the dislocation in [FORMAT_LIMB_OWNER(limb)], causing further damage!"),
		span_notice("[surgeon] fails to reset the dislocation in [FORMAT_LIMB_OWNER(limb)]!"),
	)
	display_pain(limb.owner, "The pain in your [limb.plaintext_zone] intensifies!")
	limb.receive_damage(25, damage_source = tool)

/datum/surgery_operation/limb/repair_hairline
	name = "repair hairline fracture"
	desc = "Mend a hairline fracture in a patient's bone."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_BONESET = 1,
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)
	time = 4 SECONDS
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/repair_hairline/get_time_modifiers(obj/item/bodypart/limb, mob/living/surgeon, tool)
	. = ..()
	for(var/datum/wound/blunt/bone/critical/bone_wound in limb.wounds)
		if(HAS_TRAIT(bone_wound, TRAIT_WOUND_SCANNED))
			. *= 0.5

/datum/surgery_operation/limb/repair_hairline/get_default_radial_image()
	return image(/obj/item/bonesetter)

/datum/surgery_operation/limb/repair_hairline/all_required_strings()
	return list("the limb must have a hairline fracture") + ..()

/datum/surgery_operation/limb/repair_hairline/state_check(obj/item/bodypart/limb)
	if(!(locate(/datum/wound/blunt/bone/severe) in limb.wounds))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/repair_hairline/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to repair the fracture in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to repair the fracture in [FORMAT_LIMB_OWNER(limb)] with [tool]."),
		span_notice("[surgeon] begins to repair the fracture in [FORMAT_LIMB_OWNER(limb)]."),
	)
	display_pain(limb.owner, "Your [limb.plaintext_zone] aches with pain!")

/datum/surgery_operation/limb/repair_hairline/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/blunt/bone/fracture = locate() in limb.wounds
	qdel(fracture)

	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully repair the fracture in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] successfully repairs the fracture in [FORMAT_LIMB_OWNER(limb)]!"),
		span_notice("[surgeon] successfully repairs the fracture in [FORMAT_LIMB_OWNER(limb)]!"),
	)

/datum/surgery_operation/limb/reset_compound
	name = "reset compound fracture"
	desc = "Reset a compound fracture in a patient's bone, preparing it for proper healing."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_BONESET = 1,
		/obj/item/stack/sticky_tape/surgical = 1.66,
		/obj/item/stack/sticky_tape/super = 2.5,
		/obj/item/stack/sticky_tape = 5,
	)
	time = 6 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/reset_compound/get_time_modifiers(obj/item/bodypart/limb, mob/living/surgeon, tool)
	. = ..()
	for(var/datum/wound/blunt/bone/severe/bone_wound in limb.wounds)
		if(HAS_TRAIT(bone_wound, TRAIT_WOUND_SCANNED))
			. *= 0.5

/datum/surgery_operation/limb/reset_compound/get_default_radial_image()
	return image(/obj/item/bonesetter)

/datum/surgery_operation/limb/reset_compound/all_required_strings()
	return list("the limb must have a compound fracture") + ..()

/datum/surgery_operation/limb/reset_compound/state_check(obj/item/bodypart/limb)
	var/datum/wound/blunt/bone/critical/fracture = locate() in limb.wounds
	if(isnull(fracture) || fracture.reset)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/reset_compound/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to reset the bone in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to reset the bone in [FORMAT_LIMB_OWNER(limb)] with [tool]."),
		span_notice("[surgeon] begins to reset the bone in [FORMAT_LIMB_OWNER(limb)]."),
	)
	display_pain(limb.owner, "The aching pain in your [limb.plaintext_zone] is overwhelming!")

/datum/surgery_operation/limb/reset_compound/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/blunt/bone/critical/fracture = locate() in limb.wounds
	fracture?.reset = TRUE

	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully reset the bone in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] successfully resets the bone in [FORMAT_LIMB_OWNER(limb)] with [tool]!"),
		span_notice("[surgeon] successfully resets the bone in [FORMAT_LIMB_OWNER(limb)]!"),
	)

/datum/surgery_operation/limb/repair_compound
	name = "repair compound fracture"
	desc = "Mend a compound fracture in a patient's bone."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)
	time = 4 SECONDS
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/repair_compound/get_time_modifiers(obj/item/bodypart/limb, mob/living/surgeon, tool)
	. = ..()
	for(var/datum/wound/blunt/bone/critical/bone_wound in limb.wounds)
		if(HAS_TRAIT(bone_wound, TRAIT_WOUND_SCANNED))
			. *= 0.5

/datum/surgery_operation/limb/repair_compound/get_default_radial_image()
	return image(/obj/item/stack/medical/bone_gel)

/datum/surgery_operation/limb/repair_compound/all_required_strings()
	return list("the limb's compound fracture has been reset") + ..()

/datum/surgery_operation/limb/repair_compound/state_check(obj/item/bodypart/limb)
	var/datum/wound/blunt/bone/critical/fracture = locate() in limb.wounds
	if(isnull(fracture) || !fracture.reset)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/repair_compound/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to repair the fracture in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to repair the fracture in [FORMAT_LIMB_OWNER(limb)] with [tool]."),
		span_notice("[surgeon] begins to repair the fracture in [FORMAT_LIMB_OWNER(limb)]."),
	)
	display_pain(limb.owner, "The aching pain in your [limb.plaintext_zone] is overwhelming!")

/datum/surgery_operation/limb/repair_compound/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/blunt/bone/critical/fracture = locate() in limb.wounds
	qdel(fracture)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully repair the fracture in [FORMAT_LIMB_OWNER(limb)]."),
		span_notice("[surgeon] successfully repairs the fracture in [FORMAT_LIMB_OWNER(limb)] with [tool]!"),
		span_notice("[surgeon] successfully repairs the fracture in [FORMAT_LIMB_OWNER(limb)]!"),
	)

/datum/surgery_operation/limb/prepare_cranium_repair
	name = "discard skull debris"
	desc = "Clear away bone fragments and debris from a patient's cranial fissure in preparation for repair."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 2.5,
		TOOL_SCREWDRIVER = 2.5,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'

/datum/surgery_operation/limb/prepare_cranium_repair/get_time_modifiers(obj/item/bodypart/limb, mob/living/surgeon, tool)
	. = ..()
	for(var/datum/wound/cranial_fissure/fissure in limb.wounds)
		if(HAS_TRAIT(fissure, TRAIT_WOUND_SCANNED))
			. *= 0.5

/datum/surgery_operation/limb/prepare_cranium_repair/get_default_radial_image()
	return image(/obj/item/hemostat)

/datum/surgery_operation/limb/prepare_cranium_repair/all_required_strings()
	return list("the cranium must be fractured") + ..()

/datum/surgery_operation/limb/prepare_cranium_repair/state_check(obj/item/bodypart/limb)
	var/datum/wound/cranial_fissure/fissure = locate() in limb.wounds
	if(isnull(fissure) || fissure.prepped)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/prepare_cranium_repair/on_preop(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to discard the smaller skull debris in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to discard the smaller skull debris in [FORMAT_LIMB_OWNER(limb)]..."),
		span_notice("[surgeon] begins to poke around in [FORMAT_LIMB_OWNER(limb)]..."),
	)
	display_pain(limb.owner, "Your brain feels like it's getting stabbed by little shards of glass!")

/datum/surgery_operation/limb/prepare_cranium_repair/on_success(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	. = ..()
	var/datum/wound/cranial_fissure/fissure = locate() in limb.wounds
	fissure?.prepped = TRUE

/datum/surgery_operation/limb/repair_cranium
	name = "repair cranium"
	desc = "Mend a cranial fissure in a patient's skull."
	operation_flags = OPERATION_PRIORITY_NEXT_STEP | OPERATION_NO_PATIENT_REQUIRED
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)
	time = 4 SECONDS

/datum/surgery_operation/limb/repair_cranium/get_time_modifiers(obj/item/bodypart/limb, mob/living/surgeon, tool)
	. = ..()
	for(var/datum/wound/cranial_fissure/fissure in limb.wounds)
		if(HAS_TRAIT(fissure, TRAIT_WOUND_SCANNED))
			. *= 0.5

/datum/surgery_operation/limb/repair_cranium/get_default_radial_image()
	return image(/obj/item/stack/medical/bone_gel)

/datum/surgery_operation/limb/repair_cranium/all_required_strings()
	return list("the debris has been cleared from the cranial fissure") + ..()

/datum/surgery_operation/limb/repair_cranium/state_check(obj/item/bodypart/limb)
	var/datum/wound/cranial_fissure/fissure = locate() in limb.wounds
	if(isnull(fissure) || !fissure.prepped)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/repair_cranium/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to repair [limb.owner || limb]'s skull as best you can..."),
		span_notice("[surgeon] begins to repair [limb.owner || limb]'s skull with [tool]."),
		span_notice("[surgeon] begins to repair [limb.owner || limb]'s skull."),
	)

	display_pain(limb.owner, "You can feel pieces of your skull rubbing against your brain!")

/datum/surgery_operation/limb/repair_cranium/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/cranial_fissure/fissure = locate() in limb.wounds
	qdel(fissure)

	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully repair [limb.owner || limb]'s skull."),
		span_notice("[surgeon] successfully repairs [limb.owner || limb]'s skull with [tool]."),
		span_notice("[surgeon] successfully repairs [limb.owner || limb]'s skull.")
	)
