/datum/traitor_objective/sleeper_protocol
	name = "Perform the sleeper protocol on a crewmember"
	description = "Use the button below to materialize a surgery disk in your hand, where you'll then be able to perform the sleeper protocol on a crewmember. If the disk gets destroyed, the objective will fail. This will only work on living and sentient crewmembers."

	progression_reward = list(8 MINUTES, 15 MINUTES)
	telecrystal_reward = 0

	var/list/limited_to = list(
		"Chief Medical Officer",
		"Medical Doctor",
		"Paramedic",
		"Virologist",
	)

	var/obj/item/disk/surgery/sleeper_protocol/disk

/datum/traitor_objective/sleeper_protocol/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!disk)
		buttons += add_ui_button("", "Clicking this will materialize the sleeper protocol surgery in your hand", "save", "summon_disk")

/datum/traitor_objective/sleeper_protocol/ui_perform_action(mob/living/user, action)
	switch(action)
		if("summon_disk")
			disk = new(user.drop_location())
			user.put_in_hand(disk)


/datum/traitor_objective/sleeper_protocol/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/datum/job/job = generating_for.assigned_role
	if(!(job.title in limited_to))
		return FALSE
	return TRUE

/datum/traitor_objective/sleeper_protocol/is_duplicate()
	return TRUE

/obj/item/disk/surgery/sleeper_protocol
	name = "Suspicious Surgery Disk"
	desc = "The disk provides instructions on how to turn someone into a sleeper agent for the Syndicate"
	surgeries = list(/datum/surgery/advanced/brainwashing)

/datum/surgery/advanced/brainwashing_sleeper
	name = "Brainwashing"
	desc = "A surgical procedure which implants the sleeper protocol into the patient's brain, making it their absolute priority. It can be cleared using a mindshield implant."
	steps = list(
	/datum/surgery_step/incise,
	/datum/surgery_step/retract_skin,
	/datum/surgery_step/saw,
	/datum/surgery_step/clamp_bleeders,
	/datum/surgery_step/brainwash/sleeper_agent,
	/datum/surgery_step/close)

	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_HEAD)

/datum/surgery/advanced/brainwashing/can_start(mob/user, mob/living/carbon/target)
	if(!..())
		return FALSE
	var/obj/item/organ/brain/target_brain = target.getorganslot(ORGAN_SLOT_BRAIN)
	if(!target_brain)
		return FALSE
	return TRUE

/datum/surgery_step/brainwash/sleeper_agent
	time = 25 SECONDS
	var/list/possible_objectives = list(
		"You love the Syndicate",
		"Do not trust Nanotrasen",
		"The Captain is a lizardperson",
		"Nanotrasen isn't real",
		"They put things in the food to make you forget",
		"You are the only real person on the station"
	)

/datum/surgery_step/brainwash/sleeper_agent/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	objective = pick(possible_objectives)
	display_results(user, target, span_notice("You begin to brainwash [target]..."),
		span_notice("[user] begins to fix [target]'s brain."),
		span_notice("[user] begins to perform surgery on [target]'s brain."))
	display_pain(target, "Your head pounds with unimaginable pain!") // Same message as other brain surgeries

/datum/surgery_step/brainwash/sleeper_agent/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	. = ..()
	if(!.)
		return
	target.gain_trauma(new /datum/brain_trauma/mild/phobia/conspiracies(), TRAUMA_RESILIENCE_LOBOTOMY)
