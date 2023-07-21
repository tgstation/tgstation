/datum/action/innate/clockcult/teleport_to_servant
	name = "Teleport to Servant"
	desc = "Teleport yourself to a fellow servant."
	button_icon_state = "clockwork_armor"

/datum/action/innate/clockcult/teleport_to_servant/Activate(mob/living/user = usr)
	var/datum/antagonist/clock_cultist/servant = user.mind.has_antag_datum(/datum/antagonist/clock_cultist)
	if(!servant?.clock_team)
		return

	var/list/given_list = list()
	for(var/datum/mind/servant_mind in servant.clock_team.members)
		given_list += servant_mind.current
	given_list -= usr
	if(!given_list.len)
		return

	var/mob/living/input_servant = tgui_input_list(usr, "Choosen a servant", "Servants", given_list)
	do_teleport(usr, get_turf(input_servant), 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
	usr.playsound_local(get_turf(usr), 'sound/magic/magic_missile.ogg', 50, TRUE, pressure_affected = FALSE)
	to_chat(usr, "You warp to [input_servant].")
