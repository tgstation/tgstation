/mob/living/carbon/monkey/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/mob/living/carbon/monkey/verb/ventcrawl()  called tick#: [world.time]")
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)