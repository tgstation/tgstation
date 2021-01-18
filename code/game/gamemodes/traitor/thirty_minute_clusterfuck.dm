/**
 * Thirty minute clusterfuck
 *
 * Traitor gamemode where all traitors have the same objective, to have the shuttle called at a specific time.
 *
 * This gamemode is a slight variant of traitor, giving all traitors the same two objectives:  ensure the shuttle is only called once, and have the shuttle be called between the thirty and fourty five minute marks.  This should lead to a station that's relatively quiet, but then absolutely EXPLODES into chaos as multiple traitors all simultaniously try to get the shuttle called.
 */
/datum/game_mode/traitor/thirty_minute_clusterfuck
	name = "Thirty minute clusterfuck"
	config_tag = "clusterfuck"
	report_type = "traitor"
	false_report_weight = 0 //Don't put this in false reports.
	votable = FALSE
	overwrite_objectives = TRUE
	overwrite_objectives_with = list(/datum/objective/call_limit, /datum/objective/call_at_time, /datum/objective/survive)
	
	
/datum/game_mode/traitor/thirty_minute_clusterfuck/generate_report()
	return "Nanotrasen has found a gambling ring taking bets on how long it will take for the emergency shuttle to be called.  It is possible that some syndicates will attempt to sabotoge the station to win their bet."
