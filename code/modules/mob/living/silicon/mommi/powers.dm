/*
/mob/living/silicon/robot/mommi/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Robot Commands"
	var/mob/living/silicon/robot/mommi/R = src
	if(R.canmove)
		handle_ventcrawl()
*/

/mob/living/silicon/robot/mommi/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Robot Commands"

	if(stat != CONSCIOUS)
		return
	var/mob/living/silicon/robot/mommi/R = src
	if(!R.canmove)
		return

	if (layer != TURF_LAYER+0.2)
		layer = TURF_LAYER+0.2

		visible_message("<span class='name'>[src] scurries to the ground!</span>", \
						"<span class='notice'>You are now hiding.</span>")
	else
		layer = MOB_LAYER
		visible_message("[src] slowly peaks up from the ground...", \
					"<span class='notice'>You have stopped hiding.</span>")

	updateicon()

/mob/living/silicon/robot/mommi/verb/park()
	set name = "Toggle Parking Brake"
	set desc = "Lock yourself in place"
	set category = "Robot Commands"
	var/mob/living/silicon/robot/mommi/R = src
	R.anchored=!R.anchored
	R.canmove=!R.anchored
	updateicon()