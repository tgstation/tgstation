//contains linked abscond, teleport to servant, and the eminence self teleports to reebe and the station
/datum/action/cooldown/eminence/linked_abscond
	name = "Linked Abscond"
	desc = "Absconds a fellow servant and whomever they may be pulling back to reebe if they stand still for 7 seconds."
	button_icon_state = "Linked Abscond"
	cooldown_time = 5 MINUTES

/datum/action/cooldown/eminence/linked_abscond/Activate(atom/target)
	var/mob/living/eminence/em_user = usr
	if(!istype(em_user))
		to_chat(usr, span_boldwarning("You are not an eminence and should not have this! Please report this as a bug."))
		return FALSE

	if(!em_user.marked_servant)
		to_chat(em_user, span_notice("You dont currently have a marked servant!"))
		return FALSE

	var/mob/living/teleported = em_user.marked_servant?.resolve()
	to_chat(em_user, span_brass("You begin to recall [teleported]."))
	to_chat(teleported, span_bigbrass("You are being recalled by the eminence."))
	teleported.visible_message(span_warning("[teleported] flares briefly."))

	if(!do_after(em_user, 7 SECONDS, teleported))
		to_chat(em_user, span_warning("You fail to recall [teleported]."))
		return FALSE
	teleported.visible_message(span_warning("[teleported] phases out of existence!"))
	try_servant_warp(teleported, get_turf(pick(GLOB.abscond_markers)))
	to_chat(em_user, "You recall [teleported].")
	em_user.marked_servant = null
	return TRUE

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
	var/turf/servant_turf = get_turf(input_servant)
	if((locate(/obj/effect/blessing) in servant_turf.contents) || istype(get_area(input_servant), /area/station/service/chapel))
		to_chat(usr, span_warning("Something is blocking you!"))
		return
	do_teleport(usr, get_turf(input_servant), 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
	usr.playsound_local(get_turf(usr), 'sound/magic/magic_missile.ogg', 50, TRUE, pressure_affected = FALSE)
	to_chat(usr, "You warp to [input_servant].")

/datum/action/innate/clockcult/teleport_to_station
	name = "Teleport to Station"
	desc = "Teleport to a random location on the station."
	button_icon_state = "warp_down"

/datum/action/innate/clockcult/teleport_to_station/Activate()
	var/list/turfs = GLOB.station_turfs
	shuffle_inplace(turfs)
	for(var/turf/possible_turf in turfs)
		if((locate(/obj/effect/blessing) in possible_turf.contents) || istype(get_area(possible_turf), /area/station/service/chapel)) //dont try and teleport to invalid turfs
			continue
		do_teleport(usr, possible_turf, 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
		usr.playsound_local(get_turf(usr), 'sound/magic/magic_missile.ogg', 50, TRUE, pressure_affected = FALSE)
		break

/datum/action/innate/clockcult/eminence_abscond
	name = "Return to Reebe"
	desc = "Teleport back to reebe."
	button_icon_state = "Abscond"

/datum/action/innate/clockcult/eminence_abscond/Activate()
	do_teleport(usr, get_turf(pick(GLOB.abscond_markers)), 0, no_effects = TRUE, channel = TELEPORT_CHANNEL_CULT, forced = TRUE)
	usr.playsound_local(get_turf(usr), 'sound/magic/magic_missile.ogg', 50, TRUE, pressure_affected = FALSE)
