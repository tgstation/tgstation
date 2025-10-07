/datum/surgery/advanced/necrotic_revival
	name = "Necrotic Revival"
	desc = "An experimental surgical procedure that stimulates the growth of a Romerol tumor inside the patient's brain. Requires zombie powder or rezadone."
	surgery_flags = SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/bionecrosis,
		/datum/surgery_step/close,
	)

/datum/surgery/advanced/necrotic_revival/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	var/obj/item/organ/zombie_infection/z_infection = target.get_organ_slot(ORGAN_SLOT_ZOMBIE)
	if(z_infection)
		return FALSE

/datum/surgery_step/bionecrosis
	name = "start bionecrosis (syringe)"
	implements = list(
		/obj/item/reagent_containers/syringe = 100,
		/obj/item/pen = 30)
	time = 5 SECONDS
	chems_needed = list(/datum/reagent/toxin/zombiepowder, /datum/reagent/medicine/rezadone)
	require_all_chems = FALSE

/datum/surgery_step/bionecrosis/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to grow a romerol tumor on [target]'s brain..."),
		span_notice("[user] begins to tinker with [target]'s brain..."),
		span_notice("[user] begins to perform surgery on [target]'s brain."),
	)
	display_pain(target, "Your head pounds with unimaginable pain!") // Same message as other brain surgeries

/datum/surgery_step/bionecrosis/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	display_results(
		user,
		target,
		span_notice("You succeed in growing a romerol tumor on [target]'s brain."),
		span_notice("[user] successfully grows a romerol tumor on [target]'s brain!"),
		span_notice("[user] completes the surgery on [target]'s brain."),
	)
	display_pain(target, "Your head goes totally numb for a moment, the pain is overwhelming!")
	if(!target.get_organ_slot(ORGAN_SLOT_ZOMBIE))
		var/obj/item/organ/zombie_infection/z_infection = new()
		z_infection.Insert(target)
	return ..()
