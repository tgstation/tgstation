/datum/antagonist/space_dragon
	name = "Space Dragon"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	
/datum/antagonist/space_dragon/greet()
	to_chat(owner, "<b>You are a space dragon!</b>")
	to_chat(owner, "<b>You have come across a station in your territory, thus it belongs to you.</b>")
	to_chat(owner, "<b>From intel you've gained from a derelict shuttle, you know that one person on the station stands out as a leader, who you intend to conquer as a message to the rest of the whelps.</b>")
	to_chat(owner, "<b>Clicking a tile will shoot fire onto that tile.</b>")
	to_chat(owner, "<b>Alt-clicking will let you do a tail swipe, knocking down entities in a tile radius around you.</b>")
	to_chat(owner, "<b>Attacking dead bodies will allow you to gib them to restore health.</b>")
	to_chat(owner, "<b>Exert your will on the station by killing the supposed leader of these invaders, and anyone else who stands in your way.</b>")
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/magic/demon_attack1.ogg'))
	
/datum/antagonist/space_dragon/proc/forge_objectives()
	var/current_heads = SSjob.get_all_heads()
	if(!current_heads)
		var/datum/objective/assassinate/main_target = new()
		main_target.owner = src
		main_target.find_target()
		main_target.explanation_text = "Prevent [main_target.target.name], the invaders' leader, from escaping alive."
		objectives += main_target
	else
		var/datum/mind/selected = pick(current_heads)
		var/datum/objective/assassinate/main_target = new()
		main_target.owner = src
		main_target.target = selected
		main_target.explanation_text = "Prevent [main_target.target.name], the invaders' leader, from escaping alive."
		objectives += main_target
	
/datum/antagonist/space_dragon/on_gain()
	forge_objectives()
	. = ..()
