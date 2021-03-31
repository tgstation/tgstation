#define SHY_COMPONENT_CACHE_TIME 5 //deciseconds

/// You can't use items on anyone other than yourself if there are other living mobs around you
/datum/component/shy
	can_transfer = TRUE
	/// Range of your bashfullness
	var/shy_range = 4
	/// Typecache of mob types you are okay around
	var/list/whitelist
	/// Message shown when you are bashful
	var/message = "You find yourself too shy to do that around %TARGET!"
	/// Are you shy around a dead body?
	var/dead_shy = FALSE
	/// Invalidate last_result at this time
	var/result_expires = 0
	/// What was our last result?
	var/last_result = FALSE

/// _shy_range, _whitelist, _message, dead_shy map to vars
/datum/component/shy/Initialize(_whitelist, _shy_range, _message, _dead_shy)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	whitelist = _whitelist
	if(_shy_range)
		shy_range = _shy_range
	if(_message)
		message = _message
	if(_dead_shy)
		dead_shy = _dead_shy

/datum/component/shy/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_CLICKON, .proc/bashful_click)
	RegisterSignal(parent, COMSIG_LIVING_TRY_PULL, .proc/bashful_pull)
	RegisterSignal(parent, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_EARLY_UNARMED_ATTACK), .proc/bashful_unarmed)

/datum/component/shy/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_CLICKON, COMSIG_LIVING_TRY_PULL, COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HUMAN_EARLY_UNARMED_ATTACK))

/datum/component/shy/PostTransfer()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/shy/InheritComponent(datum/component/shy/friend, i_am_original, list/arguments)
	if(i_am_original)
		shy_range = friend.shy_range
		whitelist = friend.whitelist
		message = friend.message

/// Returns TRUE or FALSE if you are within shy_range tiles from a /mob/living
/datum/component/shy/proc/bashful(atom/A)
	var/result = FALSE
	var/mob/owner = parent

	if(A in owner.DirectAccess())
		return

	if(result_expires > world.time)
		return last_result

	var/list/strangers = view(shy_range, get_turf(owner))

	if(length(strangers) && locate(/mob/living) in strangers)
		for(var/mob/living/person in strangers)
			if(person != owner && !is_type_in_typecache(person, whitelist) && (person.stat != DEAD || dead_shy))
				to_chat(owner, "<span class='warning'>[replacetext(message, "%TARGET", person)]</span>")
				result = TRUE
				break

	last_result = result
	result_expires = world.time + SHY_COMPONENT_CACHE_TIME
	return result



/datum/component/shy/proc/bashful_click(datum/source, atom/A, params)
	return bashful(A) && COMSIG_MOB_CANCEL_CLICKON

/datum/component/shy/proc/bashful_pull(datum/source, atom/movable/AM, force)
	return bashful(AM) && COMSIG_LIVING_CANCEL_PULL

/datum/component/shy/proc/bashful_unarmed(datum/source, atom/target, proximity, modifiers)
	return bashful(target) && COMPONENT_CANCEL_ATTACK_CHAIN

#undef SHY_COMPONENT_CACHE_TIME

