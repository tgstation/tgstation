/*
	Temporarily takes over a body, and then returns the mind to the old body on death
*/

/datum/component/mindcontroller
	// original mob stored
	var/mob/original

/datum/component/mindcontroller/Initialize(mob/original, list/new_mob_factions = list())
	if(!original || !ismob(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/return_to_original)
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, .proc/preattack_intercept)
	RegisterSignal(parent, COMSIG_HOSTILE_ATTACKINGTARGET, .proc/hostile_attackingtarget)
	var/mob/controlledmob = parent
	src.original = original
	// transfer original player to new body, change key so they don't retain the same abilities
	controlledmob.key = original.key
	controlledmob.faction = new_mob_factions

/*
	Returns the mob to the original mob
*/
/datum/component/mindcontroller/proc/return_to_original(mob/controlledmob = parent)
	if(!original)
		controlledmob.ghostize()
	else
		original.key = controlledmob.key

/*
	Interrupts the controlled mob from attacking anything in its faction with an item
*/
/datum/component/mindcontroller/proc/preattack_intercept(obj/item/attackingitem, atom/target, mob/user, params)
	if(isliving(target))
		var/mob/living/L = target
		var/list/shared_factions = L.faction & user.faction
		if(shared_factions.len)
			return COMPONENT_NO_ATTACK

/*
	Interrupts the controlled mob from attacking anything in its faction with its fists
*/
/datum/component/mindcontroller/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target)
	if(isliving(target))
		var/mob/living/L = target
		var/list/shared_factions = L.faction & attacker.faction
		if(shared_factions.len)
			return COMPONENT_HOSTILE_NO_ATTACK