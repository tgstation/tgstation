/datum/hallucination/station_message
	abstract_hallucination_parent = /datum/hallucination/station_message
	random_hallucination_weight = 1

/datum/hallucination/station_message/start()
	qdel(src) // To be implemented by subtypes, call parent for easy cleanup
	return TRUE

/datum/hallucination/station_message/blob_alert

/datum/hallucination/station_message/blob_alert/start()
	priority_announce("Confirmed outbreak of level 5 biohazard aboard [station_name()]. All personnel must contain the outbreak.", \
		"Biohazard Alert", ANNOUNCER_OUTBREAK5, players = list(hallucinator))
	return ..()

/datum/hallucination/station_message/shuttle_dock

/datum/hallucination/station_message/shuttle_dock/start()
	priority_announce(
					text = "[SSshuttle.emergency] has docked with the station. You have [DisplayTimeText(SSshuttle.emergency_dock_time)] to board the emergency shuttle.",
					title = "Emergency Shuttle Arrival",
					sound = ANNOUNCER_SHUTTLEDOCK,
					sender_override = "Emergency Shuttle Uplink Alert",
					players = list(hallucinator),
					color_override = "orange",
				)
	return ..()

/datum/hallucination/station_message/malf_ai

/datum/hallucination/station_message/malf_ai/start()
	if(!(locate(/mob/living/silicon/ai) in GLOB.silicon_mobs))
		return FALSE

	priority_announce("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", \
		"Anomaly Alert", ANNOUNCER_AIMALF, players = list(hallucinator))
	return ..()

/datum/hallucination/station_message/heretic
	/// This is gross and will probably easily be outdated in some time but c'est la vie.
	/// Maybe if someone datumizes heretic paths or something this can be improved
	var/static/list/ascension_bodies = list(
		list(
			"text" = "Fear the blaze, for the Ashlord, %FAKENAME% has ascended! The flames shall consume all!",
			"sound" = 'sound/ambience/antag/heretic/ascend_blade.ogg',
		),
		list(
			"text" = "Master of blades, the Torn Champion's disciple, %FAKENAME% has ascended! Their steel is that which will cut reality in a maelstom of silver!",
			"sound" = 'sound/ambience/antag/heretic/ascend_blade.ogg',
		),
		list(
			"text" = "Ever coiling vortex. Reality unfolded. ARMS OUTREACHED, THE LORD OF THE NIGHT, %FAKENAME% has ascended! Fear the ever twisting hand!",
			"sound" = 'sound/ambience/antag/heretic/ascend_flesh.ogg',
		),
		list(
			"text" = "Fear the decay, for the Rustbringer, %FAKENAME% has ascended! None shall escape the corrosion!",
			"sound" = 'sound/ambience/antag/heretic/ascend_rust.ogg',
		),
		list(
			"text" = "The nobleman of void %FAKENAME% has arrived, stepping along the Waltz that ends worlds!",
			"sound" = 'sound/ambience/antag/heretic/ascend_void.ogg',
		)
	)

/datum/hallucination/station_message/heretic/start()
	// Unfortunately, this will not be synced if mass hallucinated
	var/mob/living/carbon/human/totally_real_heretic = random_non_sec_crewmember()
	if(!totally_real_heretic)
		return FALSE

	var/list/fake_ascension = pick(ascension_bodies)
	var/announcement_text = replacetext(fake_ascension["text"], "%FAKENAME%", totally_real_heretic.real_name)
	priority_announce(
		text = "[generate_heretic_text()] [announcement_text] [generate_heretic_text()]",
		title = "[generate_heretic_text()]",
		sound = fake_ascension["sound"],
		players = list(hallucinator),
		color_override = "pink",
	)
	return ..()

/datum/hallucination/station_message/cult_summon

/datum/hallucination/station_message/cult_summon/start()
	// Same, will not be synced if mass hallucinated
	var/mob/living/carbon/human/totally_real_cult_leader = random_non_sec_crewmember()
	if(!totally_real_cult_leader)
		return FALSE

	// Get a fake area that the summoning is happening in
	var/area/hallucinator_area = get_area(hallucinator)
	var/area/fake_summon_area_type = pick(GLOB.the_station_areas - hallucinator_area.type)
	var/area/fake_summon_area = GLOB.areas_by_type[fake_summon_area_type]

	priority_announce(
		text = "Figments from an eldritch god are being summoned by [totally_real_cult_leader.real_name] into [fake_summon_area] from an unknown dimension. Disrupt the ritual at all costs!",
		title = "[command_name()] Higher Dimensional Affairs",
		sound = 'sound/ambience/antag/bloodcult/bloodcult_scribe.ogg',
		has_important_message = TRUE,
		players = list(hallucinator),
	)
	return ..()

/datum/hallucination/station_message/meteors
	random_hallucination_weight = 2

/datum/hallucination/station_message/meteors/start()
	priority_announce("Meteors have been detected on collision course with the station.", "Meteor Alert", ANNOUNCER_METEORS, players = list(hallucinator))
	return ..()

/datum/hallucination/station_message/supermatter_delam

/datum/hallucination/station_message/supermatter_delam/start()
	SEND_SOUND(hallucinator, 'sound/magic/charge.ogg')
	to_chat(hallucinator, span_boldannounce("You feel reality distort for a moment..."))
	return ..()

/datum/hallucination/station_message/clock_cult_ark
	// Clock cult's long gone, but this stays for posterity.
	random_hallucination_weight = 0

/datum/hallucination/station_message/clock_cult_ark/start()
	hallucinator.playsound_local(hallucinator, 'sound/machines/clockcult/ark_deathrattle.ogg', 50, FALSE, pressure_affected = FALSE)
	hallucinator.playsound_local(hallucinator, 'sound/effects/clockcult_gateway_disrupted.ogg', 50, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(play_distant_explosion_sound)), 2.7 SECONDS)
	return TRUE // does not call parent to finish up the sound in a few seconds

/datum/hallucination/station_message/clock_cult_ark/proc/play_distant_explosion_sound()
	if(QDELETED(src))
		return

	hallucinator.playsound_local(get_turf(hallucinator), 'sound/effects/explosion_distant.ogg', 50, FALSE, pressure_affected = FALSE)
	qdel(src)
