/datum/surgery_operation/limb/bionecrosis
	name = "induce bionecrosis"
	rnd_name = "Bionecroplasty (Necrotic Revival)"
	desc = "Inject reagents that stimulate the growth of a Romerol tumor inside the patient's brain."
	rnd_desc = "An experimental procedure which induces the growth of a Romerol tumor inside the patient's brain. \
		The patient must be dosed or the syringe must be loaded with Zombie Powder or Rezadone for it to take effect."
	implements = list(
		/obj/item/reagent_containers/syringe = 1,
		/obj/item/pen = 3.33,
	)
	time = 5 SECONDS
	operation_flags = OPERATION_MORBID | OPERATION_LOCKED

	var/list/zombie_chems = list(/datum/reagent/toxin/zombiepowder, /datum/reagent/medicine/rezadone)

/datum/surgery_operation/limb/bionecrosis/get_recommended_tool()
	. = ..()
	for(var/datum/reagent/chem as anything in zombie_chems)
		. += " / [chem::name]"

/datum/surgery_operation/limb/bionecrosis/get_default_radial_image()
	return get_dynamic_human_appearance(species_path = /datum/species/zombie)

/datum/surgery_operation/limb/bionecrosis/state_check(obj/item/bodypart/limb)
	if(!LIMB_HAS_SURGERY_STATE(limb, SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED|SURGERY_BONE_SAWED))
		return FALSE
	if(locate(/obj/item/organ/zombie_infection) in limb)
		return FALSE
	if(!(locate(/obj/item/organ/brain) in limb))
		return FALSE
	return FALSE

/datum/surgery_operation/limb/bionecrosis/snowflake_check_availability(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, body_zone)
	for(var/chem in zombie_chems)
		if(tool.reagents?.get_reagent_amount(chem) > 1)
			return TRUE
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
