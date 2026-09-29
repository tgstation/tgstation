/**
 * Tool flash bespoke element
 *
 * Flashes the user (and nearby mobs) when using this tool
 */
/datum/element/tool_flash
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Strength of the flash
	var/flash_strength

/datum/element/tool_flash/Attach(datum/target, flash_strength)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.flash_strength = flash_strength

	RegisterSignal(target, COMSIG_TOOL_IN_USE, PROC_REF(prob_flash))
	RegisterSignal(target, COMSIG_TOOL_START_USE, PROC_REF(flash))

/datum/element/tool_flash/Detach(datum/source)
	. = ..()
	UnregisterSignal(source, list(COMSIG_TOOL_IN_USE, COMSIG_TOOL_START_USE))

/datum/element/tool_flash/proc/prob_flash(datum/source, mob/living/user)
	SIGNAL_HANDLER

	if(prob(90))
		return

	flash(source, user)

/datum/element/tool_flash/proc/flash(datum/source, mob/living/user)
	SIGNAL_HANDLER

	if(flash_strength <= 0)
		return

	for(var/mob/living/victim in view(1, user))
		victim.flash_act(max(flash_strength, 1))
