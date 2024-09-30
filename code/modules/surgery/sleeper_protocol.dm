/obj/item/disk/surgery/sleeper_protocol
	name = "Suspicious Surgery Disk"
	desc = "The disk provides instructions on how to turn someone into a sleeper agent for the Syndicate."
	surgeries = list(
		/datum/surgery/advanced/brainwashing_sleeper,
		/datum/surgery/advanced/brainwashing_sleeper/mechanic,
		)

/datum/surgery/advanced/brainwashing_sleeper
	name = "Sleeper Agent Surgery"
	desc = "A surgical procedure which implants the sleeper protocol into the patient's brain, making it their absolute priority. It can be cleared using a mindshield implant."
	requires_bodypart_type = NONE
	possible_locs = list(BODY_ZONE_HEAD)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/saw,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/brainwash/sleeper_agent,
		/datum/surgery_step/close,
	)

/datum/surgery/advanced/brainwashing_sleeper/mechanic
	name = "Sleeper Agent Reprogramming"
	desc = "Malware which directly implants the sleeper protocol directive into the robotic patient's operating system, making it their absolute priority. It can be cleared using a mindshield implant."
	requires_bodypart_type = BODYTYPE_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/brainwash/sleeper_agent/mechanic,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close,
	)

/datum/surgery/advanced/brainwashing_sleeper/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/internal/brain/target_brain = target.get_organ_slot(ORGAN_SLOT_BRAIN)
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
		"You are the only real person on the station.",
		"Things would be a lot better on the station if more people were screaming, someone should do something about that.",
		"The people in charge around here have only ill intentions for the crew.",
		"Help the crew? What have they ever done for you anyways?",
		"Does your bag feel lighter? I bet those guys in Security stole something from it. Go get it back.",
		"Command is incompetent, someone with some REAL authority should take over around here.",
		"The cyborgs and the AI are stalking you. What are they planning?",
	)

/datum/surgery_step/brainwash/sleeper_agent/mechanic
	name = "reprogram (multitool)"
	implements = list(
		TOOL_MULTITOOL = 85,
		TOOL_HEMOSTAT = 50,
		TOOL_WIRECUTTER = 50,
		/obj/item/stack/package_wrap = 35,
		/obj/item/stack/cable_coil = 15)
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	success_sound = 'sound/items/handling/surgery/hemostat1.ogg'

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
