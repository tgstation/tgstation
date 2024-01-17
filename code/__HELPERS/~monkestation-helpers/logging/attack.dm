// Redeclares `log_bomber`, originally in `code/__HELPERS/logging/attack.dm` (now commented out
// there), to be a redirect to the new targetted variant.
/proc/log_bomber(atom/user, details, atom/bomb, additional_details, message_admins = TRUE)
	// We pass in `null` for the target, which makes it work as before.
	log_bomber_targeted(user, details, bomb, null, additional_details, message_admins)

// Like `/proc/log_bomber`, but with a target specified. This also marks pacifist characters as
// pacifist, so we can see if they're bypassing the trait when they shouldn't.
/proc/log_bomber_targeted(atom/user, details, atom/bomb, atom/target, additional_details, message_admins = TRUE)
	var/bomb_message = "[details][bomb ? " [bomb.name] at [AREACOORD(bomb)]": ""][target ? " on [target.name] at [AREACOORD(target)]" : ""][additional_details ? " [additional_details]" : ""]."

	if(user)
		if(HAS_TRAIT(user, TRAIT_PACIFISM))
			bomb_message = "(while pacifist) [bomb_message]"
		user.log_message(bomb_message, LOG_ATTACK) //let it go to individual logs as well as the game log
		bomb_message = "[key_name(user)] at [AREACOORD(user)] [bomb_message]."
	else
		log_attack(bomb_message)

	GLOB.bombers += bomb_message

	if(message_admins)
		message_admins("[user ? "[ADMIN_LOOKUPFLW(user)][HAS_TRAIT(user, TRAIT_PACIFISM) ? " (pacifist)" : ""] at [ADMIN_VERBOSEJMP(user)] " : ""][details][bomb ? " [bomb.name] at [ADMIN_VERBOSEJMP(bomb)]": ""][target ? " on [target.name] at [ADMIN_VERBOSEJMP(target)]" : ""][additional_details ? " [additional_details]" : ""].")
