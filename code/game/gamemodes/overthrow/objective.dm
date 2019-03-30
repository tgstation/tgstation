// This is a point based objective. You can only lose if you fail to even handle one single command personnel, else you win. But, if you win, you're given a certain number of points,
// based on the role of the head (Captain, HoP/HoS, other heads, warden, security officers) and whether you converted them, exiled or just killed (applying a modifier of 1.5, 1 and 0.5 respectively)
// because this is meant for the overthrow gamemode, which is a bloodless coup, unlike revs.

// Point system:
// Base points for each role:
// AI, Captain = 5;
// Head of Personnel, Head of Security, target = 4;
// Chief Engineer, Chief Medical Officer, Research Director = 3;

// Modifiers:
// Converting: 1.5 for the converting team, 1 for all the other ones;
// Exiling: 1;
// Killing: 0.5

#define CAPPTS		5
#define AIPTS		5
#define HOPPTS		4
#define HOSPTS		4
#define TARGETPTS	4
#define CEPTS		3
#define CMOPTS		3
#define RDPTS		3

#define CONVERTED_OURS	1.5
#define CONVERTED		1
#define EXILED			1
#define KILLED			0.5

// Parent type holding the get_points proc used for round end log.
/datum/objective/overthrow

/datum/objective/overthrow/check_completion()
	return get_points() ? TRUE : FALSE

/datum/objective/overthrow/proc/get_points()
	return 0 // int, not bool

/datum/objective/overthrow/proc/result_points(datum/mind/the_dude, base_points) // App
	var/initial_points = base_points
	if(the_dude)
		var/datum/antagonist/overthrow/O = the_dude.has_antag_datum(/datum/antagonist/overthrow)
		if(!the_dude.current || the_dude.current.stat == DEAD)
			initial_points *= KILLED
		else if(!is_station_level(the_dude.current.z) && !is_centcom_level(the_dude.current.z)) // exiled.
			initial_points *= EXILED
		else if(O)
			initial_points *= CONVERTED
			if(team == O.team)
				initial_points *=  CONVERTED_OURS
		else
			initial_points = 0
	else
		initial_points = 0
	return initial_points

// Heads overthrow objective. This targets the heads only, assigning points based on the rank of the head, captain being the highest target.
/datum/objective/overthrow/heads
	var/list/targets = list()	// We want one objective for all the heads, instead of 1 objective per head like how it's done for revs, because you don't lose if you get atleast one head.
								// Also, this is an associative list, target = role. Modifiers (defines) are applied on points calculation at round end.

/datum/objective/overthrow/heads/proc/find_targets()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/possible_target in get_crewmember_minds()) // i would use SSjob.get_all_heads() but jesus christ that proc's shit, i ain't using it
		if(!(possible_target in owners) && ishuman(possible_target.current))
			if(possible_target.assigned_role in GLOB.command_positions)
				targets[possible_target] = possible_target.assigned_role
	update_explanation_text()

/datum/objective/overthrow/heads/update_explanation_text()
	if(targets.len)
		explanation_text = "Work with your team to convert, exile or kill "
		explanation_text += english_list(targets)
		explanation_text += ". Converting to your team will give you more points, whereas killing will give you the least. Syndicates don't want to stir up too many troubles."
	else
		explanation_text = "Wait until any heads arrive. Once that happens, check your objectives again to see the updated objective. It may require around [OBJECTIVE_UPDATING_TIME] seconds to update."

/datum/objective/overthrow/heads/check_completion()
	if(!targets.len)
		return TRUE
	. = ..()

// Amount of points = foreach head, result += head basepoints * modifier.
/datum/objective/overthrow/heads/get_points()
	var/base_points = 0
	for(var/i in targets)
		var/datum/mind/M = i
		if(M)
			var/target_points
			var/role = targets[M]
			switch(role)
				if("Captain")
					target_points = CAPPTS
				if("Head of Personnel")
					target_points = HOPPTS
				if("Head of Security")
					target_points = HOSPTS
				if("Chief Engineer")
					target_points = CEPTS
				if("Research Director")
					target_points = RDPTS
				if("Chief Medical Officer")
					target_points = CMOPTS
			base_points += result_points(M, target_points)
	return base_points

// AI converting objective. The team who managed to convert the AI with the overthrow module gets the normal 1.5x boost.
/datum/objective/overthrow/AI
	explanation_text = "Enslave the AIs to your team using the special AI module board in your storage implant. It is required you use said module."

/datum/objective/overthrow/AI/get_points() // If you simply kill the Ai you get nothing, you need it to overthrow the heads.
	. = 0 // Support for multiple AIs. More AIs means more control over the station.
	for(var/i in GLOB.ai_list)
		var/mob/living/silicon/ai/AI = i
		if(AI.mind)
			var/datum/mind/M = AI.mind
			var/datum/antagonist/overthrow/O = M.has_antag_datum(/datum/antagonist/overthrow)
			if(M)
				. += (O.team == team) ? AIPTS*CONVERTED_OURS : AIPTS

/datum/objective/overthrow/AI/update_explanation_text()
	if(!GLOB.ai_list.len)
		explanation_text = "Nothing."
	else
		explanation_text = "Enslave the AIs to your team using the special AI module board in your storage implant. It is required you use said module."

/datum/objective/overthrow/AI/check_completion()
	if(!GLOB.ai_list.len)
		return TRUE
	. = ..()

// Overthrow target objective. A crewmember in particular has a certain bond with some centcom officials, and the Syndicate want you to target him in particular, even though he's not a head.
/datum/objective/overthrow/target

/datum/objective/overthrow/target/update_explanation_text()
	if(target)
		explanation_text = "Work with your team to convert, exile or kill [target.name], the [target.assigned_role]. Converting to your team will give you more points, whereas killing will give you the least. Syndicates don't want to stir up too many troubles."
	else
		explanation_text = "Nothing."

/datum/objective/overthrow/target/is_unique_objective(datum/mind/possible_target,dupe_search_range) 
	if(possible_target.assigned_role in GLOB.command_positions)
		return FALSE
	return TRUE

/datum/objective/overthrow/target/check_completion()
	if(!target)
		return TRUE
	. = ..()

/datum/objective/overthrow/target/get_points()
	return result_points(target, TARGETPTS)
