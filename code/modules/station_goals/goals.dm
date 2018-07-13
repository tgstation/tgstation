/datum/map_template/goal
	var/goal_id //The SSmapping goal_template list is ordered by this var


/datum/map_template/goal/command
	name = "StationGoalCommand" //These don't actually need to all match exactly like that
	goal_id= "StationGoalCommand"
	mappath = "_maps/goal/StationGoalCommand.dmm"

/datum/map_template/goal/security
	name = "StationGoal Security"
	goal_id= "StationGoalSecurity"
	mappath = "_maps/goal/StationGoalSecurity.dmm"

/datum/map_template/goal/engineering
	name = "StationGoal Engineering"
	goal_id= "StationGoalEngineering"
	mappath = "_maps/goal/StationGoalEngineering.dmm"

/datum/map_template/goal/science
	name = "StationGoalScience"
	mappath = "_maps/goal/StationGoalScience.dmm"

/datum/map_template/goal/medical
	name = "StationGoalMedical"
	mappath = "_maps/goal/StationGoalMedical.dmm"

/datum/map_template/goal/service
	name = "StationGoalService"
	mappath = "_maps/goal/StationGoalService.dmm"

/datum/map_template/goal/civilian
	name = "StationGoalCivilian"
	mappath = "_maps/goal/StationGoalCivilian.dmm"

/datum/map_template/goal/silicon
	name = "StationGoalSilicon"
	mappath = "_maps/goal/StationGoalSilicon.dmm"

/datum/map_template/goal/syndicate
	name = "StationGoalSyndicate"
	mappath = "_maps/goal/StationGoalSyndicate.dmm"
