/datum/antagonist/changeling
	name = ROLE_CHANGELING

	text_on_lose = "You are no longer a changeling!"

	give_special_equipment = FALSE

	number_of_possible_objectives = 2
	possible_objectives = list(/datum/objective/steal, /datum/objective/assassinate, /datum/objective/maroon)

/datum/antagonist/changeling/apply_innate_effects()
	if(!owner)
		return
	if(owner.current)
		owner.current.make_changeling()

	ticker.mode.update_changeling_icons_added(owner)

/datum/antagonist/changeling/generate_objectives()
	var/has_escape = TRUE

	var/datum/objective/absorb/absorb_objective = new
	absorb_objective.owner = owner
	absorb_objective.gen_amount_goal(6,8)
	current_objectives += absorb_objective

	if(LAZYLEN(active_ais()))
		possible_objectives += /datum/objective/destroy

	for(var/i in number_of_possible_objectives)
		var/random_objective = pick_n_take(possible_objectives)
		var/datum/objective/O = new random_objective
		O.owner = owner
		O.find_target()
		current_objectives += O
		if(istype(O, /datum/objective/maroon))
			var/datum/objective/escape/escape_with_identity/id_theft = new
			id_theft.owner = owner
			id_theft.target = O.target
			id_theft.update_explanation_text()
			current_objectives += id_theft
			has_escape = FALSE

	if(has_escape)
		if(prob(50)) //50% chance of regular escape or escape with ID theft
			var/datum/objective/escape/escape = new
			escape.owner = owner
			current_objectives += escape
		else
			var/datum/objective/escape/escape_with_identity/id_theft = new
			id_theft.owner = owner
			id_theft.find_target()
			current_objectives += id_theft

/datum/antagonist/changeling/greet()
	. = ..()
	if(owner.changeling.changelingID)
		owner.current << "<span class='boldannounce'>You are [owner.changeling.changelingID], a changeling! You have absorbed and taken the form of a human.</span>"
	owner.current << "<span class='boldannounce'>Use say \":g message\" to communicate with your fellow changelings.</span>"
	owner.current << "<b>You must complete the following tasks:</b>"