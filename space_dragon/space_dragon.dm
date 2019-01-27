/datum/antagonist/space_dragon
	name = "Space Dragon"
	show_in_antagpanel = FALSE
	show_name_in_check_antagonists = TRUE
	
/datum/antagonist/space_dragon/greet()
	to_chat(owner, "<b>You are a space dragon!</b>")
	to_chat(owner, "<b>You have come across a station in your territory, thus it belongs to you.</b>")
	to_chat(owner, "<b>Clicking a tile will shoot fire onto that tile.</b>")
	to_chat(owner, "<b>Alt-clicking will let you do a tail swipe, knocking down entities in a tile radius around you.</b>")
	to_chat(owner, "<b>You will heal very slowly, and gibbing bodies gives more health.</b>")
	to_chat(owner, "<b>Exert your will on the station, and kill whoever gets in your way.</b>")
	SEND_SOUND(owner.current, sound('sound/magic/demon_attack1.ogg'))
	