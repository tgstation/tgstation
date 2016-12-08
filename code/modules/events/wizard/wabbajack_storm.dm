/datum/round_event_control/wizard/wabbajack_storm
	name = "Wabbajack Storm"
	weight = 1
	typepath = /datum/round_event/wabbajack_storm

/datum/round_event/wabbajack_storm
	startWhen = 7
	announceWhen = 1
	var/list/subjects = list()

/datum/round_event/wabbajack_storm/announce()
	set waitfor = 0
	playsound_global('sound/magic/lightning_chargeup.ogg', repeat=0, channel=1, volume=100)
	sleep(80)
	priority_announce("Massive magical anomaly detected en route to [station_name()]. Brace for impact.")
	sleep(20)
	playsound_global('sound/magic/Staff_Change.ogg', repeat=0, channel=1, volume=100)

/datum/round_event/wabbajack_storm/setup()
	subjects = shuffle(living_mob_list.Copy())

/datum/round_event/wabbajack_storm/start()
	while(subjects.len)
		CHECK_TICK

		var/mob/living/M = pop(subjects)

		if(!M)
			continue

		M.audible_message("<span class='italics'>...wabbajack...wabbajack...</span>")
		playsound(M.loc, 'sound/magic/Staff_Change.ogg', 50, 1, -1)

		wabbajack(M)
