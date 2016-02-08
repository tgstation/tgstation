/datum/game_mode/proc/auto_declare_completion_sintouched()
	var/text = ""
	if(sintouched.len)
		text += "<br><span class='big'><b>The sintouched were:</b></span>"
		var/list/sintouchedUnique = uniqueList(sintouched)
		for(var/datum/mind/sintouched_mind in sintouchedUnique)
			text += printplayer(sintouched_mind)
			text += printobjectives(sintouched_mind)
		text += "<br>"
	text += "<br>"
	world << text
