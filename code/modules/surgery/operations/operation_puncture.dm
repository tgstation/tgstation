/datum/surgery_operation/limb/repair_puncture
	name = "realign blood vessels"
	desc = "Realign a patient's torn blood vessels to prepare for sealing."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_SCALPEL = 1.15,
		TOOL_WIRECUTTER = 2.5,
	)
	time = 3 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_PRIORITY_NEXT_STEP
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

/datum/surgery_operation/limb/repair_puncture/get_default_radial_image()
	return image(/obj/item/hemostat)

/datum/surgery_operation/limb/repair_puncture/all_required_strings()
	return list("the limb must have an unoperated puncture wound") + ..()

/datum/surgery_operation/limb/repair_puncture/state_check(obj/item/bodypart/limb)
	var/datum/wound/pierce/bleed/pierce_wound = locate() in limb.wounds
	if(isnull(pierce_wound) || pierce_wound.blood_flow <= 0 || pierce_wound.mend_state)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/repair_puncture/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to realign the torn blood vessels in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to realign the torn blood vessels in [limb.owner]'s [limb.plaintext_zone] with [tool]."),
		span_notice("[surgeon] begins to realign the torn blood vessels in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a horrible stabbing pain in your [limb.plaintext_zone]!")

/datum/surgery_operation/limb/repair_puncture/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/pierce/bleed/pierce_wound = locate() in limb.wounds
	pierce_wound?.adjust_blood_flow(-0.25)
	limb.receive_damage(3, wound_bonus = CANT_WOUND, sharpness = tool.get_sharpness(), damage_source = tool)

	if(QDELETED(pierce_wound))
		display_results(
			surgeon,
			limb.owner,
			span_notice("You successfully realign the last of the torn blood vessels in [limb.owner]'s [limb.plaintext_zone]."),
			span_notice("[surgeon] successfully realigns the last of the torn blood vessels in [limb.owner]'s [limb.plaintext_zone] with [tool]!"),
			span_notice("[surgeon] successfully realigns the last of the torn blood vessels in  [limb.owner]'s [limb.plaintext_zone]!"),
		)
		return

	pierce_wound?.mend_state = TRUE
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully realign some of the blood vessels in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] successfully realigns some of the blood vessels in [limb.owner]'s [limb.plaintext_zone] with [tool]!"),
		span_notice("[surgeon] successfully realigns some of the blood vessels in  [limb.owner]'s [limb.plaintext_zone]!"),
	)

/datum/surgery_operation/limb/repair_puncture/on_failure(obj/item/bodypart/limb, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You jerk apart some of the blood vessels in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] jerks apart some of the blood vessels in [limb.owner]'s [limb.plaintext_zone] with [tool]!"),
		span_notice("[surgeon] jerks apart some of the blood vessels in [limb.owner]'s [limb.plaintext_zone]."),
	)
	limb.receive_damage(rand(4, 8), wound_bonus = 10, sharpness = SHARP_EDGED, damage_source = tool)

/datum/surgery_operation/limb/seal_veins
	name = "seal blood vessels"
	// rnd_name = "Anastomosis (Seal Blood Vessels)" // doctor says this is the term to use but it fits awkwardly
	desc = "Seal a patient's now-realigned blood vessels."
	implements = list(
		TOOL_CAUTERY = 1,
		/obj/item/gun/energy/laser = 1.12,
		TOOL_WELDER = 1.5,
		/obj/item = 3.33,
	)
	time = 3.2 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD | OPERATION_PRIORITY_NEXT_STEP
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_ORGANS_CUT

/datum/surgery_operation/limb/seal_veins/get_default_radial_image()
	return image(/obj/item/cautery)

/datum/surgery_operation/limb/seal_veins/get_any_tool()
	return "Any heat source"

/datum/surgery_operation/limb/seal_veins/all_required_strings()
	return list("the limb must have an operated puncture wound") + ..()

/datum/surgery_operation/limb/seal_veins/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/gun/energy/laser))
		var/obj/item/gun/energy/laser/lasergun = tool
		return lasergun.cell?.charge > 0

	return tool.get_temperature() > 0

/datum/surgery_operation/limb/seal_veins/state_check(obj/item/bodypart/limb)
	var/datum/wound/pierce/bleed/pierce_wound = locate() in limb.wounds
	if(isnull(pierce_wound) || pierce_wound.blood_flow <= 0 || !pierce_wound.mend_state)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/seal_veins/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to seal the realigned blood vessels in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to seal the realigned blood vessels in [limb.owner]'s [limb.plaintext_zone] with [tool]."),
		span_notice("[surgeon] begins to seal the realigned blood vessels in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a burning sensation in your [limb.plaintext_zone]!")

/datum/surgery_operation/limb/seal_veins/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/datum/wound/pierce/bleed/pierce_wound = locate() in limb.wounds
	pierce_wound?.adjust_blood_flow(-0.5)

	if(QDELETED(pierce_wound))
		display_results(
			surgeon,
			limb.owner,
			span_notice("You successfully seal the last of the ruptured blood vessels in [limb.owner]'s [limb.plaintext_zone]."),
			span_notice("[surgeon] successfully seals the last of the ruptured blood vessels in [limb.owner]'s [limb.plaintext_zone] with [tool]!"),
			span_notice("[surgeon] successfully seals the last of the ruptured blood vessels in  [limb.owner]'s [limb.plaintext_zone]!"),
		)
		return

	pierce_wound?.mend_state = FALSE
	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully seal some of the blood vessels in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] successfully seals some of the blood vessels in [limb.owner]'s [limb.plaintext_zone] with [tool]!"),
		span_notice("[surgeon] successfully seals some of the blood vessels in  [limb.owner]'s [limb.plaintext_zone]!"),
	)
