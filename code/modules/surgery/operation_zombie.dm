/datum/surgery_operation/limb/bionecrosis
	name = "bionecrosis"
	desc = "Inject reagents that stimulate the growth of a Romerol tumor inside the patient's brain."
	implements = list(
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/pen = 3.33,
	)
	time = 5 SECONDS
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED

	var/list/zombie_chems = list(/datum/reagent/toxin/zombiepowder, /datum/reagent/medicine/rezadone)

/datum/surgery_operation/limb/bionecrosis/get_default_radial_image()
	return get_dynamic_human_appearance(species_path = /datum/species/zombie)

/datum/surgery_operation/limb/bionecrosis/state_check(obj/item/bodypart/limb)
	if(!LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED|SURGERY_BONE_SAWED))
		return FALSE
	if(locate(/obj/item/organ/zombie_infection) in limb)
		return FALSE
	if(!(locate(/obj/item/organ/brain) in limb))
		return FALSE
	for(var/chem in zombie_chems)
		if(limb.owner.reagents?.get_reagent_amount(chem) > 1)
			return TRUE
	return FALSE

/datum/surgery_operation/limb/bionecrosis/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to grow a romerol tumor on [limb.owner]'s brain..."),
		span_notice("[surgeon] begins to tinker with [limb.owner]'s brain..."),
		span_notice("[surgeon] begins to perform surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head pounds with unimaginable pain!") // Same message as other brain surgeries

/datum/surgery_operation/limb/bionecrosis/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You succeed in growing a romerol tumor on [limb.owner]'s brain."),
		span_notice("[surgeon] successfully grows a romerol tumor on [limb.owner]'s brain!"),
		span_notice("[surgeon] completes the surgery on [limb.owner]'s brain."),
	)
	display_pain(limb.owner, "Your head goes totally numb for a moment, the pain is overwhelming!")
	if(locate(/obj/item/organ/zombie_infection) in limb) // they got another one mid surgery? whatever
		return
	var/obj/item/organ/zombie_infection/z_infection = new()
	z_infection.Insert(limb.owner)
