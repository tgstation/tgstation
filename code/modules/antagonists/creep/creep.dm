/datum/antagonist/creep
	name = "Creep"
	show_in_antagpanel = TRUE
	antagpanel_category = "Other"
	show_name_in_check_antagonists = TRUE
	roundend_category = "creeps"
	var/creepiness = 0 //how many sets of people the creep has successfully vvvv
	var/max_creepiness = 3 //how many sets of people the creep needs to protect, kill, polaroid, etc

/datum/antagonist/creep/greet()
	to_chat(owner, "<span class='boldannounce'>You are the Creep!</span>")
	to_chat(owner, "<B>Defend your obsessions from demons and evildoers of the station! Until, of course, the voices want them gone, that is.</B>")
	to_chat(owner, "<B>Check your status tab to see how long you have to defend your current obsession.</B>")
	owner.announce_objectives()

/datum/antagonist/creep/proc/forge_objectives()

	var/datum/objective/protect/timed/mypretties = new
	mypretties.owner = owner
	objectives += mypretties

	var/datum/objective/polaroid/polaroid = new
	polaroid.owner = owner
	polaroid.target = mypretties.target
	objectives += polaroid

	var/datum/objective/assassinate/creep/kill = new
	kill.owner = owner
	kill.target = mypretties.target
	objectives += kill

/datum/antagonist/creep/proc/add_objectives(var/mob/living/old_target) //for when you're done with the first obsession set

	var/datum/objective/protect/timed/mypretties = new
	mypretties.owner = owner
	objectives += mypretties

	var/datum/objective/polaroid/polaroid = new
	polaroid.owner = owner
	polaroid.target = mypretties.target
	objectives += polaroid

	var/datum/objective/assassinate/creep/kill = new
	kill.owner = owner
	kill.target = mypretties.target
	objectives += kill

	if(owner.current.stat != DEAD)//would be annoying to keep getting these after you're dead
		to_chat(owner, "<span class='boldannounce'>You sense your obsession has died. They weren't good enough for you anyways!</span>")
		var/niceguy = pick("looked at you", "opened the airlock for you", "picked up your PDA for you", "said hi in the hallways")
		to_chat(owner, "<B>Besides, the way [mypretties.target.name] [niceguy] that one time means they're way more madly in love with you than [old_target.name] ever was!</B>")
		owner.announce_objectives()

/datum/antagonist/creep/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/creep/roundend_report_header()
	return 	"<span class='header'>There was a Creep!</span><br>"

/datum/antagonist/creep/roundend_report()
	var/list/report = list()

	if(!owner)
		CRASH("antagonist datum without owner")

	report += "<b>[printplayer(owner)]</b>"

	var/objectives_complete = TRUE
	if(objectives.len)
		report += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break

	if(objectives.len == 0 || objectives_complete)
		report += "<span class='greentext big'>The [name] was successful!</span>"
	else
		report += "<span class='redtext big'>The [name] has failed!</span>"

	return report.Join("<br>")


///CREEPY OBJECTIVES///

/datum/objective/protect/timed //protect someone for a set amount of time. Then, it doesn't really matter what happens to them :3
	var/timer = 9000 //15 minutes
	var/ididwin = FALSE

/datum/objective/protect/timed/update_explanation_text()
	addtimer(CALLBACK(src, .proc/didiwin), timer)

/datum/objective/protect/timed/proc/didiwin()
	if(!target || considered_alive(target, enforce_human = human_check))
		ididwin = TRUE

/datum/objective/protect/timed/check_completion()
	return ididwin

/datum/objective/polaroid //take a picture of the target with you in it.
	name = "polaroid"

/datum/objective/polaroid/check_completion()
	var/list/datum/mind/owners = get_owners()
	for(var/datum/mind/M in owners)
		if(!isliving(M.current))
			continue
		var/list/all_items = M.current.GetAllContents()	//this should get things in cheesewheels, books, etc.
		for(var/obj/I in all_items) //Check for wanted items
			if(istype(I, /obj/item/photo))
				var/obj/item/photo/P = I
				if(P.picture.mobs_seen.Find(owner) && P.picture.mobs_seen.Find(target) && !P.picture.dead_seen.Find(target))//you are in the picture, they are but they are not dead.
					return TRUE
	return FALSE

/datum/objective/polaroid/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Take a photo with [target.name] while they're alive."
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/creep //triggers the next set of objectives when the target dies
	var/datum/status_effect/deathrattle/deathrattle

/datum/objective/assassinate/creep/update_explanation_text()
	..()
	if(target && target.current)
		explanation_text = "Murder [target.name], the [!target_role_type ? target.assigned_role : target.special_role]."
		target.current.apply_status_effect(STATUS_EFFECT_DEATHRATTLE, "deathrattle")
		deathrattle = target.current.has_status_effect(STATUS_EFFECT_DEATHRATTLE)
		deathrattle.objective = src
	else
		explanation_text = "Free Objective"

/datum/objective/assassinate/creep/deathrattle(var/suicided = FALSE)
	var/datum/antagonist/creep/creeper = owner.has_antag_datum(/datum/antagonist/creep)
	if(creeper.creepiness < creeper.max_creepiness)
		if(creeper.creepiness == 0 && suicided)//your first target suicided, AKA suicide in the first 15 minutes
			creeper.max_creepiness++ //give them another obsession total
		creeper.add_objectives(target)