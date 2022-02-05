/datum/antagonist/joejoe
	name = "\improper Guardian User"
	roundend_category = "guardian users"
	antagpanel_category = "Other"
	job_rank = ROLE_JOEJOE
	show_in_antagpanel = TRUE
	show_to_ghosts = FALSE
	suicide_cry = "MENACING!!!"
	var/good_guy = TRUE
	var/goal = "Greytide worldwide!"
	var/list/possible_goals_badguys = list(
		"Live a quiet and peaceful life, while being a serial killer who steals people's arms.",
		"Stand on top of the station by yourself.",
		"Create the most unstoppable Mafia organization, with no one able to stand in your way.",
		"Become the ultimate lifeform.",
		"Transfering all of the Syndicate's bad luck to the rest of the galaxy, making the Syndicate the best place in the galaxy."
	)
	var/list/possible_goals_goodguys = list(
		"Save your mother from death.",
		"Defeat all the vampires.",
		"Protect your family.",
		"Become the most buff person on the station.",
		"Live a quiet and peaceful life, while coming out of retirement to fight evil.",
	)
	var/datum/action/cooldown/menace/menace_action = new()

/datum/antagonist/joejoe/greet()
	good_guy = pick(list(TRUE, FALSE))
	if(good_guy)
		goal = pick(possible_goals_goodguys)
	else
		goal = pick(possible_goals_badguys)
	to_chat(owner, "<B>You possess a Guardian! Work with them to succeed!</B>")
	to_chat(owner, "<B>Your goal is to: </B> " + goal)

/datum/antagonist/joejoe/apply_innate_effects(mob/living/mob_override)
	..()
	menace_action.Grant(owner.current)

/datum/antagonist/joejoe/remove_innate_effects(mob/living/mob_override)
	menace_action.Remove(owner.current)
	..()

/datum/action/cooldown/menace
	name = "Menace"
	desc = "Be menacing!"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "menacing"
	cooldown_time = 300
	var/mutable_appearance/menace

/datum/action/cooldown/menace/Activate(atom/target)
	StartCooldown(30 SECONDS)
	var/mob/living/carbon/human/human_owner = owner
	if(!menace)
		menace = mutable_appearance('icons/effects/menecing.dmi', "clear", FLY_LAYER)
	playsound(human_owner,'sound/effects/menacing.ogg',100,TRUE)
	flick_overlay_static(menace, human_owner, 5 SECONDS)
	StartCooldown()
	return TRUE
