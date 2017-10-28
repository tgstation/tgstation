/mob/dead/observer/say_dead(var/message)
	if(message == "*fart" || message == "*scream")
		to_chat(src, "<span class='danger'>Please don't do emotes in the chat. ([message])</span>")
		return
	..()