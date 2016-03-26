/datum/game_mode/extended/events
	name = "extended events"
	config_tag = "extendedevents"
	required_players = 0

/datum/game_mode/extended/events/announce()
	world << "<B>The current game mode is - Extended Role-Playing with Summon Events!</B>"
	world << "<B>Just have fun and get teleported into space!</B>"

/datum/game_mode/extended/events/pre_setup()
	summonevents()
	summonevents()
	summonevents()
	summonevents()
	summonevents()
	return 1