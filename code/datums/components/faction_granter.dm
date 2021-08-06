#define DEFAULT_GRANT_MESSAGE "You have become friends with "

/**
 * ## faction granter component!
 *
 * component attached to items to allow them to be used
 */
/datum/component/faction_granter
	///whichever faction the parent adds upon using in hand
	var/faction_to_grant
	///whether you need to be holy to get the faction.
	var/holy_role_required
	///message given when granting the faction.
	var/grant_message
	///boolean on whether it has been used
	var/used = FALSE

/datum/component/faction_granter/Initialize(faction_to_grant, holy_role_required = FALSE, grant_message = "You have become friends with ")
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.faction_to_grant = faction_to_grant
	src.holy_role_required = holy_role_required
	src.grant_message = grant_message

/datum/component/faction_granter/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, .proc/on_self_attack)
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)

/datum/component/faction_granter/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_PARENT_EXAMINE))

///signal called on parent being examined
/datum/component/faction_granter/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(used)
		examine_list += span_notice("[parent]'s faction granting power has been used up.")
	else
		examine_list += span_notice("Using [parent] in your hand will grant you favor with a faction.")

///signal called on parent being interacted with in hand
/datum/component/faction_granter/proc/on_self_attack(atom/source, mob/user)
	SIGNAL_HANDLER
	if(used)
		to_chat(user, span_warning("The power of [parent] has been used up!"))
		return
	if(holy_role_required && user.mind?.holy_role >= HOLY_ROLE_PRIEST)
		to_chat(user, span_warning("You are not holy enough to invoke the power of [parent]!"))
		return
	if(grant_message == DEFAULT_GRANT_MESSAGE)
		grant_message += faction_to_grant

	to_chat(user, grant_message)
	user.faction |= faction_to_grant
	used = TRUE
