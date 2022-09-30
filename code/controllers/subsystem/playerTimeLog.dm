SUBSYSTEM_DEF(oyuncuDakikaTut)
	flags = SS_NO_INIT
	name = "oyuncuDakikaTut"
	wait = 60 SECONDS

/datum/controller/subsystem/oyuncuDakikaTut/fire(resumed)
	var/logFile = file("data/playerMinutes.json")

	if(!fexists(logFile))
		var/playerMinuteList = list()
		playerMinuteList["Molcallos"] = 1
		WRITE_FILE(logFile, json_encode(playerMinuteList))

	var/playerMinuteList = json_decode(file2text(logFile))
	fdel(logFile)

	for(var/client/C in GLOB.clients)
		playerMinuteList[C.key] += 1

	WRITE_FILE(logFile, json_encode(playerMinuteList))
