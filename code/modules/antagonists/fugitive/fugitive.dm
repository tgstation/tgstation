/datum/antagonist/refugee
	name = "Fugitive"
	show_in_antagpanel = FALSE
	roundend_category = "Fugitive"

/datum/antagonist/creep/greet(backstory)
	to_chat(owner, "<span class='boldannounce'>You are the Fugitive!</span>")
	switch(backstory)
		if(prisoner)
			to_chat(owner, "<B>I can't believe we managed to break out of a Nanotrasen superjail! Sadly though, our work is not done. The emergency teleport we all jumped into certainly has got us out</B>")
			to_chat(owner, "<B>It won't be long until Centcom tracks where we've gone off to. I need to work with my fellow escapees to prepare for the troops Nanotrasen is sending, I'm not going back.</B>")
	to_chat(owner, "<span class='boldannounce'>You are not an antagonist in that you may kill whoever you please, but do anything to avoid capture.</span>")
	owner.announce_objectives()
