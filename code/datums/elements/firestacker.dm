/**
 * Can be applied to /atom/movable subtypes to make them apply fire stacks to things they hit
 */
/datum/element/firestacker
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// How many firestacks to apply per hit
	var/amount

/datum/element/firestacker/Attach(datum/target, amount)
	. = ..()

	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	src.amount = amount

	register_signal(target, COMSIG_MOVABLE_IMPACT, .proc/impact, override = TRUE)
	if(isitem(target))
		register_signal(target, COMSIG_ITEM_ATTACK, .proc/item_attack, override = TRUE)
		register_signal(target, COMSIG_ITEM_ATTACK_SELF, .proc/item_attack_self, override = TRUE)

/datum/element/firestacker/Detach(datum/source)
	. = ..()
	unregister_signal(source, list(COMSIG_MOVABLE_IMPACT, COMSIG_ITEM_ATTACK, COMSIG_ITEM_ATTACK_SELF))

/datum/element/firestacker/proc/stack_on(datum/owner, mob/living/target)
	target.adjust_fire_stacks(amount)

/datum/element/firestacker/proc/impact(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	if(isliving(hit_atom))
		stack_on(source, hit_atom)

/datum/element/firestacker/proc/item_attack(datum/source, atom/movable/target, mob/living/user)
	SIGNAL_HANDLER

	if(isliving(target))
		stack_on(source, target)

/datum/element/firestacker/proc/item_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER

	if(isliving(user))
		stack_on(source, user)
