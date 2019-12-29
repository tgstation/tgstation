/// You can't use items on anyone other than yourself if there are other living mobs around you
/datum/component/shy
	can_transfer = TRUE
	var/shy_range = 4 //! Range of your bashfullness
	var/list/whitelist //! Typecache of mob types you are okay around
	var/message = "You find yourself too shy to do that around %TARGET!" //! Message shown when you are bashful
	var/dead_shy = FALSE //! Are you shy around a dead body?

/// _shy_range, _whitelist, _message map to vars
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
	RegisterSignal(parent, COMSIG_MOB_CLICKON, .proc/bashful)

/datum/component/shy/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOB_CLICKON)

/datum/component/shy/PostTransfer()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

/datum/component/shy/InheritComponent(datum/component/shy/friend, i_am_original, list/arguments)
	if(i_am_original)
		shy_range = friend.shy_range
		whitelist = friend.whitelist
		message = friend.message

/datum/component/shy/proc/bashful(datum/source, atom/A, params)
	var/mob/owner = parent
	var/list/strangers = view(shy_range, get_turf(owner))
	if(!length(strangers) || !(locate(/mob/living) in strangers) || (A in owner.DirectAccess()))
		return

	for(var/mob/living/person in strangers)
		if(!is_type_in_typecache(person, whitelist) && (person.stat != DEAD || dead_shy))
			to_chat(owner, "<span class='warning'>[replacetext(message, "%TARGET", person)]</span>")
			return COMSIG_MOB_CANCEL_CLICKON
