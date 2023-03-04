/datum/traitor_objective_category/sleeper_protocol
	name = "Sleeper Protocol"
	objectives = list(
		/datum/traitor_objective/sleeper_protocol = 1,
		/datum/traitor_objective/sleeper_protocol/everybody = 1,
	)

/datum/traitor_objective/sleeper_protocol
	name = "Perform the sleeper protocol on a crewmember"
	description = "Use the button below to materialize a surgery disk in your hand, where you'll then be able to perform the sleeper protocol on a crewmember. If the disk gets destroyed, the objective will fail. This will only work on living and sentient crewmembers."

	progression_minimum = 0 MINUTES

	progression_reward = list(8 MINUTES, 15 MINUTES)
	telecrystal_reward = 1

	var/list/limited_to = list(
		JOB_CHIEF_MEDICAL_OFFICER,
		JOB_MEDICAL_DOCTOR,
		JOB_PARAMEDIC,
		JOB_VIROLOGIST,
		JOB_ROBOTICIST,
	)

	var/obj/item/disk/surgery/sleeper_protocol/disk

	var/mob/living/current_registered_mob

	var/inverted_limitation = FALSE

/datum/traitor_objective/sleeper_protocol/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!disk)
		buttons += add_ui_button("", "Clicking this will materialize the sleeper protocol surgery in your hand", "save", "summon_disk")
	return buttons

/datum/traitor_objective/sleeper_protocol/ui_perform_action(mob/living/user, action)
	switch(action)
		if("summon_disk")
			if(disk)
				return
			disk = new(user.drop_location())
			user.put_in_hands(disk)
			AddComponent(/datum/component/traitor_objective_register, disk, \
				fail_signals = list(COMSIG_PARENT_QDELETING))

/datum/traitor_objective/sleeper_protocol/proc/on_surgery_success(datum/source, datum/surgery_step/step, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	SIGNAL_HANDLER
	if(istype(step, /datum/surgery_step/brainwash/sleeper_agent))
		succeed_objective()

/datum/traitor_objective/sleeper_protocol/can_generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/datum/job/job = generating_for.assigned_role
	if(!(job.title in limited_to) && !inverted_limitation)
		return FALSE
	if((job.title in limited_to) && inverted_limitation)
		return FALSE
	if(length(possible_duplicates) > 0)
		return FALSE
	return TRUE

/datum/traitor_objective/sleeper_protocol/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	AddComponent(/datum/component/traitor_objective_mind_tracker, generating_for, \
		signals = list(COMSIG_MOB_SURGERY_STEP_SUCCESS = PROC_REF(on_surgery_success)))
	return TRUE

/datum/traitor_objective/sleeper_protocol/ungenerate_objective()
	disk = null
/obj/item/disk/surgery/sleeper_protocol
	name = "Suspicious Surgery Disk"
	desc = "The disk provides instructions on how to turn someone into a sleeper agent for the Syndicate."
	surgeries = list(/datum/surgery/advanced/brainwashing_sleeper)

/datum/surgery/advanced/brainwashing_sleeper
	name = "Sleeper Agent Surgery"
	desc = "A surgical procedure which implants the sleeper protocol into the patient's brain, making it their absolute priority. It can be cleared using a mindshield implant."
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/brainwash/sleeper_agent,
		/datum/surgery_step/close,
	)

/datum/surgery/advanced/brainwashing_sleeper/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/internal/brain/target_brain = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		return FALSE
	return TRUE

/datum/surgery_step/brainwash/sleeper_agent
	time = 25 SECONDS
	var/static/list/possible_objectives = list(
		"You love the Syndicate.",
		"Do not trust Nanotrasen.",
		"The Captain is a lizardperson.",
		"Nanotrasen isn't real.",
		"They put something in the food to make you forget.",
		"You are the only real person on the station."
	)

/datum/surgery_step/brainwash/sleeper_agent/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	objective = pick(possible_objectives)
	display_results(
		user,
		target,
		span_notice("You begin to brainwash [target]..."),
		span_notice("[user] begins to fix [target]'s brain."),
		span_notice("[user] begins to perform surgery on [target]'s brain."),
	)
	display_pain(target, "Your head pounds with unimaginable pain!") // Same message as other brain surgeries

/datum/surgery_step/brainwash/sleeper_agent/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(target.stat == DEAD)
		to_chat(user, span_warning("They need to be alive to perform this surgery!"))
		return FALSE
	. = ..()
	if(!.)
		return
	target.gain_trauma(new /datum/brain_trauma/mild/phobia/conspiracies(), TRAUMA_RESILIENCE_LOBOTOMY)

/datum/traitor_objective/sleeper_protocol/everybody //Much harder for non-med and non-robo
	progression_minimum = 30 MINUTES
	progression_reward = list(8 MINUTES, 15 MINUTES)
	telecrystal_reward = 1

	inverted_limitation = TRUE
