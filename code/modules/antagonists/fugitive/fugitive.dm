/datum/antagonist/fugitive
	name = "Fugitive"
	//show_in_antagpanel = FALSE //remove this later- they are event specific. this is 100% for testing
	roundend_category = "Fugitive"
	silent = TRUE //greet called by the event

/datum/antagonist/fugitive/greet(backstory)
	to_chat(owner, "<span class='boldannounce'>You are the Fugitive!</span>")
	switch(backstory)
		if("prisoner")
			to_chat(owner, "<B>I can't believe we managed to break out of a Nanotrasen superjail! Sadly though, our work is not done. The emergency teleport at the station logs everyone who uses it, and where they went.</B>")
			to_chat(owner, "<B>It won't be long until Centcom tracks where we've gone off to. I need to work with my fellow escapees to prepare for the troops Nanotrasen is sending, I'm not going back.</B>")
		if("cultist")
			to_chat(owner, "<B>Blessed be our journey so far, but I fear the worst has come to our doorstep, and only those with the strongest faith will survive.</B>")
			to_chat(owner, "<B>Our religeon has been repeatedly culled by Nanotrasen because it is categorized as an \"Enemy of the Corporation\", whatever that means.</B>")
			to_chat(owner, "<B>Now there are only three of us left, and Nanotrasen is coming. But we have a secret weapon: Our weakened god, Yalp Elor, will help us survive.</B>")
		if("waldo")
			to_chat(owner, "<B>Hi, Friends!</B>")
			to_chat(owner, "<B>My name is Waldo. I'm just setting off on a galaxywide hike. You can come too. All you have to do is find me.</B>")
			to_chat(owner, "<B>By the way, I'm not traveling on my own. wherever I go, there are lots of other characters for you to spot. First find the people hunting me (They're somewhere around centcom).</B>")
	to_chat(owner, "<span class='boldannounce'>You are not an antagonist in that you may kill whomever you please, but you can do anything to avoid capture.</span>")
	owner.announce_objectives()
