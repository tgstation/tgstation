/datum/surgery_operation/basic/implant_removal
	name = "implant removal"
	desc = "Attempt to find and remove an implant from a patient. \
		Any implant found will be destroyed unless an implant case is held or nearby."
	operation_flags = OPERATION_NOTABLE
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 1.5,
		/obj/item/kitchen/fork = 2.85,
	)
	time = 6.4 SECONDS
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED

/datum/surgery_operation/basic/implant_removal/get_default_radial_image()
	return image('icons/obj/medical/syringe.dmi', "implantcase-b")

/datum/surgery_operation/basic/implant_removal/any_optional_strings()
	return ..() + list("have an implant case below or inhand to store removed implants")

/datum/surgery_operation/basic/implant_removal/on_preop(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("You search for implants in [patient]..."),
		span_notice("[surgeon] searches for implants in [patient]."),
		span_notice("[surgeon] searches for something in [patient]."),
	)
	if(LAZYLEN(patient.implants))
		display_pain(patient, "You feel a serious pain as [surgeon] digs around inside you!")

/datum/surgery_operation/basic/implant_removal/on_success(mob/living/patient, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/implant/implant = LAZYACCESS(patient.implants, 1)
	if(isnull(implant))
		display_results(
			surgeon,
			patient,
			span_warning("You find no implant to remove from [patient]."),
			span_warning("[surgeon] finds no implant to remove from [patient]."),
			span_warning("[surgeon] finds nothing to remove from [patient]."),
		)
		return

	display_results(
		surgeon,
		patient,
		span_notice("You successfully remove [implant] from [patient]."),
		span_notice("[surgeon] successfully removes [implant] from [patient]!"),
		span_notice("[surgeon] successfully removes something from [patient]!"),
	)
	display_pain(patient, "You can feel your [implant.name] pulled out of you!")
	implant.removed(patient)

	if(QDELETED(implant))
		return

	var/obj/item/implantcase/case = get_case(surgeon, patient)
	if(isnull(case))
		return

	case.imp = implant
	implant.forceMove(case)
	case.update_appearance()
	display_results(
		surgeon,
		patient,
		span_notice("You place [implant] into [case]."),
		span_notice("[surgeon] places [implant] into [case]."),
		span_notice("[surgeon] places something into [case]."),
	)

/datum/surgery_operation/basic/implant_removal/proc/get_case(mob/living/surgeon, mob/living/target)
	var/list/locations = list(
		surgeon.is_holding_item_of_type(/obj/item/implantcase),
		locate(/obj/item/implantcase) in surgeon.loc,
		locate(/obj/item/implantcase) in target.loc,
	)

	for(var/obj/item/implantcase/case in locations)
		if(!case.imp)
			return case

	return null
