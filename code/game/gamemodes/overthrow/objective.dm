// This is a point based objective. You can only lose if you fail to even handle one single command personnel, else you win. But, if you win, you're given a certain number of points,
// based on the role of the head (Captain, HoP/HoS, other heads, warden, security officers) and whether you converted them, exiled or just killed (applying a modifier of 1.5, 1 and 0.5 respectively)
// because this is meant for the overthrow gamemode, which is a bloodless coup, unlike revs.

// Point system:
// Base points for each role:
// AI, Captain = 5;
// Head of Personnel, Head of Security, target = 4;
// Chief Engineer, Chief Medical Officer, Research Director = 3;
// Warden = 2;
// Security Officer = 1

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
#define WARDENPTS	2
#define SECPTS		1

#define CONVERTED_OURS	1.5
#define CONVERTED		1
#define EXILED			1
#define KILLED			0.5

/datum/objective/ovethrow_heads
	var/list/targets = list()	// we want one objective for all the heads, instead of 1 objective per head, because you don't actually "lose" if you get atleast one head.
								// Also, this is an associative list, target = role. Modifiers (defines) are applied on points calculation at round end.

/datum/objective/ovethrow_heads/proc/find_targets()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/possible_target in get_crewmember_minds())
		if(!(possible_target in owners) && ishuman(possible_target.current))
			if(possible_target.assigned_role in GLOB.command_positions)
				targets[possible_target] = possible_target.assigned_role
	update_explanation_text()

/datum/objective/ovethrow_heads/update_explanation_text()
	explanation_text = "Convert, exile or kill "
	explanation_text += targets.Join(",")
	explanation_text += ". Converting to your team will give you more points, whereas killing will give you the least. Syndicates don't want to stir up too many troubles."

/datum/objective/ovethrow_heads/check_completion() // This won't return a boolean as usual, but the amount of points earned.
	var/base_points = 0
	for(var/i in targets)
		var/datum/mind/M = i
		if(M && M.current)
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
			// modifiers
			var/datum/antagonist/overthrow/O = M.has_antag_datum(/datum/antagonist/overthrow)
			if(M.current.stat == DEAD) // yeah, you gotta defend him even if you converted him
				target_points *= KILLED
			else if(!is_station_level(M.current.z) && !is_centcom_level(M.current.z)) // exiled.
				target_points *= EXILED
			else if(O) //dude's alive, on station/centcom and converted, nice
				target_points *= CONVERTED // doesn't matter to which team
				if(team == O.team) // converted to our team, nice
					target_points *=  CONVERTED_OURS
			else // you didn't do anything, no reward for you
				target_points = 0
			base_points += target_points
	return base_points

/datum/objective/overthrow_AI // Basically a shared objective. All teams get the same amount of points, but obviously the one controlling the AI will have more power ingame.
	explanation_text = "Enslave the AI using the special AI module board in your storage implant. It is required you use said module."

/datum/objective/overthrow_AI/check_completion() // Also returns points, just AIPTS. If you simply kill the Ai you get nothing, you need it to overthrow the heads.
	for(var/i in GLOB.ai_list)
		var/mob/living/silicon/ai/AI = i
		if(AI.laws && AI.laws.id == "overthrow")
			return AIPTS

/datum/objective/overthrow_target

/datum/objective/overthrow_target/update_explanation_text()
	explanation_text = "Convert, exile or kill [target.name], the [target.assigned_role]."

/datum/objective/overthrow_target/is_unique_objective(datum/mind/possible_target)
	if(possible_target.assigned_role in GLOB.command_positions)
		return FALSE
	return TRUE

/datum/objective/overthrow_target/check_completion()
	var/base_points
	if(target && target.current)
		base_points = TARGETPTS
		var/datum/antagonist/overthrow/O = target.has_antag_datum(/datum/antagonist/overthrow)
		if(target.current.stat == DEAD)
			base_points *= KILLED
		else if(!is_station_level(target.current.z) && !is_centcom_level(target.current.z)) // exiled.
			base_points *= EXILED
		else if(O)
			base_points *= CONVERTED
			if(team == O.team)
				base_points *=  CONVERTED_OURS
		else
			base_points = 0
	return base_points