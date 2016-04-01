/datum/game_mode/tensioner
	name = "just fuck my shit up"
	config_tag = "tensioner"
	required_players = 0
	var/If_there_were_two_guys_on_the_moon_and_one_killed_the_other_with_a_rock_would_that_be_fucked_up_or_what = 0
	var/doctor_incomings_mean_meme_machine = 0

/datum/game_mode/tensioner/announce()
	world << "<B>The current game mode is - Tensioner!</B>"
	world << "<B>Oh boy!</B>"

/datum/game_mode/tensioner/process()
	doctor_incomings_mean_meme_machine++
	if(doctor_incomings_mean_meme_machine > 100 * If_there_were_two_guys_on_the_moon_and_one_killed_the_other_with_a_rock_would_that_be_fucked_up_or_what)
		if(Do_Something())
			If_there_were_two_guys_on_the_moon_and_one_killed_the_other_with_a_rock_would_that_be_fucked_up_or_what++
			doctor_incomings_mean_meme_machine = 0

/datum/game_mode/tensioner/proc/Do_Something()
	var/datum/admins/I = new
	var/why_is_this_a_var = pick(I.makeTraitors(), I.makeChanglings(), I.makeRevs(), I.makeWizard(), I.makeCult(), I.makeNukeTeam(), I.makeAliens(), I.makeSpaceNinja(), I.makeDeathsquad(), I.makeGangsters(), I.makeOfficial(), I.makeAbductorTeam(), I.makeRevenant(), I.makeShadowling(), I.makeERPsquad())
	return why_is_this_a_var