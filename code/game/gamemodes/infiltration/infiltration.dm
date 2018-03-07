/datum/game_mode/infiltration
	name = "infiltration"
	config_tag = "infiltration"
	false_report_weight = 10
	required_players = 35
	required_enemies = 3
	recommended_enemies = 5
	antag_flag = ROLE_INFILTRATOR

	announce_span = "danger"
	announce_text = "Syndicate infiltrators are attempting to board the station!\n\
	<span class='danger'>Infiltrators</span>: Board the station stealthfully and complete your objectives!\n\
	<span class='notice'>Crew</span>: Prevent the infiltrators from completing their objectives!"

	var/datum/team/infiltration/sit_team