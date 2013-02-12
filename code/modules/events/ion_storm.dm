/datum/event/ion_storm/announce()
	if(prob(33))
		command_alert("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert")
		world << sound('sound/AI/ionstorm.ogg')


/datum/event/ion_storm/start()
	IonStorm()