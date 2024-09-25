/datum/component/obeys_commands/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examine_more))

/datum/component/obeys_commands/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE_MORE)

/datum/component/obeys_commands/on_examine(mob/living/source, mob/user, list/examine_list)
	. = ..()
	examine_list += span_italics("You can alt+click [source.p_them()] when adjacent to see available commands.")
	examine_list += span_italics("You can also examine [source.p_them()] closely to check on [source.p_their()] wounds. Many companions can be healed with sutures or creams!")

/datum/component/obeys_commands/proc/on_examine_more(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	if (IS_DEAD_OR_INCAP(source))
		return
	if (!(user in source.ai_controller?.blackboard[BB_FRIENDS_LIST]))
		return

	if (source.health < source.maxHealth*0.2)
		examine_list += span_bolddanger("[source.p_They()] look[source.p_s()] severely injured.")
	else if (source.health < source.maxHealth*0.5)
		examine_list += span_danger("[source.p_They()] look[source.p_s()] moderately injured.")
	else if (source.health < source.maxHealth*0.8)
		examine_list += span_warning("[source.p_They()] look[source.p_s()] slightly injured.")
	else
		examine_list += span_notice("[source.p_They()] look[source.p_s()] to be in good condition.")
