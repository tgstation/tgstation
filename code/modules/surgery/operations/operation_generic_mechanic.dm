// Mechanical equivalents of basic surgical operations
/// Mechanical equivalent of cutting skin
/datum/surgery_operation/limb/mechanical_incision
	name = "unscrew shell"
	desc = "Unscrew the shell of a mechanical patient to access its internals. \
		Causes \"cut skin\" surgical state."
	implements = list(
		TOOL_SCREWDRIVER = 1,
		TOOL_SCALPEL = 1.33,
		/obj/item/knife = 2,
		/obj/item = 10, // i think this amounts to a 180% chance of failure (clamped to 99%)
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	required_bodytype = BODYTYPE_ROBOTIC
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'
	any_surgery_states_blocked = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/mechanical_incision/get_any_tool()
	return "Any sharp item"

/datum/surgery_operation/limb/mechanical_incision/get_default_radial_image()
	return image(/obj/item/screwdriver)

/datum/surgery_operation/limb/mechanical_incision/tool_check(obj/item/tool)
	// Require any sharpness OR a tool behavior match
	return (tool.get_sharpness() || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/mechanical_incision/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to unscrew the shell of [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to unscrew the shell of [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to unscrew the shell of [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel your [limb.plaintext_zone] grow numb as the shell is unscrewed.", TRUE)

/datum/surgery_operation/limb/mechanical_incision/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_SKIN_CUT)

/// Mechanical equivalent of opening skin and clamping vessels
/datum/surgery_operation/limb/mechanical_open
	name = "open hatch"
	desc = "Open the hatch of a mechanical patient to access its internals. \
		Causes \"skin open\" and \"vessels clamped\" surgical states."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		IMPLEMENT_HAND = 1,
		TOOL_CROWBAR = 1,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 1 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'
	all_surgery_states_required = SURGERY_SKIN_CUT

/datum/surgery_operation/limb/mechanical_open/get_default_radial_image()
	return image('icons/hud/screen_gen.dmi', "arrow_large_still")

/datum/surgery_operation/limb/mechanical_open/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to open the hatch holders in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to open the hatch holders in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to open the hatch holders in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "The last faint pricks of tactile sensation fade from your [limb.plaintext_zone] as the hatch is opened.", TRUE)

/datum/surgery_operation/limb/mechanical_open/on_success(obj/item/bodypart/limb)
	. = ..()
	// We get both vessels and skin done at the same time wowee
	limb.add_surgical_state(SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED)
	limb.remove_surgical_state(SURGERY_SKIN_CUT)

/// Mechanical equivalent of cauterizing / closing skin
/datum/surgery_operation/limb/mechanical_close
	name = "screw shell"
	desc = "Screw the shell of a mechanical patient back into place. \
		Clears most surgical states."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_SCREWDRIVER = 1,
		TOOL_SCALPEL = 1.33,
		/obj/item/knife = 2,
		/obj/item = 10,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/mechanical_close/get_any_tool()
	return "Any sharp item"

/datum/surgery_operation/limb/mechanical_close/get_default_radial_image()
	return image(/obj/item/screwdriver)

/datum/surgery_operation/limb/mechanical_close/tool_check(obj/item/tool)
	// Require any sharpness OR a tool behavior match
	return (tool.get_sharpness() || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/mechanical_close/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_SKIN(limb)

/datum/surgery_operation/limb/mechanical_close/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to screw the shell of [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to screw the shell of [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to screw the shell of [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel the faint pricks of sensation return as your [limb.plaintext_zone]'s shell is screwed in.", TRUE)

/datum/surgery_operation/limb/mechanical_close/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)

// Mechanical equivalent of cutting vessels and organs
/datum/surgery_operation/limb/prepare_electronics
	name = "prepare electronics"
	desc = "Prepare the internal electronics of a mechanical patient for surgery. \
		Causes \"organs cut\" surgical state."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_MULTITOOL = 1,
		TOOL_HEMOSTAT = 1.33,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 2.4 SECONDS
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_ORGANS_CUT

/datum/surgery_operation/limb/prepare_electronics/get_default_radial_image()
	return image(/obj/item/multitool)

/datum/surgery_operation/limb/prepare_electronics/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to prepare electronics in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to prepare electronics in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to prepare electronics in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You can feel a faint buzz in your [limb.plaintext_zone] as the electronics reboot.", TRUE)

/datum/surgery_operation/limb/prepare_electronics/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_ORGANS_CUT)

// Mechanical equivalent of sawing bone
/datum/surgery_operation/limb/mechanic_unwrench
	name = "unwrench endoskeleton"
	desc = "Unwrench a mechanical patient's endoskeleton to access its internals. \
		Clears \"bone sawed\" surgical state."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_WRENCH = 1,
		TOOL_RETRACTOR = 1.33,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED

/datum/surgery_operation/limb/mechanic_unwrench/get_default_radial_image()
	return image(/obj/item/wrench)

/datum/surgery_operation/limb/mechanic_unwrench/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to unwrench some bolts in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to unwrench some bolts in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to unwrench some bolts in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a jostle in your [limb.plaintext_zone] as the bolts begin to loosen.", TRUE)

/datum/surgery_operation/limb/mechanic_unwrench/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.add_surgical_state(SURGERY_BONE_SAWED)

// Mechanical equivalent of unsawing bone
/datum/surgery_operation/limb/mechanic_wrench
	name = "wrench endoskeleton"
	desc = "Wrench a mechanical patient's endoskeleton back into place. \
		Clears \"bone sawed\" surgical state."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_WRENCH = 1,
		TOOL_RETRACTOR = 1.33,
	)
	operation_flags = OPERATION_SELF_OPERABLE | OPERATION_MECHANIC
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED

/datum/surgery_operation/limb/mechanic_wrench/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_BONES(limb)

/datum/surgery_operation/limb/mechanic_wrench/all_required_strings()
	return ..() + list("the limb must have bones")

/datum/surgery_operation/limb/mechanic_wrench/get_default_radial_image()
	return image(/obj/item/wrench)

/datum/surgery_operation/limb/mechanic_wrench/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to wrench some bolts in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to wrench some bolts in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to wrench some bolts in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a jostle in your [limb.plaintext_zone] as the bolts begin to tighten.", TRUE)

/datum/surgery_operation/limb/mechanic_wrench/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.remove_surgical_state(SURGERY_BONE_SAWED)
