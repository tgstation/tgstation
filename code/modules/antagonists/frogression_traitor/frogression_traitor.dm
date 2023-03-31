/datum/antagonist/frogression_traitor
	name = "\improper Frogression Traitor"
	job_rank = ROLE_FROGRESSION_TRAITOR
	hijack_speed = 0.5
	suicide_cry = "FOR THE CROAKDICATE!!" //don't even know how you would manage to do this
	antagpanel_category = "Traitor"

/datum/antagonist/frogression_traitor/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/frogression_traitor/greet()
	..()
	to_chat(owner, span_boldannounce("You emerge from the moisture trap with your small, webbed hands and feet. \
		You can't help but feel like this was not the intention of the long-ranged mindswap experiment... \
		One small hiccup is no excuse to abandon the mission though! \
		You've still got your wits and your training. \
		This makes you more dangerous and durable than most other amphibians."))
	owner.announce_objectives()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/frogression_traitor/get_preview_icon()
	var/icon/frog_icon = icon('icons/mob/simple/animal.dmi', "frog")

	var/icon/logo_icon = icon('icons/misc/language.dmi', "codespeak")
	frog_icon.Blend(logo_icon, ICON_UNDERLAY, world.icon_size / 4, world.icon_size / 3)

	frog_icon.Shift(NORTH, world.icon_size / 12)
	frog_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return frog_icon

/datum/antagonist/frogression_traitor/forge_objectives()
	var/list/potential_objective_types = list(
		/datum/objective/assassinate,
		/datum/objective/maroon,
		/datum/objective/protect,
		/datum/objective/jailbreak,
	)

	var/list/already_targeted = list() //for blacklisting already-set targets
	var/objective_limit = CONFIG_GET(number/traitor_objectives_amount)
	for(var/i in 1 to objective_limit)
		var/picked_objective = pick(potential_objective_types)
		var/datum/objective/objective = new picked_objective
		objective.owner = owner
		objective.find_target(blacklist = already_targeted)
		already_targeted += objective.target
		objectives += objective

	var/datum/objective/escape_objective = new
	if (prob(95))
		escape_objective = new /datum/objective/escape()
	else
		escape_objective = new /datum/objective/hijack() //go get 'em, champ
	escape_objective.owner = owner
	objectives += escape_objective
