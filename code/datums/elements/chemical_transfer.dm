//the default chemical transfer messages if they aren't set
#define DEFAULT_ATTACKER_MESSAGE span_notice("You transfer your chemicals to %VICTIM.")
#define DEFAULT_VICTIM_MESSAGE span_userdanger("Chemicals have been transferred into you from %ATTACKER!")

/**
 * ## chemical transfer element!
 *
 * Bespoke element that, on a certain chance to proc, transfers all chemicals from the person attacking to the victim being attacked
 * with whatever item has this element.
 *
 * attacker_message uses %VICTIM as whomever is getting attacked.
 * victim_message uses %ATTACKER for the same.
 */
/datum/element/chemical_transfer
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///chance for the chemical transfer to proc.
	var/transfer_prob
	///message attacker gets when the chemical transfer procs
	var/attacker_message
	///message victim gets when the chemical transfer procs
	var/victim_message

/datum/element/chemical_transfer/Attach(datum/target, attacker_message = DEFAULT_ATTACKER_MESSAGE, victim_message = DEFAULT_VICTIM_MESSAGE, transfer_prob = 100)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	src.transfer_prob = transfer_prob
	src.attacker_message = attacker_message
	src.victim_message = victim_message
	RegisterSignal(target, COMSIG_ITEM_ATTACK, .proc/on_attack)
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/element/chemical_transfer/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_ATTACK, COMSIG_PARENT_EXAMINE))

///signal called on parent being examined
/datum/element/chemical_transfer/proc/on_examine(datum/target, mob/user, list/examine_list)
	SIGNAL_HANDLER
	var/probability_description
	switch(transfer_prob)
		if(1 to 25)
			probability_description = "rarely"
		if(26 to 66)
			probability_description = "sometimes"
		if(67 to 99)
			probability_description = "often"
		if(100)
			probability_description = "always"
	examine_list += span_notice("Attacking with [target] will [probability_description] transfer reagents inside of you to your victim.")

///signal called on parent being used to attack a victim
/datum/element/chemical_transfer/proc/on_attack(datum/target, mob/living/transfer_victim, mob/living/transfer_attacker)
	SIGNAL_HANDLER

	if(!istype(transfer_attacker) || !prob(transfer_prob))
		return
	var/built_attacker_message = replacetext(attacker_message, "%VICTIM", transfer_victim)
	var/built_victim_message = replacetext(attacker_message, "%ATTACKER", transfer_attacker)
	transfer_attacker.reagents?.trans_to(transfer_victim, transfer_attacker.reagents.total_volume, multiplier = 1, preserve_data = 1, no_react = 0, transfered_by = transfer_attacker)
	to_chat(transfer_attacker, built_attacker_message)
	to_chat(transfer_victim, built_victim_message)

#undef DEFAULT_ATTACKER_MESSAGE
#undef DEFAULT_VICTIM_MESSAGE
