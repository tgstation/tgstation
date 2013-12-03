/obj/machinery/computer/orion_trail
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	circuit = /obj/item/weapon/circuitboard/arcade
	var/engine = 0
	var/hull = 0
	var/electronics = 0
	var/food = 80
	var/fuel = 60
	var/turns = 4
	var/gameover = 0
	var/playing = 0
	var/alive = 4
	var/eventdat = null
	var/event = null
	var/list/settlers = list("Harry","Larry","Bob")
	var/list/events = list("Raiders"				= 3,
						   "Interstellar Flux"		= 1,
						   "Illness"				= 3,
						   "Breakdown"				= 2,
						   "Malfunction"			= 2,
						   "Collision"              = 1
						   )
	// Sets up the main trail
	var/list/stops = list("Pluto","Asteroid Belt","Proxima Centauri","Dead Space","Rigel Prime","Tau Ceti Beta","Black Hole","Space Outpost Beta-9","Orion Prime")
	var/list/stopblurbs = list(
		"Long since occupied with long-range sensors and scanners stands ready to, and indeed continues to, probe the far reaches of the galaxy.",
		"At the edge of the Sol system lies a treacherous asteroid belt, many have been crushed by stray asteroids and miss-guided judgement.",
		"The nearest star system to Sol, in ages past it stood as a reminder of the boundaries of sub-light travel, now it is a low-population sanctuary for adventureres and traders.",
		"This region of space is particularly devoid of matter. Such low-density pockets are known to exist, but the vastness of it is astounding.",
		"Rigel Prime, the center of the Rigel system, burns hot, basking it's planetary bodies in warmth and radiation.",
		"Tau Ceti Beta has recently become a way-point for colonists headed towards Orion. There are many ships and makeshift stations in the viscinity.",
		"Sensors indicate a black-hole's gravitational field is affecting the region of space we were headed through. We could stay the course, but risk being over-come by it's gravity; or we could change course to go around, which will take longer.",
		"You have come into range of the first man-made structure in this region of space. It has been constructed, not by travellers from Sol, but by colonists from Orion. It stands as a monument to the colonist's success.",
		"You have made it to Orion! Congratulations! Your crew is one of the few to start a new foothold for man-kind!"
		)

	var/list/prizes = list(	/obj/item/weapon/storage/box/snappops			= 2,
							/obj/item/toy/AI								= 2,
							/obj/item/clothing/under/syndicate/tacticool	= 2,
							/obj/item/toy/sword								= 2,
							/obj/item/toy/gun								= 2,
							/obj/item/toy/crossbow							= 2,
							/obj/item/weapon/storage/box/fakesyndiesuit		= 2,
							/obj/item/weapon/storage/fancy/crayons			= 2,
							/obj/item/toy/spinningtoy						= 2,
							/obj/item/toy/prize/ripley						= 1,
							/obj/item/toy/prize/fireripley					= 1,
							/obj/item/toy/prize/deathripley					= 1,
							/obj/item/toy/prize/gygax						= 1,
							/obj/item/toy/prize/durand						= 1,
							/obj/item/toy/prize/honk						= 1,
							/obj/item/toy/prize/marauder					= 1,
							/obj/item/toy/prize/seraph						= 1,
							/obj/item/toy/prize/mauler						= 1,
							/obj/item/toy/prize/odysseus					= 1,
							/obj/item/toy/prize/phazon						= 1
							)

/obj/machinery/computer/orion_trail/proc/newgame()
	..()
	// Set names of settlers in crew
	settlers = list()
	var/list/settlernames = list("Bob","Henry","Joe","Mary","Jill","Mandy")
	for(var/i = 1; i <= 3; i++)
		var/choice = pick_n_take(settlernames)
		settlers += choice
	settlers += "[usr]"
	// Re-set items to defaults
	engine = 1
	hull = 1
	electronics = 1
	food = 80
	fuel = 60
	alive = 4
	turns = 1
	event = null
	playing = 1
	gameover = 0

/obj/machinery/computer/orion_trail/attack_hand(mob/user as mob)
	if(..())
		return
	if(fuel <= 0 || food <=0 || settlers.len == 0)
		gameover = 1
		event = null
	user.set_machine(src)
	var/dat = ""
	if(gameover)
		dat = "<center><h1>Game Over</h1></center>"
		dat += "Like many before you, your crew never made it to Orion, lost to space... <br><b>Forever</b>."
		dat += "<P ALIGN=Right><a href='byond://?src=\ref[src];menu=1'>OK...</a></P>"
		var/datum/browser/popup = new(user, "arcade", "The Orion Trail")
		popup.set_content(dat)
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
		return
	else if(event)
		var/datum/browser/popup = new(user, "arcade", "The Orion Trail")
		popup.set_content(eventdat)
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
		return
	else if(playing)
		var/title = stops[turns]
		var/subtext = stopblurbs[turns]
		dat = "<center><h1>[title]</h1></center>"
		dat += "[subtext]"
		dat += "<h3><b>Crew:</b></h3>"
		dat += english_list(settlers)
		dat += "<br><b>Food: </b>[food] | <b>Fuel: </b>[fuel]"
		dat += "<br><b>Engine Parts: </b>[engine] | <b>Hull Panels: </b>[hull] | <b>Electronics: </b>[electronics]<br>"
		if(turns == 7)
			dat += "<P ALIGN=Right><a href='byond://?src=\ref[src];pastblack=1'>Go Around</a> <a href='byond://?src=\ref[src];blackhole=1'>Continue</a></P>"
		else
			dat += "<P ALIGN=Right><a href='byond://?src=\ref[src];continue=1'>Continue</a></P>"
		dat += "<P ALIGN=Right><a href='byond://?src=\ref[src];close=1'>Close</a></P>"
		var/datum/browser/popup = new(user, "arcade", "The Orion Trail")
		popup.set_content(dat)
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
		return
	else
		dat = "<center><h2>The Orion Trail</h2></center>"
		dat += "<br><center><h3>Experience the journey of your ancestors!</h3></center><br><br>"
		dat += "<center><b><a href='byond://?src=\ref[src];newgame=1'>New Game</a></b></center>"
		dat += "<P ALIGN=Right><a href='byond://?src=\ref[src];close=1'>Close</a></P>"
		var/datum/browser/popup = new(user, "arcade", "The Orion Trail")
		popup.set_content(dat)
		popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
		popup.open()
		return

/obj/machinery/computer/orion_trail/Topic(href, href_list)
	if(..())
		return
	if(href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=arcade")
	else if (href_list["continue"]) //Continue your travels
		if(turns >= 9)
			win()
		else if(turns == 2)
			if(prob(30))
				event = "Collision"
				event()
				food -= alive*2
				fuel -= 5
				turns += 1
			else
				food -= alive*2
				fuel -= 5
				turns += 1
				if(prob(75))
					event = pickweight(events)
					event()
		else
			food -= alive*2
			fuel -= 5
			turns += 1
			if(prob(75))
				event = pickweight(events)
				event()
	else if(href_list["newgame"]) //Reset everything
		newgame()
	else if(href_list["menu"]) //back to the main menu
		playing = 0
		event = null
		gameover = 0
		food = 80
		fuel = 60
		settlers = list("Harry","Larry","Bob")
	else if(href_list["slow"]) //slow down
		food -= alive*2
		fuel -= 5
		event = null
	else if(href_list["pastblack"]) //slow down
		food -= (alive*2)*3
		fuel -= 15
		turns += 1
		event = null
	else if(href_list["useengine"]) //use parts
		engine -= 1
		event = null
	else if(href_list["useelec"]) //use parts
		electronics -= 1
		event = null
	else if(href_list["usehull"]) //use parts
		hull -= 1
		event = null
	else if(href_list["wait"]) //wait 3 days
		food -= (alive*2)*3
		event = null
	else if(href_list["keepspeed"]) //keep speed
		if(prob(75))
			event = "Breakdown"
			event()
		else
			event = null
	else if(href_list["blackhole"]) //keep speed past a black hole
		if(prob(75))
			event = "BlackHole"
			event()
		else
			event = null
	else if(href_list["holedeath"])
		gameover = 1
		event = null
	else if(href_list["eventclose"]) //end an event
		event = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/orion_trail/proc/event()
	eventdat = "<center><h1>[event]</h1></center>"
	if(event == "Raiders")
		eventdat += "Raiders have come aboard your ship!"
		if(prob(50))
			var/sfood = rand(1,10)
			var/sfuel = rand(1,10)
			food -= sfood
			fuel -= sfuel
			eventdat += "<br>They have stolen [sfood] <b>Food</b> and [sfuel] <b>Fuel</b>."
		else if(prob(10))
			var/deadname = pick_n_take(settlers)
			eventdat += "<br>[deadname] tried to fight back but was killed."
			alive -= 1
		else
			eventdat += "<br>Fortunately you fended them off without any trouble."
		eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];eventclose=1'>Continue</a></P>"
		eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];close=1'>Close</a></P>"

	else if(event == "Interstellar Flux")
		eventdat += "This region of space is highly turbulent. <br>If we go slowly we may avoid more damage, but if we keep our speed we won't waste supplies."
		eventdat += "<br>What will you do?"
		eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];slow=1'>Slow Down</a> <a href='byond://?src=\ref[src];keepspeed=1'>Continue</a></P>"
		eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];close=1'>Close</a></P>"

	else if(event == "Illness")
		eventdat += "A deadly illness has been contracted!"
		var/deadname = pick_n_take(settlers)
		eventdat += "<br>[deadname] was killed by the disease."
		alive -= 1
		eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];eventclose=1'>Continue</a></P>"
		eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];close=1'>Close</a></P>"

	else if(event == "Breakdown")
		eventdat += "Oh no! The engine has broken down!"
		eventdat += "<br>You can repair it with an engine part, or you can make reapirs for 3 days."
		if(engine >= 1)
			eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];useengine=1'>Use Part</a><a href='byond://?src=\ref[src];wait=1'>Wait</a></P>"
		else
			eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];wait=1'>Wait</a></P>"
		eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];close=1'>Close</a></P>"

	else if(event == "Malfunction")
		eventdat += "The ship's systems are malfunctioning!"
		eventdat += "<br>You can replace the broken electronics with spares, or you can spend 3 days troubleshooting the AI."
		if(electronics >= 1)
			eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];useelec=1'>Use Part</a><a href='byond://?src=\ref[src];wait=1'>Wait</a></P>"
		else
			eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];wait=1'>Wait</a></P>"
		eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];close=1'>Close</a></P>"

	else if(event == "Collision")
		eventdat += "Something hit us! Looks like there's some hull damage."
		if(prob(25))
			var/sfood = rand(5,15)
			var/sfuel = rand(5,15)
			food -= sfood
			fuel -= sfuel
			eventdat += "<br>[sfood] <b>Food</b> and [sfuel] <b>Fuel</b> was vented out into space."
		if(prob(10))
			var/deadname = pick_n_take(settlers)
			eventdat += "<br>[deadname] was killed by rapid depressurization."
			alive -= 1
		eventdat += "<br>You can repair the damage with hull plates, or you can spend the next 3 days welding scrap together."
		if(hull >= 1)
			eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];usehull=1'>Use Part</a><a href='byond://?src=\ref[src];wait=1'>Wait</a></P>"
		else
			eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];wait=1'>Wait</a></P>"
		eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];close=1'>Close</a></P>"

	else if(event == "BlackHole")
		eventdat += "You were swept away into the black hole."
		eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];holedeath=1'>Oh...</a></P>"
		eventdat += "<P ALIGN=Right><a href='byond://?src=\ref[src];close=1'>Close</a></P>"



/obj/machinery/computer/orion_trail/proc/win()
	playing = 0
	var/prizeselect = pickweight(prizes)
	new prizeselect(src.loc)