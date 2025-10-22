// Mechanical equivalents of basic surgical operations

/// Mechanical equivalent of cutting skin
/datum/surgery_operation/mechanical_incision
	name = "unscrew shell"
	desc = "Unscrew the shell of a mechanical patient to access its internals."
	implements = list(
		TOOL_SCREWDRIVER = 1,
		TOOL_SCALPEL = 0.75,
		/obj/item/knife = 0.50,
		/obj/item = 0.10,
	)
	required_bodytype = BODYTYPE_ROBOTIC
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'

/datum/surgery_operation/mechanical_incision/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/screwdriver)
	return base

/datum/surgery_operation/mechanical_incision/tool_check(obj/item/tool)
	// Require sharpness OR a tool behavior match
	return (tool.get_sharpness() || implements[tool.tool_behaviour])

/datum/surgery_operation/mechanical_incision/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state != SURGERY_SKIN_CLOSED)
		return FALSE
	return TRUE

/datum/surgery_operation/mechanical_incision/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to make an unscrew the shell of [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to unscrew the shell of [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to unscrew the shell of [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel your [limb.plaintext_zone] grow numb as the shell is unscrewed.", TRUE)

/datum/surgery_operation/mechanical_incision/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.surgery_skin_state = SURGERY_SKIN_CUT

/// Mechanical equivalent of opening skin and clamping vessels
/datum/surgery_operation/mechanical_open
	name = "open hatch"
	desc = "Open the hatch of a mechanical patient to access its internals."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		IMPLEMENT_HAND = 1,
		TOOL_CROWBAR = 1,
	)
	time = 1 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'
	success_sound = 'sound/machines/airlock/doorclick.ogg'

/datum/surgery_operation/mechanical_open/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(image('icons/hud/screen_gen.dmi', "arrow_large_still"))
	return base

/datum/surgery_operation/mechanical_open/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state != SURGERY_SKIN_CUT)
		return FALSE
	return TRUE

/datum/surgery_operation/mechanical_open/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to open the hatch holders in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to open the hatch holders in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to open the hatch holders in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "The last faint pricks of tactile sensation fade from your [limb.plaintext_zone] as the hatch is opened.", TRUE)

/datum/surgery_operation/mechanical_open/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.surgery_skin_state = SURGERY_SKIN_OPEN
	limb.surgery_vessel_state = SURGERY_VESSELS_CLAMPED

/// Mechanical equivalent of cauterizing / closing skin
/datum/surgery_operation/mechanical_close
	name = "screw shell"
	desc = "Screw the shell of a mechanical patient back into place."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_SCREWDRIVER = 1,
		TOOL_SCALPEL = 0.75,
		/obj/item/knife = 0.50,
		/obj/item = 0.10,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/screwdriver.ogg'
	success_sound = 'sound/items/tools/screwdriver2.ogg'

/datum/surgery_operation/mechanical_close/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/screwdriver)
	return base

/datum/surgery_operation/mechanical_close/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	return TRUE

/datum/surgery_operation/mechanical_close/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to screw the shell of [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to screw the shell of [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to screw the shell of [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel the faint pricks of sensation return as your [limb.plaintext_zone]'s shell is screwed in.", TRUE)

/datum/surgery_operation/mechanical_close/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.surgery_skin_state = SURGERY_SKIN_CLOSED
	limb.surgery_vessel_state = SURGERY_VESSELS_NORMAL

// Mechanical equivalent of cutting vessels and organs
/datum/surgery_operation/prepare_electronics
	name = "prepare electronics"
	desc = "Prepare the internal electronics of a mechanical patient for surgery."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_MULTITOOL = 1,
		TOOL_HEMOSTAT = 0.75,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/taperecorder/tape_flip.ogg'
	success_sound = 'sound/items/taperecorder/taperecorder_close.ogg'

/datum/surgery_operation/prepare_electronics/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/multitool)
	return base

/datum/surgery_operation/prepare_electronics/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to prepare electronics in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to prepare electronics in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to prepare electronics in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You can feel a faint buzz in your [limb.plaintext_zone] as the electronics reboot.", TRUE)

/datum/surgery_operation/prepare_electronics/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.surgery_vessel_state = SURGERY_VESSELS_ORGANS_CUT

// Mechanical equivalent of sawing bone
/datum/surgery_operation/mechanic_unwrench
	name = "unwrench"
	desc = "Unwrench a mechanical patient to access its internals."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_WRENCH = 1,
		TOOL_RETRACTOR = 0.75,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'

/datum/surgery_operation/mechanic_unwrench/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/wrench)
	return base

/datum/surgery_operation/mechanic_unwrench/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to unwrench some bolts in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to unwrench some bolts in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to unwrench some bolts in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a jostle in your [limb.plaintext_zone] as the bolts begin to loosen.", TRUE)

/datum/surgery_operation/mechanic_unwrench/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.surgery_bone_state = SURGERY_BONE_SAWED

// Mechanical equivalent of unsawing bone
/datum/surgery_operation/mechanic_wrench
	name = "wrench"
	desc = "Wrench a mechanical patient back into place."
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		TOOL_WRENCH = 1,
		TOOL_RETRACTOR = 0.75,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/tools/ratchet.ogg'

/datum/surgery_operation/mechanic_wrench/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/wrench)
	return base

/datum/surgery_operation/mechanic_wrench/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to wrench some bolts in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to wrench some bolts in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to wrench some bolts in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a jostle in your [limb.plaintext_zone] as the bolts begin to tighten.", TRUE)

/datum/surgery_operation/mechanic_wrench/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.surgery_bone_state = SURGERY_BONE_INTACT
