/obj/machinery/computer/arcade/
	name = "random arcade"
	desc = "random arcade machine"
	icon = 'icons/obj/computer.dmi'
	icon_state = "arcade"
	var/list/prizes = list(	/obj/item/weapon/storage/box/snappops					= 2,
							/obj/item/toy/AI										= 2,
							/obj/item/clothing/under/syndicate/tacticool			= 2,
							/obj/item/toy/sword										= 2,
							/obj/item/toy/gun										= 2,
							/obj/item/weapon/gun/projectile/shotgun/toy/crossbow	= 2,
							/obj/item/weapon/storage/box/fakesyndiesuit				= 2,
							/obj/item/weapon/storage/fancy/crayons					= 2,
							/obj/item/toy/spinningtoy								= 2,
							/obj/item/toy/prize/ripley								= 1,
							/obj/item/toy/prize/fireripley							= 1,
							/obj/item/toy/prize/deathripley							= 1,
							/obj/item/toy/prize/gygax								= 1,
							/obj/item/toy/prize/durand								= 1,
							/obj/item/toy/prize/honk								= 1,
							/obj/item/toy/prize/marauder							= 1,
							/obj/item/toy/prize/seraph								= 1,
							/obj/item/toy/prize/mauler								= 1,
							/obj/item/toy/prize/odysseus							= 1,
							/obj/item/toy/prize/phazon								= 1,
							/obj/item/toy/prize/reticence							= 1,
							/obj/item/toy/cards/deck								= 2,
							/obj/item/toy/nuke										= 2,
							/obj/item/toy/minimeteor								= 2,
							/obj/item/toy/carpplushie								= 2,
							/obj/item/toy/foamblade									= 2,
							/obj/item/toy/redbutton									= 2,
							/obj/item/toy/owl										= 2,
							/obj/item/toy/griffin									= 2,
							/obj/item/weapon/coin/antagtoken						= 2,
							)

/obj/machinery/computer/arcade/New()
	..()
	// If it's a generic arcade machine, pick a random arcade
	// circuit board for it and make the new machine
	if(!circuit)
		var/choice = pick(typesof(/obj/item/weapon/circuitboard/arcade) - /obj/item/weapon/circuitboard/arcade)
		var/obj/item/weapon/circuitboard/CB = new choice()
		new CB.build_path(loc, CB)
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
	..()
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


/obj/machinery/computer/arcade/battle/emag_act(mob/user as mob)
	if(!emagged)
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
	..()
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
				if(emagged)
					user.nutrition = 0 //yeah you pretty hongry
					user << "<span class='userdanger'><font size=3>Your body instantly contracts to that of one who has not eaten in months. Agonizing cramps seize you as you fall to the floor.</span>"
			if(fuel <= 0)
				dat += "<br>You ran out of fuel, and drift, slowly, into a star."
				if(emagged)
					var/mob/living/M = user
					M.adjust_fire_stacks(5)
					M.IgniteMob() //flew into a star, so you're on fire
					user << "<span class='userdanger'><font size=3>You feel an immense wave of heat emanate from the arcade machine. Your skin bursts into flames.</span>"
		dat += "<br><P ALIGN=Right><a href='byond://?src=\ref[src];menu=1'>OK...</a></P>"

		if(emagged)
			user << "<span class='userdanger'><font size=3>You're never going to make it to Orion...</span></font>"
			user.death()
			emagged = 0 //removes the emagged status after you lose
			playing = 0 //also a new game
			name = "The Orion Trail"
			desc = "Learn how our ancestors got to Orion, and have fun in the process!"


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
		if(emagged)
			var/mob/living/carbon/M = usr //for some vars
			switch(event)
				if("Raiders")
					if(prob(50))
						usr << "<span class='userdanger'>You hear battle shouts. The tramping of boots on cold metal. Screams of agony. The rush of venting air. Are you going insane?</span>"
						M.hallucination += 30
					else
						usr << "<span class='userdanger'>Something strikes you from behind! It hurts like hell and feel like a blunt weapon, but nothing is there...</span>"
						M.take_organ_damage(30)
						playsound(loc, 'sound/weapons/genhit2.ogg', 100, 1)
				if("Illness")
					var/severity = rand(1,3) //pray to RNGesus. PRAY, PIGS
					if(severity == 1)
						M << "<span class='userdanger'>You suddenly feel slightly nauseous.</span>" //got off lucky
					if(severity == 2)
						usr << "<span class='userdanger'>You suddenly feel extremely nauseous and hunch over until it passes.</span>"
						M.Stun(3)
					if(severity >= 3) //you didn't pray hard enough
						M << "<span class='warning'>An overpowering wave of nausea consumes over you. You hunch over, your stomach's contents preparing for a spectacular exit.</span>"
						M.Stun(5)
						sleep(30)
						M.visible_message("<span class='warning'>[M] throws up!</span>", "<span class='userdanger'>You violently throw up!</span>")
						playsound(loc, 'sound/effects/splat.ogg', 50, 1)
						M.nutrition -= 50 //lose a lot of food
						var/turf/location = usr.loc
						if(istype(location, /turf/simulated))
							location.add_vomit_floor(src, 1)
				if("Interstellar Flux")
					if(prob(75))
						M.Weaken(3)
						M.visible_message("<span class='danger'>[M] is swept off their feet!</span>", "<span class='userdanger'>A sudden gust of powerful wind slams you into the floor!</span>")
						M.take_organ_damage(25)
						playsound(src.loc, 'sound/weapons/Genhit.ogg', 100, 1)
					else
						M << "<span class='userdanger'>A violent gale blows past you, and you barely manage to stay standing!</span>"
				if("Collision") //by far the most damaging event
					if(prob(90))
						playsound(src.loc, 'sound/effects/bang.ogg', 100, 1)
						var/turf/simulated/floor/F
						for(F in orange(1, src))
							F.ChangeTurf(F.baseturf)
						src.visible_message("<span class='userdanger'>Something slams into the floor around [src], exposing it to space!</span>")
						if(hull)
							sleep(10)
							src.visible_message("<span class='danger'>A new floor suddenly appears around [src]. What the hell?</span>")
							playsound(src.loc, 'sound/weapons/Genhit.ogg', 100, 1)
							var/turf/space/T
							for(T in orange(1, src))
								T.ChangeTurf(/turf/simulated/floor/plating/)
					else
						src.visible_message("<span class='danger'>Something slams into the floor around [src] - luckily, it didn't get through!</span>")
						playsound(src.loc, 'sound/effects/bang.ogg', 50, 1)
				if("Malfunction")
					playsound(src.loc, 'sound/effects/EMPulse.ogg', 50, 1)
					src.visible_message("<span class='danger'>[src] malfunctions, randomizing in-game stats!</span>")
					var/oldfood = food
					var/oldfuel = fuel
					food = rand(10,80) / rand(1,2)
					fuel = rand(10,60) / rand(1,2)
					if(electronics)
						sleep(10)
						if(oldfuel > fuel && oldfood > food)
							src.audible_message("<span class='danger'>[src] lets out a somehow reassuring chime.</span>")
						else if(oldfuel < fuel || oldfood < food)
							src.audible_message("<span class='danger'>[src] lets out a somehow ominous chime.</span>")
						food = oldfood
						fuel = oldfuel
						playsound(src.loc, 'sound/machines/chime.ogg', 50, 1)


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
			if(emagged) //has to be here because otherwise it doesn't work
				playsound(src.loc, 'sound/effects/supermatter.ogg', 100, 1)
				src.visible_message("<span class='userdanger'><font size=3>A miniature black hole suddenly appears in front of [src], devouring [usr] alive!</font></span>")
				usr.Stun(10) //you can't run :^)
				var/S = new /obj/singularity/academy(usr.loc)
				emagged = 0 //immediately removes emagged status so people can't kill themselves by sprinting up and interacting
				sleep(50)
				src.visible_message("<span class='userdanger'>[S] winks out, just as suddenly as it appeared.</span>")
				qdel(S)
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
	if(emagged)
		new /obj/item/weapon/orion_ship(src.loc)
		message_admins("[key_name_admin(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
		log_game("[key_name(usr)] made it to Orion on an emagged machine and got an explosive toy ship.")
	else
		prizevend()
	emagged = 0
	name = "The Orion Trail"
	desc = "Learn how our ancestors got to Orion, and have fun in the process!"

/obj/machinery/computer/arcade/orion_trail/emag_act(mob/user as mob)
	if(!emagged)
		user << "<span class='notice'>You override the cheat code menu and skip to Cheat #[rand(1, 50)]: Realism Mode.</span>"
		name = "The Orion Trail: Realism Edition"
		desc = "Learn how our ancestors got to Orion, and try not to die in the process!"
		newgame()
		emagged = 1

/obj/item/weapon/orion_ship
	name = "model settler ship"
	desc = "A model spaceship, it looks like those used back in the day when travelling to Orion! It even has a miniature FX-293 reactor, which was renowned for its instability and tendency to explode..."
	icon = 'icons/obj/toy.dmi'
	icon_state = "ship"
	w_class = 2
	var/active = 0 //if the ship is on

/obj/item/weapon/orion_ship/examine(mob/user)
	..()
	if(!(in_range(user, src)))
		return
	if(!active)
		user << "<span class='notice'>There's a little switch on the bottom. It's flipped down.</span>"
	else
		user << "<span class='notice'>There's a little switch on the bottom. It's flipped up.</span>"

/obj/item/weapon/orion_ship/attack_self(mob/user) //Minibomb-level explosion. Should probably be more because of how hard it is to survive the machine! Also, just over a 5-second fuse
	if(active)
		return

	message_admins("[key_name_admin(usr)] primed an explosive Orion ship for detonation.")
	log_game("[key_name(usr)] primed an explosive Orion ship for detonation.")

	user << "<span class='warning'>You flip the switch on the underside of [src].</span>"
	active = 1
	src.visible_message("<span class='notice'>[src] softly beeps and whirs to life!</span>")
	playsound(src.loc, 'sound/machines/defib_SaftyOn.ogg', 25, 1)
	say("This is ship ID #[rand(1,1000)] to Orion Port Authority. We're coming in for landing, over.")
	sleep(20)
	src.visible_message("<span class='warning'>[src] begins to vibrate...</span>")
	say("Uh, Port? Having some issues with our reactor, could you check it out? Over.")
	sleep(30)
	say("Oh, God! Code Eight! CODE EIGHT! IT'S GONNA BL-")
	playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 25, 1)
	sleep(3.6)
	src.visible_message("<span class='userdanger'>[src] explodes!</span>")
	explosion(src.loc, 1,2,4, flame_range = 3)
	qdel(src)
