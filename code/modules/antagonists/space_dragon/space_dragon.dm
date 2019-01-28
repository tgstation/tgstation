/datum/antagonist/space_dragon
	name = "Space Dragon"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	
/datum/antagonist/space_dragon/greet()
	to_chat(owner, "<b>You are a space dragon!</b>")
	to_chat(owner, "<b>You have come across a station in your territory, thus it belongs to you, and everything and everyone inside it.</b>")
	to_chat(owner, "<b>From intel you've gained, you know that one person on the station stands out amongst the rest as a leader. You intend to conquer that person as a message to the rest of the invaders that you are in control.</b>")
	to_chat(owner, "<b>Clicking a tile will shoot fire onto that tile.</b>")
	to_chat(owner, "<b>Alt-clicking will let you do a tail swipe, knocking down entities in a tile radius around you.</b>")
	to_chat(owner, "<b>Attacking dead bodies will allow you to gib them to restore health.</b>")
	to_chat(owner, "<b>Exert your will on the station by killing the leader of these invaders, and anyone else who stands in your way.</b>")
	owner.announce_objectives()
	SEND_SOUND(owner.current, sound('sound/magic/demon_attack1.ogg'))
	
/datum/antagonist/space_dragon/proc/forge_objectives()
	var/current_heads = SSjob.get_all_heads()
	var/datum/objective/assassinate/killchosen = new
	killchosen.owner = owner
	var/datum/mind/selected = pick(current_heads)
	killchosen.target = selected
	killchosen.update_explanation_text()
	objectives += killchosen
	var/datum/objective/survive/survival = new
	survival.owner = owner
	objectives += survival
	
/datum/antagonist/space_dragon/on_gain()
	forge_objectives()
	. = ..()
