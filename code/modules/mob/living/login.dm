/mob/living/Login()
	..()
	//Mind updates
	sync_mind()
	mind.show_memory(src, 0)

	//Round specific stuff
	if(ticker && ticker.mode)
		switch(ticker.mode.name)
			if("sandbox")
				CanBuild()

	//Vents
	if(ventcrawler)
		src << "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>"
	//Should update regardless of if we can ventcrawl, since we can end up in pipes in other ways.
	update_pipe_vision(loc)

	update_interface()
	return .
