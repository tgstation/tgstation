/datum/round_event_control/false_war
	name = "False Nuke Ops War Declaration"
	typepath = /datum/round_event/false_war
	weight = 10
	min_players = 30
	earliest_start = 300
	max_occurrences = 1

/datum/round_event/false_war
	announceWhen	= 1
	startWhen = 1

/datum/round_event/false_war/announce()
	priority_announce("[syndicate_name()] [pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")] has declared his intent to utterly destroy [station_name()] with a nuclear device, and dares the crew to try and stop them.", title = "Declaration of War", sound = 'sound/machines/Alarm.ogg')

/datum/round_event/false_war/start()
	config.shuttle_refuel_delay = max(config.shuttle_refuel_delay, CHALLENGE_SHUTTLE_DELAY)
