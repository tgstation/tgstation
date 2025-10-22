/datum/surgery_operation/implant_removal
	name = "implant removal"
	desc = "Attempt to remove an implant from a patient."
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_CROWBAR = 0.65,
		/obj/item/kitchen/fork = 0.35,
	)
	time = 6.4 SECONDS
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'

/datum/surgery_operation/implant_removal/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/hemostat)
	return base

/datum/surgery_operation/implant_removal/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state < SURGERY_VESSELS_CLAMPED)
		return FALSE
	return TRUE

/datum/surgery_operation/implant_removal/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to extract something from [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to extract something from [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to extract something from [limb.owner]'s [limb.plaintext_zone]."),
	)
	if(LAZYLEN(limb.owner.implants))
		display_pain(surgeon, "You feel a serious pain in your [limb.plaintext_zone]!")

/datum/surgery_operation/implant_removal/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	var/obj/item/implant/implant = LAZYACCESS(limb.owner.implants, 1)
	if(!implant)
		display_results(
			surgeon,
			limb.owner,
			span_warning("You find no implant to remove from [limb.owner]'s [limb.plaintext_zone]."),
			span_warning("[surgeon] finds no implant to remove from [limb.owner]'s [limb.plaintext_zone]."),
			span_warning("[surgeon] finds nothing to remove from [limb.owner]'s [limb.plaintext_zone]."),
		)
		return

	display_results(
		surgeon,
		limb.owner,
		span_notice("You successfully remove [implant] from [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] successfully removes [implant] from [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] successfully removes something from [limb.owner]'s [limb.plaintext_zone]!"),
	)
	display_pain(limb.owner, "You can feel your [implant.name] pulled out of you!")
	implant.removed(limb.owner)

	if(QDELETED(implant))
		return

	var/obj/item/implantcase/case = get_case(surgeon, limb.owner)
	if(isnull(case))
		return

	case.imp = implant
	implant.forceMove(case)
	case.update_appearance()
	display_results(
		surgeon,
		limb.owner,
		span_notice("You place [implant] into [case]."),
		span_notice("[surgeon] places [implant] into [case]."),
		span_notice("[surgeon] places something into [case]."),
	)

/datum/surgery_operation/implant_removal/proc/get_case(mob/living/surgeon, mob/living/target)
	var/list/locations = list(
		surgeon.is_holding_item_of_type(/obj/item/implantcase),
		locate(/obj/item/implantcase) in surgeon.loc,
		locate(/obj/item/implantcase) in target.loc,
	)

	for(var/obj/item/implantcase/case in locations)
		if(!case.imp)
			return case

	return null
