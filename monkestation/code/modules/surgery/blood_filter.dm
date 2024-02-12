/datum/surgery/blood_filter
	replaced_by = /datum/surgery/blood_filter/upgraded
	/// Path to the filtering step to replace the usual `/datum/surgery_step/filter_blood` with.
	var/filtering_step_type

/datum/surgery/blood_filter/New(atom/surgery_target, surgery_location, surgery_bodypart)
	..()
	if(filtering_step_type)
		steps = list(
			/datum/surgery_step/incise,
			/datum/surgery_step/retract_skin,
			/datum/surgery_step/incise,
			filtering_step_type,
			/datum/surgery_step/close,
		)

/datum/surgery_step/filter_blood
	/// The factor by which to purge the volume of reagents in the patient's blood.
	var/chem_purge_factor = 0.2
	/// The factor by which to heal the patient's toxin damage.
	var/tox_heal_factor = 0

/datum/surgery_step/filter_blood/initiate(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, try_to_fail = FALSE)
	if(!..())
		return
	while(has_filterable_chems(target, tool) || (tox_heal_factor && target.getToxLoss() > 0))
		if(!..())
			break

/datum/surgery_step/filter_blood/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/obj/item/blood_filter/bloodfilter = tool
	if(target.reagents?.total_volume)
		for(var/datum/reagent/chem as anything in target.reagents.reagent_list)
			if(!length(bloodfilter.whitelist) || (chem.type in bloodfilter.whitelist))
				var/purge_amt = (chem.volume <= 2) ? chem.volume : min(chem.volume * chem_purge_factor, 10)
				target.reagents.remove_reagent(chem.type, purge_amt)
	var/tox_loss = target.getToxLoss()
	if(tox_heal_factor > 0)
		if(tox_loss <= 2)
			target.setToxLoss(0, forced = TRUE)
		else
			target.adjustToxLoss(-(tox_loss * tox_heal_factor), forced = TRUE) //forced so this will actually heal oozelings too
	var/list/remaining = list()
	if(locate(/obj/item/healthanalyzer) in user.held_items)
		if(tox_heal_factor > 0 && tox_loss > 0)
			remaining += "<font color='[COLOR_GREEN]'>[round(tox_loss, 0.1)]</font> toxin"
		if(target.reagents?.total_volume)
			remaining += "<font color='[COLOR_MAGENTA]'>[round(target.reagents.total_volume, 0.1)]u</font> of reagents"
	var/umsg = length(remaining) ? " [english_list(remaining)] remaining." : ""
	display_results(
		user,
		target,
		span_notice("[tool] pings as it finishes filtering [target]'s blood.[umsg]"),
		span_notice("[tool] pings as it stops pumping [target]'s blood."),
		span_notice("[tool] pings as it stops pumping."),
	)

	return ..()

/datum/surgery/blood_filter/upgraded
	name = "Filter Blood (Adv.)"
	desc = "A surgical procedure that provides advanced toxin filtering to remove reagents from the patient's blood, in addition to undoing any damage the toxins done to the patient's system. Heals considerably more when the patient is severely injured."
	requires_tech = TRUE
	filtering_step_type = /datum/surgery_step/filter_blood/upgraded
	replaced_by = /datum/surgery/blood_filter/femto

/datum/surgery_step/filter_blood/upgraded
	time = 1.85 SECONDS
	tox_heal_factor = 0.075

/datum/surgery/blood_filter/femto
	name = "Filter Blood (Exp.)"
	desc = "A surgical procedure that provides experimental toxin filtering to remove reagents from the patient's blood, in addition to undoing any damage the toxins done to the patient's system. Heals considerably more when the patient is severely injured."
	requires_tech = TRUE
	filtering_step_type = /datum/surgery_step/filter_blood/upgraded/femto
	replaced_by = null

/datum/surgery_step/filter_blood/upgraded/femto
	time = 1 SECONDS
