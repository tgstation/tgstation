/// Applied to an item: Causes the item to deal shock damage to a target and jump to other targets
/datum/element/chain_lightning_attack
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 2
	/// Damage dealt by the shock of the chain lightning
	var/shock_damage
	/// Range the shock will jump to another target
	var/shock_range
	/// Maximum number of jumps the chain lightning can make
	var/chain_limit

/datum/element/chain_lightning_attack/Attach(datum/target, shock_damage = 10, shock_range = 2, chain_limit = 3)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.shock_damage = shock_damage
	src.shock_range = shock_range
	src.chain_limit = chain_limit
	RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, PROC_REF(try_chain))

/datum/element/chain_lightning_attack/Detach(datum/source, ...)
	. = ..()
	UnregisterSignal(source, COMSIG_ITEM_AFTERATTACK)

/datum/element/chain_lightning_attack/proc/try_chain(obj/item/source, atom/hit, mob/user)
	SIGNAL_HANDLER

	if(!isliving(hit))
		return
	do_chain(source, hit, user, list(user))

/datum/element/chain_lightning_attack/proc/do_chain(obj/item/source, mob/living/next_target, atom/last_target, list/dont_hit = list())
	if(!next_target.electrocute_act(shock_damage, source, flags = SHOCK_NOGLOVES|SHOCK_NOSTUN))
		return
	if(last_target != next_target)
		last_target.Beam(next_target, icon_state = "lightning[rand(1, 12)]", time = 0.5 SECONDS)
	dont_hit += next_target
	if(length(dont_hit) >= chain_limit + 1)
		return

	for(var/mob/living/other_victim in view(next_target, shock_range))
		if(other_victim in dont_hit)
			continue
		do_chain(source, other_victim, next_target, dont_hit)
		break
