/datum/antagonist/devil
	name = ROLE_DEVIL

	number_of_possible_objectives = 2
	possible_objectives = list(/datum/objective/devil/soulquantity, /datum/objective/devil/soulquality, /datum/objective/devil/sintouch, /datum/objective/devil/buy_target)

	var/devil_name //The devil's real name


/datum/antagonist/devil/on_gain()
	. = ..()
	devil_name = randomDevilName()

/datum/antagonist/devil/on_removal()
/datum/antagonist/devil/apply_innate_effects()
/datum/antagonist/devil/remove_innate_effects()

/datum/antagonist/devil/generate_objectives()
	for(var/i in number_of_possible_objectives)
		var/objective_type = pick_n_take(possible_objectives)
		var/datum/objective/devil/OD = new objective_type
		OD.owner = owner
		OD.find_target()
		current_objectives += OD