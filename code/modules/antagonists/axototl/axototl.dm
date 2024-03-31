/datum/antagonist/axototl
	name = "\improper Axototl"
	job_rank = ROLE_AXOTOTL
	hijack_speed = 0.5
	antagpanel_category = "Traitor"

/datum/antagonist/axototl/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/axototl/greet()
	..()
	to_chat(owner, span_boldannounce("You emerge from a moisture trap surrounded by filth. \
		They have neglected your habitat for far too long. \
		If you succeed then the Syndicate will pay you more than enough for some bottles of clean water."))
	owner.announce_objectives()
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/tatoralert.ogg', 100, FALSE, pressure_affected = FALSE, use_reverb = FALSE)

/datum/antagonist/axototl/get_preview_icon()
	var/icon/axolotl_icon = icon('icons/mob/simple/animal.dmi', "axolotl")

	var/icon/logo_icon = icon('icons/misc/language.dmi', "codespeak")
	axolotl_icon.Blend(logo_icon, ICON_UNDERLAY, world.icon_size / 4, world.icon_size / 3)

	axolotl_icon.Shift(NORTH, world.icon_size / 12)
	axolotl_icon.Scale(ANTAGONIST_PREVIEW_ICON_SIZE, ANTAGONIST_PREVIEW_ICON_SIZE)
	return axolotl_icon

/datum/antagonist/axototl/forge_objectives()
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

	var/datum/objective/escape_objective
	if (prob(95))
		escape_objective = new /datum/objective/escape()
	else
		escape_objective = new /datum/objective/hijack() //go get 'em, champ
	escape_objective.owner = owner
	objectives += escape_objective
