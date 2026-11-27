// Turn a ghost into a human
/mob/dead/observer/CtrlShiftClickOn(atom/target)
	if(isobserver(target) && check_rights(R_SPAWN, FALSE))
		var/mob/dead/observer/target_ghost = target
		target_ghost.change_mob_type(/mob/living/carbon/human , null, null, TRUE) //always delmob, ghosts shouldn't be left lingering

// Open "View Variables" menu for target
/mob/dead/observer/proc/CtrlAltClickOn(atom/target)
	if(check_rights(R_DEBUG, FALSE))
		SSadmin_verbs.dynamic_invoke_verb(client, /datum/admin_verb/debug_variables, target)

// Open "Show Player Panel" menu for target mob
/mob/dead/observer/CtrlClickOn(atom/target)
	if(check_rights(R_ADMIN) && ismob(target))
		SSadmin_verbs.dynamic_invoke_verb(client, /datum/admin_verb/show_player_panel, target)
