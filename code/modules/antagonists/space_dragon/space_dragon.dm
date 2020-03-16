/datum/antagonist/space_dragon
	name = "Space Dragon"
	roundend_category = "space dragons"
	antagpanel_category = "Space Dragon"
	job_rank = ROLE_SPACE_DRAGON
	show_in_antagpanel = TRUE
	show_name_in_check_antagonists = TRUE
	var/list/datum/mind/carp = list()

/datum/antagonist/space_dragon/greet()
	to_chat(owner, "<b>Endless time and space we have moved through.  We do not remember from where we came, we do not know where we will go.  All space belongs to us.\n\
					Space is an empty void, of which our kind is the apex predator, and there was little to rival our claim to this title.\n\
					But now, we find intruders spread out amongst our claim, willing to fight our teeth with magics unimaginable, their dens like lights flicking in the depths of space.\n\
					Today, we will snuff out one of those lights.</b>")
	to_chat(owner, "<span class='boldwarning'>You have five minutes to find a safe location to place down the first rift.  If you take longer than five minutes to place a rift, you will be returned from whence you came.</span>")
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/magic/demon_attack1.ogg'))

/datum/antagonist/space_dragon/proc/forge_objectives()
	var/datum/objective/summon_carp/summon = new()
	summon.dragon = src
	objectives += summon

/datum/antagonist/space_dragon/on_gain()
	forge_objectives()
	. = ..()
	
/datum/objective/summon_carp
	var/datum/antagonist/space_dragon/dragon
	explanation_text = "Summon and protect the rifts to flood the station with carp."
	
/datum/antagonist/space_dragon/roundend_report()
	var/list/parts = list()
	var/datum/objective/summon_carp/S = locate() in objectives
	if(S.check_completion())
		parts += "<span class='redtext big'>The [name] has succeeded!  Station space has been reclaimed by the space carp!</span>"
	parts += printplayer(owner)
	var/objectives_complete = TRUE
	if(objectives.len)
		parts += printobjectives(objectives)
		for(var/datum/objective/objective in objectives)
			if(!objective.check_completion())
				objectives_complete = FALSE
				break
	if(objectives_complete)
		parts += "<span class='greentext big'>The [name] was successful!</span>"
	else
		parts += "<span class='redtext big'>The [name] has failed!</span>"
	parts += "<span class='header'>The [name] was assisted by:</span>"
	parts += printplayerlist(carp)
	return "<div class='panel redborder'>[parts.Join("<br>")]</div>"
