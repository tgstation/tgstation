/datum/action/cooldown/open_mob_commands
	name = "Command Star Gazer"
	desc = "Open the command menu for your star gazer."
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "stargazer_menu"
	check_flags = AB_CHECK_CONSCIOUS | AB_CHECK_INCAPACITATED | AB_CHECK_PHASED
	/// Weakref for storing our stargazer
	var/datum/weakref/our_mob

/datum/action/cooldown/open_mob_commands/Grant(mob/granted_to, mob/living/basic/heretic_summon/star_gazer/our_mob_input)
	. = ..()
	our_mob = WEAKREF(our_mob_input)

/datum/action/cooldown/open_mob_commands/Activate(atom/target)
	open_menu()
	return TRUE

/// Opens the pet command options menu for a mob.
/datum/action/cooldown/open_mob_commands/proc/open_menu()
	var/mob/living/basic/heretic_summon/star_gazer/our_mob_resolved = our_mob?.resolve()
	if(our_mob_resolved)
		var/datum/component/obeys_commands/command_component = our_mob_resolved.GetComponent(/datum/component/obeys_commands)
		if(command_component)
			command_component.display_menu(owner)
