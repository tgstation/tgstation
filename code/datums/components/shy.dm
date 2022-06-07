#define SHY_COMPONENT_CACHE_TIME 0.5 SECONDS

/// You can't use items on anyone other than yourself if there are other living mobs around you
/datum/component/shy
	can_transfer = TRUE
	/// How close you are before you get shy
	var/shy_range = 4
	/// Typecache of mob types you are okay around
	var/list/mob_whitelist
	/// Typecache of machines you can avoid being shy with
	var/list/machine_whitelist = null
	/// Message shown when you are is_shy
	var/message = "You find yourself too shy to do that around %TARGET!"
	/// Are you shy around bodies with no key?
	var/keyless_shy = FALSE
	/// Are you shy around bodies with no client?
	var/clientless_shy = TRUE
	/// Are you shy around a dead body?
	var/dead_shy = FALSE
	/// If dead_shy is false and this is true, you're only shy when right next to a dead target
	var/dead_shy_immediate = TRUE
	/// Invalidate last_result at this time
	COOLDOWN_DECLARE(result_cooldown)
	/// What was our last result?
	var/last_result = FALSE

/datum/component/shy/Initialize(mob_whitelist, shy_range, message, keyless_shy, clientless_shy, dead_shy, dead_shy_immediate, machine_whitelist)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	src.mob_whitelist = mob_whitelist
	if(shy_range)
		src.shy_range = shy_range
	if(message)
		src.message = message
	if(keyless_shy)
		src.keyless_shy = keyless_shy
	if(clientless_shy)
		src.clientless_shy = clientless_shy
	if(dead_shy)
		src.dead_shy = dead_shy
	if(dead_shy_immediate)
		src.dead_shy_immediate = dead_shy_immediate
	if(machine_whitelist)
		src.machine_whitelist = machine_whitelist

/datum/component/shy/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLICKON, .proc/on_clickon)
	RegisterSignal(parent, COMSIG_LIVING_TRY_PULL, .proc/on_try_pull)
	RegisterSignal(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_EARLY_UNARMED_ATTACK), .proc/on_unarmed_attack)
	RegisterSignal(parent, COMSIG_TRY_STRIP, .proc/on_try_strip)
	RegisterSignal(parent, COMSIG_TRY_ALT_ACTION, .proc/on_try_alt_action)

/datum/component/shy/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_MOB_CLICKON,
		COMSIG_LIVING_TRY_PULL,
		COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_EARLY_UNARMED_ATTACK,
		COMSIG_TRY_STRIP,
		COMSIG_TRY_ALT_ACTION,
	))

/datum/component/shy/PostTransfer()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/shy/InheritComponent(datum/component/shy/friend, i_am_original, list/arguments)
	if(i_am_original)
		shy_range = friend.shy_range
		mob_whitelist = friend.mob_whitelist
		message = friend.message

/// Returns TRUE or FALSE if you are within shy_range tiles from a /mob/living
/datum/component/shy/proc/is_shy(atom/target)
	var/result = FALSE
	var/mob/owner = parent

	if(target in owner.DirectAccess())
		return
	for(var/type in machine_whitelist)
		if(istype(target, type))
			return

	if(!COOLDOWN_FINISHED(src, result_cooldown))
		return last_result

	var/list/strangers = view(shy_range, get_turf(owner))

	if(length(strangers) && locate(/mob/living) in strangers)
		for(var/mob/living/person in strangers)
			if(person == owner)
				continue
			if(is_type_in_typecache(person, mob_whitelist))
				continue
			if(!person.key && !keyless_shy)
				continue
			if(!person.client && !clientless_shy)
				continue
			if(person.stat == DEAD && !dead_shy)
				if(!dead_shy_immediate)
					continue
				else if(!owner.Adjacent(person))
					continue
			to_chat(owner, span_warning("[replacetext(message, "%TARGET", person)]"))
			result = TRUE
			break

	last_result = result
	COOLDOWN_START(src, result_cooldown, SHY_COMPONENT_CACHE_TIME)
	return result



/datum/component/shy/proc/on_clickon(datum/source, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if(modifiers[SHIFT_CLICK]) //let them examine their surroundings.
		return
	return is_shy(target) && COMSIG_MOB_CANCEL_CLICKON

/datum/component/shy/proc/on_try_pull(datum/source, atom/movable/target, force)
	SIGNAL_HANDLER
	return is_shy(target) && COMSIG_LIVING_CANCEL_PULL

/datum/component/shy/proc/on_unarmed_attack(datum/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	return is_shy(target) && COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/shy/proc/on_try_strip(datum/source, atom/target, obj/item/equipping)
	SIGNAL_HANDLER
	return is_shy(target) && COMPONENT_CANT_STRIP

/datum/component/shy/proc/on_try_alt_action(datum/source, atom/target)
	SIGNAL_HANDLER
	return is_shy(target) && COMPONENT_CANT_ALT_ACTION

#undef SHY_COMPONENT_CACHE_TIME

