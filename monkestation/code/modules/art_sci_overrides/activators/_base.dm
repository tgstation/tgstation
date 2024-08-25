/datum/artifact_activator
	/// Name given to activator
	var/name = "Generic Activator"
	///bitflag list of needed stimuli
	var/required_stimuli = NONE
	/// our baseline amount needed to even think about triggering (do this in setup otherwise its gonna be static)
	var/base_trigger_amount = 0
	///the highest number our trigger can be
	var/highest_trigger_amount = 0
	///the end goal of the amount we need set by setup below
	var/amount = 0
	///the hint we want to pass into the componenet for when we hit hint triggers
	var/list/hint_texts = list("Emits a <i>faint</i> noise..")
	///what it says on inspect when discovered
	var/discovered_text = "Activated by ... coderbus"
	///Research value when discovered
	var/research_value = 0

/datum/artifact_activator/proc/setup(potency)
	amount = round(max(base_trigger_amount, base_trigger_amount + (highest_trigger_amount - base_trigger_amount) * (potency/100)))

/datum/artifact_activator/proc/grab_hint()
	return pick(hint_texts)
