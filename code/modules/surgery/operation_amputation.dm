/datum/surgery_operation/amputate
	name = "amputate limb"
	desc = "Sever a limb from the patient's body."
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		/obj/item/shears = 3,
		TOOL_SCALPEL = 1,
		TOOL_SAW = 1,
		/obj/item/shovel/serrated = 0.75,
		/obj/item/melee/arm_blade = 0.8,
		/obj/item/fireaxe = 0.5,
		/obj/item/hatchet = 0.4,
		/obj/item/knife/butcher = 0.25,
	)
	time = 6.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'

/datum/surgery_operation/amputate/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/circular_saw)
	return base

/datum/surgery_operation/amputate/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_bone_state < SURGERY_BONE_SAWED)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_VESSELS_CLAMPED)
		return FALSE
	if(limb.body_zone == BODY_ZONE_CHEST)
		return FALSE
	if(limb.bodypart_flags & BODYPART_UNREMOVABLE)
		return FALSE
	if(HAS_TRAIT(limb.owner, TRAIT_NODISMEMBER))
		return FALSE
	return TRUE

/datum/surgery_operation/amputate/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to sever [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to sever [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to sever [limb.owner]'s [limb.plaintext_zone] with [tool]."),
	)
	display_pain(limb.owner, "You feel a gruesome pain in your [limb.plaintext_zone]'s joint!")

/datum/surgery_operation/amputate/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully amputate [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] successfully amputates [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] finishes severing [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You can no longer feel your [limb.plaintext_zone]!")
	if(HAS_MIND_TRAIT(surgeon, TRAIT_MORBID))
		surgeon.add_mood_event("morbid_dissection_success", /datum/mood_event/morbid_dissection_success)
	limb.drop_limb()

/datum/surgery_operation/amputate/mechanic
	name = "disassemble limb"
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		/obj/item/shovel/giant_wrench = 3,
		TOOL_WRENCH = 1,
		TOOL_CROWBAR = 1,
		TOOL_SCALPEL = 0.5,
		TOOL_SAW = 0.5,
	)
	time = 2 SECONDS //WAIT I NEED THAT!!
	preop_sound = 'sound/items/tools/ratchet.ogg'
	preop_sound = 'sound/machines/airlock/doorclick.ogg'

/datum/surgery_operation/amputate/mechanic/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	return TRUE

/datum/surgery_operation/amputate/pegleg
	name = "detach peg leg"
	required_bodytype = BODYTYPE_PEG
	implements = list(
		TOOL_SAW = 1,
		/obj/item/shovel/serrated = 1,
		/obj/item/fireaxe = 0.9,
		/obj/item/hatchet = 0.75,
		TOOL_SCALPEL = 0.25,
	)
	time = 3 SECONDS
	preop_sound = 'sound/items/handling/surgery/saw.ogg'
	success_sound = 'sound/items/handling/materials/wood_drop.ogg'

/datum/surgery_operation/amputate/mechanic/state_check(obj/item/bodypart/limb)
	return TRUE
