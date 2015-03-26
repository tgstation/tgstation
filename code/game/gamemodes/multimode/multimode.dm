/datum/game_mode/multimode
	name = "double trouble"
	config_tag = "doubletrouble"
	required_players = 40
	pre_setup_before_jobs = 1
	metamode = 1
	var/number_of_modes = 2
	var/list/modes = list()
	var/list/post_job_antagonists = list()

/datum/game_mode/multimode/triple //Oh baby
	name = "triple threat"
	config_tag = "triplethreat"
	required_players = 50
	number_of_modes = 3

/datum/game_mode/multimode/announce()
	for(var/datum/game_mode/G in modes)
		G.announce()

/datum/game_mode/multimode/pre_setup()
	var/list/datum/game_mode/runnable_modes = config.get_runnable_modes()
	var/list/datum/game_mode/usable_modes = list()

	for(var/datum/game_mode/mode in runnable_modes)
		if(!mode.metamode)
			usable_modes += mode

	if(!usable_modes)
		return 0

	for(var/i = 1, i <= number_of_modes, i++)
		var/mode_to_add = pickweight(usable_modes)
		modes += mode_to_add
		usable_modes -= mode_to_add
		if(!usable_modes)
			break

	for(var/datum/game_mode/mode in modes)
		if(!mode.pre_setup_before_jobs) //Run their pre_setup later after job selection but before post
			post_job_antagonists += mode
		else
			mode.pre_setup()

/datum/game_mode/multimode/post_setup()
	for(var/datum/game_mode/mode in post_job_antagonists)
		mode.pre_setup()

	for(var/datum/game_mode/mode in modes)
		mode.post_setup()

	spawn(150)	handle_edgecases() //Allow other spawn shinanagans in indiviudual modes to resolve before finalizing things

	SSshuttle.emergencyNoEscape = 0

/datum/game_mode/multimode/make_antag_chance()
	return

/datum/game_mode/multimode/process()
	for(var/datum/game_mode/mode in modes)
		mode.process()

/datum/game_mode/multimode/declare_completion() //only one gets top billing if neither ended the round on their own terms
	var/datum/game_mode/mode = pick(modes)
	mode.declare_completion()

/datum/game_mode/multimode/proc/handle_edgecases() //AW HERE WE GO
	if(syndicates && traitors) //These guys are actually on the same side and should help each other if possible
		var/hijacker_present
		var/escape_needed
		for(var/datum/mind/traitor in traitors) //Traitors are informed that nuke ops are here and how to succeed if the station explodes
			var/message = "<B><font size=3 color=red>Your employers have marked this station for annihilation!</font><br>The team tasked with destroying the station has been made aware of your presence here, do not impede their mission.</B>"
			if(locate(/datum/objective/hijack) in traitor.objectives)
				message += "<br>You will need to hijack the shuttle before the nuke is detonated."
				hijacker_present = 1
			else if(locate(/datum/objective/escape) in traitor.objectives)
				message += "<br>Be aware that if the team is successful in deploying the nuke you may still escape alive by extracting with the team."
				escape_needed = 1
			else if(locate(/datum/objective/survive) in traitor.objectives)
				message += "<br>You should seek asylum away from the station if the team successfully arms the nuke."
			traitor.current << message
		for(var/datum/mind/nukeop in syndicates) //Syndicates are told how they can help the traitors.
			var/message = "<B><font size=3 color=red>We have agents on the station already.</font><br>While your mission takes priority, try to avoid friendly fire.</B>"
			if(hijacker_present)
				message += "<br>We have tasked one or more agent to hijack the escape shuttle. If practical consider setting the nuke to detonate after the escape shuttle leaves the station so that the shuttle may be salvaged."
			if(escape_needed)
				message += "<br>One or more agents will need extraction. If practical allow them to return with your team to the shuttle."
 			message += "<br><B>Agents currently operating on station:</B><br>"
 			for(var/datum/mind/traitor in traitors)
 				message += "[traitor.name], "
 			nukeop.current << message