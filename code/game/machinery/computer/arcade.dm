/obj/machinery/computer/arcade/
	name = "random arcade"
	desc = "random arcade machine"
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
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
							/obj/item/toy/prize/phazon						= 1,
							/obj/item/toy/cards/deck						= 2,
							/obj/item/toy/nuke								= 2
							)

/obj/machinery/computer/arcade/New()
	..()
	var/choice = pick(typesof(/obj/machinery/computer/arcade) - /obj/machinery/computer/arcade)
	new choice(loc)
	qdel(src)

/obj/machinery/computer/arcade/proc/prizevend()
	if(!contents.len)
		var/prizeselect = pickweight(prizes)
		new prizeselect(src.loc)

		if(istype(prizeselect, /obj/item/toy/gun)) //Ammo comes with the gun
			new /obj/item/toy/ammo/gun(src.loc)

		else if(istype(prizeselect, /obj/item/clothing/suit/syndicatefake)) //Helmet is part of the suit
			new	/obj/item/clothing/head/syndicatefake(src.loc)

	else
		var/atom/movable/prize = pick(contents)
		prize.loc = src.loc

/obj/machinery/computer/arcade/emp_act(severity)
	..(severity)

	if(stat & (NOPOWER|BROKEN))
		return

	var/empprize = null
	var/num_of_prizes = 0
	switch(severity)
		if(1)
			num_of_prizes = rand(1,4)
		if(2)
			num_of_prizes = rand(0,2)
	for(var/i = num_of_prizes; i > 0; i--)
		empprize = pickweight(prizes)
		new empprize(src.loc)
	explosion(src.loc, -1, 0, 1+num_of_prizes, flame_range = 1+num_of_prizes)


/obj/machinery/computer/arcade/battle
	name = "arcade machine"
	desc = "Does not support Pinball."
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	circuit = /obj/item/weapon/circuitboard/arcade/battle
	var/enemy_name = "Space Villian"
	var/temp = "Winners don't use space drugs" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = 0
	var/blocked = 0 //Player cannot attack/heal while set
	var/turtle = 0

/obj/machinery/computer/arcade/battle/New()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "slime", "Griefer", "ERPer", "Lizard Man", "Unicorn")

	src.enemy_name = replacetext((name_part1 + name_part2), "the ", "")
	src.name = (name_action + name_part1 + name_part2)

/obj/machinery/computer/arcade/battle/attack_hand(mob/user as mob)
	if(..())
		return
	user.set_machine(src)
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a>"
	dat += "<center><h4>[src.enemy_name]</h4></center>"

	dat += "<br><center><h3>[src.temp]</h3></center>"
	dat += "<br><center>Health: [src.player_hp] | Magic: [src.player_mp] | Enemy Health: [src.enemy_hp]</center>"

	if (src.gameover)
		dat += "<center><b><a href='byond://?src=\ref[src];newgame=1'>New Game</a>"
	else
		dat += "<center><b><a href='byond://?src=\ref[src];attack=1'>Attack</a> | "
		dat += "<a href='byond://?src=\ref[src];heal=1'>Heal</a> | "
		dat += "<a href='byond://?src=\ref[src];charge=1'>Recharge Power</a>"

	dat += "</b></center>"

	//user << browse(dat, "window=arcade")
	//onclose(user, "arcade")
	var/datum/browser/popup = new(user, "arcade", "Space Villian 2000")
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

/obj/machinery/computer/arcade/battle/Topic(href, href_list)
	if(..())
		return

	if (!src.blocked && !src.gameover)
		if (href_list["attack"])
			src.blocked = 1
			var/attackamt = rand(2,6)
			src.temp = "You attack for [attackamt] damage!"
			src.updateUsrDialog()
			if(turtle > 0)
				turtle--

			sleep(10)
			src.enemy_hp -= attackamt
			src.arcade_action()

		else if (href_list["heal"])
			src.blocked = 1
			var/pointamt = rand(1,3)
			var/healamt = rand(6,8)
			src.temp = "You use [pointamt] magic to heal for [healamt] damage!"
			src.updateUsrDialog()
			turtle++

			sleep(10)
			src.player_mp -= pointamt
			src.player_hp += healamt
			src.blocked = 1
			src.updateUsrDialog()
			src.arcade_action()

		else if (href_list["charge"])
			src.blocked = 1
			var/chargeamt = rand(4,7)
			src.temp = "You regain [chargeamt] points"
			src.player_mp += chargeamt
			if(turtle > 0)
				turtle--

			src.updateUsrDialog()
			sleep(10)
			src.arcade_action()

	if (href_list["close"])
		usr.unset_machine()
		usr << browse(null, "window=arcade")

	else if (href_list["newgame"]) //Reset everything
		temp = "New Round"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		turtle = 0

		if(emagged)
			src.New()
			emagged = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/arcade/battle/proc/arcade_action()
	if ((src.enemy_mp <= 0) || (src.enemy_hp <= 0))
		if(!gameover)
			src.gameover = 1
			src.temp = "[src.enemy_name] has fallen! Rejoice!"

			if(emagged)
				feedback_inc("arcade_win_emagged")
				new /obj/effect/spawner/newbomb/timer/syndicate(src.loc)
				new /obj/item/clothing/head/collectable/petehat(src.loc)
				message_admins("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded a bomb.")
				log_game("[key_name(usr)] has outbombed Cuban Pete and been awarded a bomb.")
				src.New()
				emagged = 0
			else
				feedback_inc("arcade_win_normal")
				prizevend()

	else if (emagged && (turtle >= 4))
		var/boomamt = rand(5,10)
		src.temp = "[src.enemy_name] throws a bomb, exploding you for [boomamt] damage!"
		src.player_hp -= boomamt

	else if ((src.enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		src.temp = "[src.enemy_name] steals [stealamt] of your power!"
		src.player_mp -= stealamt
		src.updateUsrDialog()

		if (src.player_mp <= 0)
			src.gameover = 1
			sleep(10)
			src.temp = "You have been drained! GAME OVER"
			if(emagged)
				feedback_inc("arcade_loss_mana_emagged")
				usr.gib()
			else
				feedback_inc("arcade_loss_mana_normal")

	else if ((src.enemy_hp <= 10) && (src.enemy_mp > 4))
		src.temp = "[src.enemy_name] heals for 4 health!"
		src.enemy_hp += 4
		src.enemy_mp -= 4

	else
		var/attackamt = rand(3,6)
		src.temp = "[src.enemy_name] attacks for [attackamt] damage!"
		src.player_hp -= attackamt

	if ((src.player_mp <= 0) || (src.player_hp <= 0))
		src.gameover = 1
		src.temp = "You have been crushed! GAME OVER"
		if(emagged)
			feedback_inc("arcade_loss_hp_emagged")
			usr.gib()
		else
			feedback_inc("arcade_loss_hp_normal")

	src.blocked = 0
	return


/obj/machinery/computer/arcade/battle/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		temp = "If you die in the game, you die for real!"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		blocked = 0

		emagged = 1

		enemy_name = "Cuban Pete"
		name = "Outbomb Cuban Pete"


		src.updateUsrDialog()
	else
		..()
	return





/obj/machinery/computer/arcade/orion_trail
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	circuit = /obj/item/weapon/circuitboard/arcade/orion_trail
	var/engine = 0
	var/hull = 0
	var/electronics = 0
	var/food = 80
	var/fuel = 60
	var/turns = 4
	var/playing = 0
	var/gameover = 0
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
	var/list/stops = list()
	var/list/stopblurbs = list()

/obj/machinery/computer/arcade/orion_trail/New()
	// Sets up the main trail
	stops = list("Pluto","Asteroid Belt","Proxima Centauri","Dead Space","Rigel Prime","Tau Ceti Beta","Black Hole","Space Outpost Beta-9","Orion Prime")
	stopblurbs = list(
		"Pluto, long since occupied with long-range sensors and scanners, stands ready to, and indeed continues to probe the far reaches of the galaxy.",
		"At the edge of the Sol system lies a treacherous asteroid belt. Many have been crushed by stray asteroids and misguided judgement.",
		"The nearest star system to Sol, in ages past it stood as a reminder of the boundaries of sub-light travel, now a low-population sanctuary for adventurers and traders.",
		"This region of space is particularly devoid of matter. Such low-density pockets are known to exist, but the vastness of it is astounding.",
		"Rigel Prime, the center of the Rigel system, burns hot, basking its planetary bodies in warmth and radiation.",
		"Tau Ceti Beta has recently become a waypoint for colonists headed towards Orion. There are many ships and makeshift stations in the vicinity.",
		"Sensors indicate that a black hole's gravitational field is affecting the region of space we were headed through. We could stay of course, but risk of being overcome by its gravity, or we could change course to go around, which will take longer.",
		"You have come into range of the first man-made structure in this region of space. It has been constructed not by travellers from Sol, but by colonists from Orion. It stands as a monument to the colonists' success.",
		"You have made it to Orion! Congratulations! Your crew is one of the few to start a new foothold for mankind!"
		)

/obj/machinery/computer/arcade/orion_trail/proc/newgame()
	// Set names of settlers in crew
	settlers = list()
	var/choice = null
	for(var/i = 1; i <= 3; i++)
		if(prob(50))
			choice = pick(first_names_male)
		else
			choice = pick(first_names_female)
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

/obj/machinery/computer/arcade/orion_trail/attack_hand(mob/user as mob)
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
		if(settlers.len == 0)
			dat += "<br>Your entire crew died, your ship joins the fleet of ghost-ships littering the galaxy."
		else
			if(food <= 0)
				dat += "<br>You ran out of food and starved."
			if(fuel <= 0)
				dat += "<br>You ran out of fuel, and drift, slowly, into a star."
		dat += "<br><P ALIGN=Right><a href='byond://?src=\ref[src];menu=1'>OK...</a></P>"
	else if(event)
		dat = eventdat
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

/obj/machinery/computer/arcade/orion_trail/Topic(href, href_list)
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
			turns += 1
	else if(href_list["holedeath"])
		gameover = 1
		event = null
	else if(href_list["eventclose"]) //end an event
		event = null

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return


/obj/machinery/computer/arcade/orion_trail/proc/event()
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
		eventdat += "<br>You can repair it with an engine part, or you can make repairs for 3 days."
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
		settlers = list()


/obj/machinery/computer/arcade/orion_trail/proc/win()
	playing = 0
	prizevend()


/obj/machinery/computer/arcade/prison
	name = "Prison Simulator 2554"
	desc = "What happens to those who break Space Law? Today we will find out. This is a true story."
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	circuit = /obj/item/weapon/circuitboard/arcade// /prison
	var/playing = 0
	var/dat = ""
	var/money = 0
	var/username = "Dangerous Criminal"
	//stats
	var/health = 0
	var/strength = 0
	var/intelligence = 0
	//relationship with
	var/authorities = 0
	var/inmates = 0
	var/security = 0
	var/weekday = "Monday" //Can be Monday through Sunday, they don't correspond to real calendar, the game always starts at Monday
	var/current_date = null //In-game date (which is current date + 540 years basically)
	var/days_since = 0
	var/term = 0
	var/cockroach_speed //how fast is your cockroach (in meters per hour)
	var/race_speed = 0 //How fast can cockroaches run until death (in meters per hour)
	var/food_pricelist = list(0, 15, 40, 150, 800)
	var/fights = 0
	var/stoolie = 0
	var/sap = 0
	var/content = "" //For proper popup update

/obj/machinery/computer/arcade/prison/attack_hand(mob/user as mob)
	if(..())
		return
	if(!playing)
		username = scan_user(user)
	src.add_fingerprint(user)
	var/datum/browser/popup = new(user, "arcade", "Prison Simulator")
	popup.set_content(src.content)
	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()
	return

//Modified /obj/machinery/newscaster/proc/scan_user(), credits to whoever coded that
/obj/machinery/computer/arcade/prison/proc/scan_user(mob/living/user as mob)
	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/human_user = user
		if(human_user.wear_id)
			if(istype(human_user.wear_id, /obj/item/device/pda))
				var/obj/item/device/pda/P = human_user.wear_id
				if(P.id)
					return P.id.registered_name
			else if(istype(human_user.wear_id, /obj/item/weapon/card/id) )
				var/obj/item/weapon/card/id/ID = human_user.wear_id
				return ID.registered_name
	else if(istype(user,/mob/living/silicon))
		var/mob/living/silicon/ai_user = user
		return ai_user.name
	return "Dangerous Criminal"

/obj/machinery/computer/arcade/prison/attackby(obj/item/W as obj, mob/user as mob)
	..()
	if(!(stat & (NOPOWER | BROKEN)))
		if(istype(W, /obj/item/weapon/spacecash))
			user.drop_item()
			user << "<span class='warning'>[src] devours space cash.</span>"
			if(istype(W, /obj/item/weapon/spacecash/c10))
				money += 10
			else if (istype(W, /obj/item/weapon/spacecash/c20))
				money += 20
			else if (istype(W, /obj/item/weapon/spacecash/c50))
				money += 50
			else if (istype(W, /obj/item/weapon/spacecash/c100))
				money += 100
			else if (istype(W, /obj/item/weapon/spacecash/c200))
				money += 200
			else if (istype(W, /obj/item/weapon/spacecash/c500))
				money += 500
			else if (istype(W, /obj/item/weapon/spacecash/c1000))
				money += 1000
			qdel(W)
			update()

/obj/machinery/computer/arcade/prison/proc/update()
	content = dat + stats()
	src.updateUsrDialog()


/obj/machinery/computer/arcade/prison/proc/stat_change(var/value, var/changeby)
	if (changeby > 0)
		value = min(100, value + changeby)
	else if (changeby < 0)
		value = max(0, value + changeby)
	return value

/obj/machinery/computer/arcade/prison/proc/stats()
	var/temp = ""
	if (playing)
		temp += "<hr><h3><b>Statistics:</b></h3>"
		switch (health)
			if (0 to 10) temp += "You are almost dead"
			if (11 to 20) temp += "You are feeling awful"
			if (21 to 30) temp += "Your whole body is aching"
			if (31 to 40) temp += "You are not feeling well"
			if (41 to 50) temp += "Your health is worse than average"
			if (51 to 60) temp += "Could feel better, could feel worse"
			if (61 to 70) temp += "You are feeling good"
			if (71 to 80) temp += "You are feeling great"
			if (81 to 90) temp += "You are feeling super<"
			if (91 to 100) temp += "You've never felt better<"
		temp += "<br>"
		switch (strength)
			if (0 to 10) temp += "The weakest guy in the cell!"
			if (11 to 20) temp += "You are peaked"
			if (21 to 30) temp += "You are a weakling"
			if (31 to 40) temp += "You are of average strength"
			if (41 to 50) temp += "You are rather strong"
			if (51 to 60) temp += "You are very strong"
			if (61 to 70) temp += "You are nearly a tough guy"
			if (71 to 80) temp += "You are a tough guy"
			if (81 to 90) temp += "You are one huge guy"
			if (91 to 100) temp += "You are a true gorilla!"
		temp += "<br>"
		switch (intelligence)
			if (0 to 10) temp += "Moron"
			if (11 to 20) temp += "You are an idiot"
			if (21 to 30) temp += "You are a fool"
			if (31 to 40) temp += "You are not very clever"
			if (41 to 50) temp += "Your intellect is average"
			if (51 to 60) temp += "You are clever"
			if (61 to 70) temp += "You are very clever"
			if (71 to 80) temp += "You are one big brain"
			if (81 to 90) temp += "You are the smartest guy in the cell"
			if (91 to 100) temp += "You are the smartest guy in jail"
		temp += "<br>"
		switch (authorities)
			if (0 to 10) temp += "Rotten scoundrel"
			if (11 to 20) temp += "Scoundrel"
			if (21 to 30) temp += "Bad inmate"
			if (31 to 40) temp += "Low and worthless type"
			if (41 to 50) temp += "Average Joe"
			if (51 to 60) temp += "You are on the right path"
			if (61 to 70) temp += "You are turning over a new leaf"
			if (71 to 80) temp += "Good inmate"
			if (81 to 90) temp += "Role model of an inmate"
			if (91 to 100) temp += "The release papers are being processed"
		temp += "<br>"
		switch (security)
			if (0 to 10) temp += "Security guards hate you"
			if (11 to 20) temp += "Security guards despise you"
			if (21 to 30) temp += "Security treats you suspiciously"
			if (31 to 40) temp += "Security guards do not like you very much"
			if (41 to 50) temp += "Security's attitude to you is cold"
			if (51 to 60) temp += "Security's attitude to you is neutral"
			if (61 to 70) temp += "Security's attitude to you is good"
			if (71 to 80) temp += "Some of the security guards are your buddies"
			if (81 to 90) temp += "You have best friends amongst security"
			if (91 to 100) temp += "HoS is your best friend"
		temp += "<br>"
		switch (inmates)
			if (0 to 10) temp += "Other inmates are ready to kill you"
			if (11 to 20) temp += "You are a downcast"
			if (21 to 30) temp += "You are a punk"
			if (31 to 40) temp += "Other inmates despise you"
			if (41 to 50) temp += "The inmates are neutral to you"
			if (51 to 60) temp += "You are an OK chap"
			if (61 to 70) temp += "The inmates respect you"
			if (71 to 80) temp += "You are a respected criminal"
			if (81 to 90) temp += "You are a local criminal authority"
			if (91 to 100) temp += "You are a Don"
		temp += "<br>"
		if (stoolie) temp += "You are a stoolie.<br>"
		if (sap) temp += "Sap length: [sap]<br>"
		if (fights) temp += "Fights held: [fights]<br>"
		if (cockroach_speed) temp += "Cockroach runs at [cockroach_speed] m/h<br>"
		temp += "<h4>Your belongings</h4>"
		temp += "Money: [money] space cash<br>"
	return temp

/obj/machinery/computer/arcade/prison/New()
	newgame()
	content = dat

/obj/machinery/computer/arcade/proc/determine_work()
	switch (security)
		if ()

/obj/machinery/computer/arcade/prison/Topic(href, href_list[])
	dat = ""
	switch (href_list["location"])
		if("blindman")
			dat += pick("<p> - They say that fools are always lucky, but I wouldn't believe it if I were you. Gambling is not about luck, it's about intelligence!</p>",
						"<p> - Cockroach races are a traditional entertainment for the inmates, the most popular one after fist-fights. Usually the races are organized on Saturdays, though there are some unplanned runs. The cockroach owners field their runners and others simply put stakes. A good runner is hard to breed, and the owners of six-legged champions are respected amongst the inmates. That is not to mention the prize fund of 500 credits...</p>",
						"<p> - Good food will improve your health, but you won't achieve much just by eating well! The food in canteen is of good quality and is not too expensive, but keep in mind that your cellmates may grow envious of you because of your trips to canteen...</p>",
						"<p> - The word around the campus is that this prison is not as sound as it used to be. They say that one guy had dug up a tunnel and ran off. Oh yes, and I bet you he would have never been able to dig that tunnel if he hadn't been that strong.</p>",
						"<p> - On Sundays prison authorities become nice and kind lot and would even read the petitions for reprieve written by the inmates. However, you have to use your brain when writing the petition! Besides, guards may simply 'lose' it on the way to warden if they don't like you much.</p>",
						"<p> - Only the strongest and the most reputable can racket anyone they want. In fact, anyone can try it, but there's no safety guarantee, you know.</p>",
						"<p> - The jail gym has excellent equipment and you can build yourself some serious muscle by working out there. Keep in mind that regulars there don't like outcasts and could beat them up if they show up in the gym. Then again, it's not a problem for a big tough guy.</p>",
						"<p> - A cellmate once told me that a regular cockroach can develop a speed of [race_speed] m/h. If you try to make it run faster, the result may be fatal...</p>",
						"<p> - If you don't want to do any hard work, make friends with guards, for they are the once distributing the work. And remember that by doing hard work you lose reputation with other inmates!</p>",
						"<p> - Try not to lose your cellmates' respect! They do not like those who work and try to gain goodwill of the prison authorities, but they respect those who have lots of tats and those who gamble all the time. They hate snithes and the guards would often carry out of the cell those who upset their cellmates...</p>",
						"<p> - They say that a fist-fighting champion was released solely for his ring achievements - the warden really likes that kind of entertainment. But to become a champion you must be strong and experienced fighter...</p>")
			dat += "<br>"
			money -= 5 //This is impossible to reach unless you have the money
			if (money >= 5)
				dat += "<br><a href='byond://?src=\ref[src];location=blindman'>Give 5 space credits to the blind man</a>"
			dat += "<br><a href='byond://?src=\ref[src];location=Cell'>Head back to your cell</a>"
		if ("Cell")
//			if (href_list["event"])
//							event("Cell")
			switch (weekday)
				if ("Monday")
					dat += "<p> - Monday, get to work! - yells the guard.</p><p>Some of the inmates go to work, while the rest are trying to talk themselves out of it by pretending to be sick and exhausted. You can hear the banging of dice from the corner of the cell. In other corner somebody is playing cards. May be you should try your luck as well?</p>"
					dat += "<p>It's been [days_since] day[days_since == 1 ? "" : "s"] since your arrival, [term - days_since] until release.</p>"
					dat += "<br><a href='byond://?src=\ref[src];location=Canteen'>Go to canteen</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Work'>Go to work</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Gambling'>Gamble</a>"
					weekday = "Tuesday"
				if ("Tuesday")
					dat += "<p>Tuesday, an ordinary day in jail. You have been sitting here for [days_since] days already and you will spend here another [term - days_since]. Today the library and the gym are open. It's the choice between muscle and knowledge. Or else, you could go to work and thus get an approval from the prison authorities.</p>"
					dat += "<br><a href='byond://?src=\ref[src];location=Canteen'>Go to canteen</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Work'>Go to work</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Gym'>Go to the gym</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Library'>Go to the library</a>"
					weekday = "Wednesday"
				if ("Wednesday")
					dat += "<p>Today is Wednesday, a working day. You've spent [days_since] days in and it's [term - days_since] days before you're let out. Part of the prisoners already left to work, but a handful of the toughest ones is shuffling a deck of cards. Maybe you should join them?</p>"
					dat += "<br><a href='byond://?src=\ref[src];location=Canteen'>Go to canteen</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Work'>Go to work</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Gambling'>Gamble</a>"
					weekday = "Thursday"
				if ("Thursday")
					dat += "<p>Today is Thursday, [days_since] days in prison, [term - days_since] days left. The weather is beautiful and both the library and gym are open. Somehow nobody's gambling.</p>"
					dat += "<br><a href='byond://?src=\ref[src];location=Canteen'>Go to canteen</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Work'>Go to work</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Gym'>Go to the gym</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Library'>Go to the library</a>"
					weekday = "Friday"
				if ("Friday")
					dat += "<p>Friday, the favourite day of the week. Weekend is coming and this is the last working day. The majority left to work, but you see some of them are playing cards. May be you should join them?<br>[days_since] days passed since your arrival, [term - days_since] days left.</p><p>The doctor's office is open and everyone who needs medical attention may go there and receive it.</p>"
					dat += "<br><a href='byond://?src=\ref[src];location=Canteen'>Go to canteen</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Work'>Go to work</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Gambling'>Gamble</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Medbay'>Go to medical bay</a>"
					weekday = "Saturday"
				if ("Saturday")
					dat += "<p>Today is Saturday, day-off. [days_since] days behind the bars, and you still have to spend [term - days_since] days here. Everyone is chilling out, the gym is closed, there's no work to do, and only library has its doors wide open.<br>Also today is the traditional day for cockroach races. A must for all insect fans.</p>"
					dat += "<br><a href='byond://?src=\ref[src];location=Canteen'>Go to canteen</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Gambling'>Gamble</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Library'>Go to the library</a>"
					weekday = "Sunday"
				if ("Sunday")
					dat += "<p>Today is Sunday, the day of denunciation. This is the day when head of security is expecting messages from his informers. This is also the day when all guards go ballistic and wouldn't let inmates gamble.<br>[days_since] days passed since the last term, [term - days_since] days to release.</p>"
					dat += "<br><a href='byond://?src=\ref[src];location=Snitch'>Call the guard and tell him I'd like to speak to Head of Security</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Amnesty'>Write an amnesty petition</a>"
					dat += "<br><a href='byond://?src=\ref[src];location=Bribe'>Donate 500 credits to the prison needs</a>"
					weekday = "Monday"
			if (prob(5) || weekday == "Sunday")
				dat += "<br><a href='byond://?src=\ref[src];location=Race'>Today is the day of the cockroach races - go there, quick</a>"
			days_since++
		if ("Canteen")
			switch (href_list["meal"])
				if("1")
					money -= food_pricelist[1]
					health = stat_change(health,rand(7,12))
					dat += "The skilly is as disgusting as only a skilly can be. You eat, rest and feel a little better.<br>"
				if("2")
					money -= food_pricelist[2]
					health = stat_change(health,rand(15,25))
					dat += "Today you feast like a real man! Lots of nutritious food, meat, vegetables and all that - dirt cheap.<br>"
					if (inmates < 70)
						inmates = stat_change(inmates, rand(25,35))
						dat += "Nonetheless, other inmates do not look kindly upon you. You order yourself OG dinner, but you're not really an original gangsta!<br>"
				if("3")
					money -= food_pricelist[3]
					if (fights)
						health = stat_change(health,rand(30,40))
					else
						health = stat_change(health,rand(-30,-50))
						dat += "No one expected such an impudence from you. You never went to the ring! By ordering 'champ dinner' you insult other fighters who are now busy making sure you will know better from now on. Using their fists. And pieces of furniture. Guards interfere and save you from certain death, drag you back to the cell and leave you on the cot. Other inmates eye you suspiciously not knowing what to expect from such.<br>"
				if("4")
					money -= food_pricelist[4]
					dat += " - This is a token of gratitude to our honourable security officers on guard of prison's peace, - you say, half-mocking, and dishes start appearing on guard's table. These guys would never be able to afford this on their salaries. Without further ado they hawk down at what cooks have brought - fresh bread, juicy meat, appetizers, even some wine! The guards aren't supposed to drink on duty, but what the heck, it's a free meal. They will certainly treat you a lot better, however other inmates do not appreciate what you're doing. Nor do prison authorities, so chances are this is the last time you are able to do this.<br>"
				if("5")
					money -= food_pricelist[5]
					inmates = stat_change(inmates,rand(55,65))
					security = stat_change(security,rand(-15,-25))
					authorities = stat_change(authorities,rand(-15,-25))
					dat += "There is a huge bash. Everyone is having fun and eating for free. You instantly become respected among all inmates like a true OG. The guards watch the party suspiciously and report it to the authorities. The authorities do not really appreciate this act of generosity either.<br>"
				else
					dat += "Now you have to figure out what to order. The jail menu is as follows:<br>1. You can eat for absolutely free. A standard portion of skilly is available to anyone.<br>2. Pay [food_pricelist[2]] credits and ask for an 'original gangster portion'.<br>3. Pay [food_pricelist[3]] credits for a 'champion's dinner'<br>4. Treat the tired guards on the entrance for [food_pricelist[4]] credits.<br>5. Treat everyone present for [food_pricelist[5]] credits.<br>"
					if (money >= food_pricelist[1])
						dat += "<br><a href='byond://?src=\ref[src];location=Canteen;meal=1'>Take a free set</a>"
					if (money >= food_pricelist[2])
						dat += "<br><a href='byond://?src=\ref[src];location=Canteen;meal=2'>Pay [food_pricelist[2]] credits and get an 'OG portion'</a>"
					if (money >= food_pricelist[3])
						dat += "<br><a href='byond://?src=\ref[src];location=Canteen;meal=3'>Pay [food_pricelist[3]] credits for a 'champ dinner'</a>"
					if (money >= food_pricelist[4])
						dat += "<br><a href='byond://?src=\ref[src];location=Canteen;meal=4'>Treat the tired guards on the entrance - [food_pricelist[4]] credits!</a>"
					if (money >= food_pricelist[5])
						dat += "<br><a href='byond://?src=\ref[src];location=Canteen;meal=5'>Let's throw a party! Treat everyone, after all, it's only [food_pricelist[5]] credits!</a>"
			dat += "<br><a href='byond://?src=\ref[src];location=Cell'>Go back to the cell</a>"
		if ("Gym")
			if (prob(max(0,intelligence - 50)))
				dat += "<p>A couple of guys approach you when you enter.</p><p> - Go back to the library, [username], we don't like eggheads here!</p><p>With those words they stuff you into a closet and lock it. You spend the rest of the day getting out of it.</p>"
			else
				dat += "<p>You do some training and develop a bit of muscle. Your strength is growing.</p>"
				strength += rand(5,15)
				if (prob(40))
					dat += "<p>Closer to the end of the training you overdo it and drop a weight on your foot. It hurts quite a bit.</p>"
					health = stat_change(health,-10)
			dat += "<br><a href='byond://?src=\ref[src];location=Cell'>Continue</a>"
		if ("Library")
			if (href_list["cockroach"])
				switch (href_list["cockroach"])
					if ("start")
						dat += "Then all of a sudden a small and quick cockroach runs out right onto the manuscript. You try to blow it off, so that to not soil the pages, but the cockroach has all its six legs planted firmly on the paper, thus demonstrating its enormous stubbornness in combination with love for knowledge."
						dat += "<br><a href='byond://?src=\ref[src];location=Library;cockroach=throwaway'>Throw manuscript away in disgust</a>"
						dat += "<br><a href='byond://?src=\ref[src];location=Library;cockroach=take'>Take a cockroach</a>"
					if ("throaway")
						dat += "The librarian notices what you do and reads you a notation about proper behaviour in the library. In the end, as a punishment, he makes you put all books in order while other inmates can leave them wherever they want."
						dat += "<br><a href='byond://?src=\ref[src];location=Cell'>Continue</a>"
					if ("take")
						dat += "You like its will for victory and decide to make a real cockroach race champion out of it. You take it carefully and place it in a matchbox."
						cockroach_speed = rand(1,15)
						dat += "<br><a href='byond://?src=\ref[src];location=Cell'>Continue</a>"
			else if (href_list["exit"])
				dat += "<p>At the exit you run into a guy with the hat in front of him.</p><p> - Give five credits to a blind man and he will give you some advise!</p>"
				if (money >= 5)
					dat += "<br><a href='byond://?src=\ref[src];location=blindman'>Give 5 space credits to the blind man</a>"
				dat += "<br><a href='byond://?src=\ref[src];location=Cell'>Head back to your cell</a>"
			else
				var/rng = pick(prob(20); "monkey",
							prob(50); "romantic",
							"warandpeace",
							"belletristic",
							"encyclopaedia",
							"scientific",
							"spesslaw",
							"comics",
							prob(cockroach_speed ? 0 : 10); "cockroach")
				switch (rng)
					if ("monkey")
						dat += "<p>Today you run into a very exotic book called \"Teach Yourself to Speak Monkey\" by R. McAllister. You study it for three hours and finally manage to perfectly pronounce the phrase: 'Ahoo mahookah hee [username]!'</p><p>Your linguistic capabilities make a very good impression on everyone.</p>"
						authorities = stat_change(authorities, rand(20,30))
						security = stat_change(security, rand(20.30))
						inmates = stat_change(inmates, rand(20,30))
					if ("romantic")
						dat += "You decide to read some romantic fiction intended for housewives. After three hours of intense reading you become a lot more stupid. Authorities appreciate your effort, but your reputation among guards and cellmates drops."
						intelligence = stat_change(intelligence, rand(-10,-20))
						authorities = stat_change(authorities, rand(15, 20))
						security = stat_change(security, rand(-5,-15))
						inmates = stat_change(inmates, rand(-15,-25))
					if ("warandpeace")
						dat+= "You sit down and read a very ancient novel called \"War and Peace\". Unfortunately you fall asleep on page 20. Authorities do not like it, but you have a good rest and restore your strength."
						health = stat_change(health, rand(20,30))
						authorities = stat_change(authorities, rand(-10,-15))
					if ("belletristic")
						dat += "You decide to get some belletristic reading. Firstly, it won't be so boring, secondly, the prison authorities will like it. The interesting reading has a positive effect on your overall condition, but your reputation among guards and other inmates goes down."
						health = stat_change(health, rand(15,25))
						authorities = stat_change(authorities, rand(10, 15))
						security = stat_change(security, rand(-5,-15))
						inmates = stat_change(inmates, rand(-15,-25))
					if ("encyclopaedia")
						dat += "Today you take one of the volumes of Big Galactic Encyclopaedia and start reading about all sorts of random things. You learn a great deal of new things, but you suffer from a headache at the evening. Prison authorities are pleased with you, but other inmates think you are an egghead."
						intelligence = stat_change(intelligence, rand(15, 30))
						health = stat_change(health, rand(-5, -15))
						authorities = stat_change(authorities, rand(10,15))
						inmates = stat_change(inmates, rand(-15,-25))
					if ("scientific")
						dat += "Today you start reading scientific literature hoping that this will make the best impression on prison authorities. It does, but other inmates are calling you an egghead and you lose reputation. Besides, the font in these books was too small and at the end of the day your eyes ache. On the bright side, you feel considerably more intelligent than before."
						intelligence = stat_change(intelligence, rand(20, 25))
						health = stat_change(health, rand(-5, -15))
						authorities = stat_change(authorities, rand(15,20))
						inmates = stat_change(inmates, rand(-15,-25))
					if ("spesslaw")
						dat += "You take a book called \"Space Law For Dummies\", thinking that authorities will like it. They sure do, but other inmates start giving you the looks."
						authorities = stat_change(authorities, 20)
						inmates = stat_change(inmates, rand(-10,-30))
					if ("comics")
						dat += "You stuck to comic books. Not really a smart reading, but you have yourself a good laugh and are feeling much better."
						health = stat_change(health, rand(5, 15))
						intelligence = stat_change(intelligence, rand(-1,-5))
					if ("cockroach")
						dat += "You come into the library and start digging in the old books hoping to find something useful here. Finally you run into an old manuscript, or rather a copy of thereof, and start browsing through the pictures, since you cannot read the old tongue the manuscript has been written on."
						dat += "<br><a href='byond://?src=\ref[src];location=Library;cockroach=start'>Keep reading</a>"
				dat += "<br><a href='byond://?src=\ref[src];location=Library;exit=1'>Go back to your cell</a>"
		if ("Work")

		else
			switch (href_list["newgame"]) //all of the starting texts
				if ("newgame0")
					playing = 1
					dat += "<p>Soon the shuttle reaches its destination. The warden himself comes to greet new inmates in arrivals.</p><p> - NanoTrasen Rehabilitation Facility #3 is a place where each of you who chose the path of crime can once again become a good citizen, demonstrating your best personal qualities, such as love for good literature and hard work. All your actions will be evaluated and each who has a good conduct record shall be rehabilitated and released on parole.On the other hand, gamblers, parasites and other criminal elements will stay here until the end of their term.</p><br>"
					dat += "<br><a href='byond://?src=\ref[src];newgame=newgame1'>Submit your belongings and go to your cell</a>"
				if ("newgame1")
					dat += "<p>A librarian greets you with a happy smile. You can tell that the library is not the most popular place in prison, which is not really surprising.</p><p> - Ah, convict [username]! A very good move. Come here often and read a lot. Those who do usually are the first to step on the right path. Let me remind you of few rules that will help you survive here. The library works on Tuesdays, Thursdays and Saturdays. Monday through Friday are workdays. All of this gives you a chance to be released on parole. On Tuesdays and Thursdays the gym is also open, which will allow you to keep yourself in good shape. In order to increase your reputation you can allow yourself an occasional gamble.</p>"
					dat += "<br><a href='byond://?src=\ref[src];location=Library;exit=1'>Thank you, I will come here more often</a>"
	src.add_fingerprint(usr)
	update()

///obj/machinery/computer/arcade/prison/proc/event(var/location)
//	switch (location)
//		if ("Cell")

/obj/machinery/computer/arcade/prison/proc/newgame()
	playing = 0
	dat = "<center><b>Prison Simulator</b></center><br><center><b><a href='byond://?src=\ref[src];newgame=newgame0'>New Game</a></b></center>"
	current_date = "[time2text(world.realtime, "DD Month")] [year_integer+540]"
	weekday = "Monday"
	days_since = 1
	term = rand(70, 100)
	health = 70
	strength = 50
	intelligence = 50
	authorities = 50
	security = 50
	inmates = 50
	fights = 0
	stoolie = 0
	sap = 0
	cockroach_speed = 0