/datum/surgery_operation/limb/amputate
	name = "amputate limb"
	desc = "Sever a limb from the patient's body."
	operation_flags = OPERATION_MORBID | OPERATION_AFFECTS_MOOD
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		/obj/item/shears = 0.33,
		TOOL_SCALPEL = 1,
		TOOL_SAW = 1,
		/obj/item/melee/arm_blade = 1.25,
		/obj/item/shovel/serrated = 1.33,
		/obj/item/fireaxe = 2,
		/obj/item/hatchet = 2.5,
		/obj/item/knife/butcher = 4,
	)
	time = 6.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'

/datum/surgery_operation/limb/amputate/get_default_radial_image()
	return image(/obj/item/circular_saw)

/datum/surgery_operation/limb/amputate/state_check(obj/item/bodypart/limb)
	if(!LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_BONE_SAWED|SURGERY_VESSELS_CLAMPED))
		return FALSE
	if(limb.body_zone == BODY_ZONE_CHEST)
		return FALSE
	if(limb.bodypart_flags & BODYPART_UNREMOVABLE)
		return FALSE
	if(HAS_TRAIT(limb.owner, TRAIT_NODISMEMBER))
		return FALSE
	return TRUE

/datum/surgery_operation/limb/amputate/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to sever [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to sever [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to sever [limb.owner]'s [limb.plaintext_zone] with [tool]."),
	)
	display_pain(limb.owner, "You feel a gruesome pain in your [limb.plaintext_zone]'s joint!")

/datum/surgery_operation/limb/amputate/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
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

/datum/surgery_operation/limb/amputate/mechanic
	name = "disassemble limb"
	required_bodytype = BODYTYPE_ROBOTIC
	implements = list(
		/obj/item/shovel/giant_wrench = 0.33,
		TOOL_WRENCH = 1,
		TOOL_CROWBAR = 1,
		TOOL_SCALPEL = 2,
		TOOL_SAW = 2,
	)
	time = 2 SECONDS //WAIT I NEED THAT!!
	preop_sound = 'sound/items/tools/ratchet.ogg'
	preop_sound = 'sound/machines/airlock/doorclick.ogg'

/datum/surgery_operation/limb/amputate/mechanic/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN)

/datum/surgery_operation/limb/amputate/pegleg
	name = "detach peg leg"
	required_bodytype = BODYTYPE_PEG
	implements = list(
		TOOL_SAW = 1,
		/obj/item/shovel/serrated = 1,
		/obj/item/fireaxe = 1.15,
		/obj/item/hatchet = 1.33,
		TOOL_SCALPEL = 4,
	)
	time = 3 SECONDS
	preop_sound = 'sound/items/handling/surgery/saw.ogg'
	success_sound = 'sound/items/handling/materials/wood_drop.ogg'

/datum/surgery_operation/limb/amputate/mechanic/state_check(obj/item/bodypart/limb)
	return TRUE
