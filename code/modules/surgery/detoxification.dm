/datum/surgery/detox
	name = "Detoxification"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/detox,
				/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = TRUE
	replaced_by = /datum/surgery
	ignore_clothes = FALSE

/datum/surgery/detox/can_start(mob/user, mob/living/carbon/target)
	var/obj/item/organ/stomach/S = target.getorganslot(ORGAN_SLOT_STOMACH)
	if(!S)
		return FALSE
	return TRUE

//an incision but with greater bleed, and a 90% base success chance
/datum/surgery_step/detox
	name = "Pump Stomach"
	accept_hand = TRUE
	repeatable = TRUE
	time = 20

/datum/surgery_step/detox/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin pumping [target]'s stomach...</span>",
		"<span class='notice'>[user] begins to pump [target]'s stomach.</span>",
		"<span class='notice'>[user] begins to pump [target]'s stomach.</span>")

/datum/surgery_step/detox/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		display_results(user, target, "<span class='notice'>[user] forces [H] to vomit, cleansing their stomach of chemicals!</span>",
				"<span class='notice'>[user] forces [H] to vomit, cleansing their stomach of chemicals!</span>",
				"")
		H.vomit(20, FALSE, TRUE, 1, TRUE, FALSE, purge = TRUE) //called with purge as true to lose more reagents
	return ..()

/datum/surgery_step/detox/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		display_results(user, target, "<span class='warning'>You screw up, brusing [H]'s chest!</span>",
			"<span class='warning'>[user] screws up, brusing [H]'s chest!</span>",
			"<span class='warning'>[user] screws up, brusing [H]'s chest!</span>")
		H.adjustOrganLoss(ORGAN_SLOT_STOMACH, 5)
		H.adjustBruteLoss(5)
