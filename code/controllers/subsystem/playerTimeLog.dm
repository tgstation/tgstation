SUBSYSTEM_DEF(oyuncuDakikaTut)
    name = "oyuncuDakikaTut"
    wait = 60 SECONDS

/datum/controller/subsystem/oyuncuDakikaTut/fire(resumed)
	var/logFile = file("data/playerMinutes.json")
	var/playerMinuteList = json_decode(file2text(logFile))
	fdel(logFile)

	for(var/client/C in GLOB.clients)
		playerMinuteList[C.key] += 1

	WRITE_FILE(logFile, json_encode(playerMinuteList))
