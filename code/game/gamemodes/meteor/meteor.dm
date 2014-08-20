/datum/game_mode/meteor
	name = "meteor"
	config_tag = "meteor"
	var/const/waittime_l = 600 //Lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //Upper bound on time before intercept arrives (in tenths of seconds)
	var/const/meteorannouncedelay = 9000 //Time before a special intercept tells the station to prepare (aka reveal). Now 15 minutes
	var/const/supplydelay = 100 //Delay before meteor supplies are spawned in tenth of seconds. Anyone in the way will be GIBBED
	var/const/meteordelay = 3000 //Supplementary time before the dakka commences, here 5 minutes
	var/nometeors = 1 //Can we send the meteors ?
	required_players = 0

	uplink_welcome = "EVIL METEOR Uplink Console:"
	uplink_uses = 10

/datum/game_mode/meteor/announce()
	world << "<B>The current game mode is - Meteor!</B>"
	world << "<B>The space station has been stuck in a major meteor shower. You must escape from the station or at least live.</B>"

/datum/game_mode/meteor/post_setup()
	defer_powernet_rebuild = 2//Might help with the lag
	spawn(0)
	spawn(rand(waittime_l, waittime_h))
		send_intercept()

	spawn(meteorannouncedelay)
		command_alert("A meteor storm has been detected in proximity of [station_name()] and is expected to strike in [round((meteordelay)/600)] minutes. A backup emergency shuttle is being set and emergency gear should be teleported into your station's Bar area in [(supplydelay)/10] seconds. Make good use of these supplies to build a safe zone and good luck.", "Space Weather Automated Announcements")
		for(var/obj/item/weapon/rcd/rcd in world) //No, you're not walling in everything
			rcd.disabled = 1
		for(var/obj/item/mecha_parts/mecha_equipment/tool/rcd/rcd in world)
			rcd.disabled = 1
		spawn(100) //Panic interval
		emergency_shuttle.incall(2.5)
		captain_announce("A backup emergency shuttle has been called. It will arrive in [round(emergency_shuttle.timeleft()/60)] minutes.")
		world << sound('sound/AI/shuttlecalled.ogg')

		spawn(supplydelay)
			//for(var/obj/effect/landmark/C in landmarks_list) //Time to get those supplies going, begin fuck huge free supply list
			var/obj/effect/landmark/woodkit = locate("landmark*meteorsupplywoodkit")
			var/obj/effect/landmark/woodkit2 = locate("landmark*meteorsupplywoodkit2") //Lazy man's way of unfucking shit
			var/obj/effect/landmark/bombkit = locate("landmark*meteorsupplybombkit")
			var/obj/effect/landmark/bombkit2 = locate("landmark*meteorsupplybombkit2")
			var/obj/effect/landmark/bombkit3 = locate("landmark*meteorsupplybombkit3")
			var/obj/effect/landmark/buildkit = locate("landmark*meteorsupplybuildkit")
			var/obj/effect/landmark/pizzakit = locate("landmark*meteorsupplypizzakit")
			var/obj/effect/landmark/panickit = locate("landmark*meteorsupplypanickit")
			var/obj/effect/landmark/shieldkit = locate("landmark*meteorsupplyshieldkit")
			//Barricading hallways
			for(var/atom/A in get_turf(woodkit)) //Until I find a better idea, I'll just slap it here
				if(istype(A,/mob/living))
					var/mob/living/unlucky_person = A
					unlucky_person.gib() //We told you to get the fuck out of here
				if(istype(A,/obj) || istype(A,/turf/simulated/wall)) //We're going to do it very simply. There should NOT be things in the way, and if they are we want them out
					qdel(A) //Telegib
				break
			spawn(1)
			playsound(get_turf(woodkit), 'sound/effects/sparks1.ogg', 50, 1)
			new /obj/structure/rack(woodkit.loc)
			new /obj/item/stack/sheet/wood(woodkit.loc, 10)
			new /obj/item/stack/sheet/wood(woodkit.loc, 10)
			new /obj/item/stack/sheet/wood(woodkit.loc, 10)
			for(var/atom/A in get_turf(woodkit2))
				if(istype(A,/mob/living))
					var/mob/living/unlucky_person = A
					unlucky_person.gib()
				if(istype(A,/obj) || istype(A,/turf/simulated/wall))
					qdel(A) //Telegib
				break
			spawn(1)
			playsound(get_turf(woodkit2), 'sound/effects/sparks1.ogg', 50, 1)
			new /obj/structure/rack(woodkit2.loc)
			new /obj/item/stack/sheet/wood(woodkit2.loc, 10)
			new /obj/item/stack/sheet/wood(woodkit2.loc, 10)
			new /obj/item/stack/sheet/wood(woodkit2.loc, 10)
			//Very useful, I swear. Acts as discount EVA otherwise
			for(var/atom/A in get_turf(bombkit))
				if(istype(A,/mob/living))
					var/mob/living/unlucky_person = A
					unlucky_person.gib()
				if(istype(A,/obj) || istype(A,/turf/simulated/wall))
					qdel(A)
				break
			spawn(1)
			playsound(get_turf(bombkit), 'sound/effects/sparks1.ogg', 50, 1)
			new /obj/structure/rack(bombkit.loc)
			new /obj/item/clothing/shoes/jackboots(bombkit.loc)
			new /obj/item/weapon/tank/oxygen(bombkit.loc)
			new /obj/item/clothing/suit/bomb_suit(bombkit.loc)
			new /obj/item/clothing/mask/gas(bombkit.loc)
			new /obj/item/clothing/head/bomb_hood(bombkit.loc)
			for(var/atom/A in get_turf(bombkit2))
				if(istype(A,/mob/living))
					var/mob/living/unlucky_person = A
					unlucky_person.gib()
				if(istype(A,/obj) || istype(A,/turf/simulated/wall))
					qdel(A)
				break
			spawn(1)
			playsound(get_turf(bombkit2), 'sound/effects/sparks1.ogg', 50, 1)
			new /obj/structure/rack(bombkit2.loc)
			new /obj/item/clothing/shoes/jackboots(bombkit2.loc)
			new /obj/item/weapon/tank/oxygen(bombkit2.loc)
			new /obj/item/clothing/suit/bomb_suit(bombkit2.loc)
			new /obj/item/clothing/mask/gas(bombkit2.loc)
			new /obj/item/clothing/head/bomb_hood(bombkit2.loc)
			for(var/atom/A in get_turf(bombkit3))
				if(istype(A,/mob/living))
					var/mob/living/unlucky_person = A
					unlucky_person.gib()
				if(istype(A,/obj) || istype(A,/turf/simulated/wall))
					qdel(A)
				break
			spawn(1)
			playsound(get_turf(bombkit3), 'sound/effects/sparks1.ogg', 50, 1)
			new /obj/structure/rack(bombkit3.loc)
			new /obj/item/clothing/shoes/jackboots(bombkit3.loc)
			new /obj/item/weapon/tank/oxygen(bombkit3.loc)
			new /obj/item/clothing/suit/bomb_suit(bombkit3.loc)
			new /obj/item/clothing/mask/gas(bombkit3.loc)
			new /obj/item/clothing/head/bomb_hood(bombkit3.loc)
			//WE BUILD (RCDs are disabled)
			for(var/atom/A in get_turf(buildkit))
				if(istype(A,/mob/living))
					var/mob/living/unlucky_person = A
					unlucky_person.gib()
				if(istype(A,/obj) || istype(A,/turf/simulated/wall))
					qdel(A)
				break
			spawn(1)
			playsound(get_turf(buildkit), 'sound/effects/sparks1.ogg', 50, 1)
			new /obj/structure/rack(buildkit.loc)
			new /obj/item/stack/sheet/metal(buildkit.loc, 30)
			new /obj/item/stack/sheet/glass/plasmarglass(buildkit.loc, 30) //Bomb-proof, so very useful
			new /obj/item/weapon/storage/toolbox/electrical(buildkit.loc)
			new /obj/item/weapon/storage/toolbox/mechanical(buildkit.loc)
			new /obj/item/clothing/head/welding(buildkit.loc)
			new /obj/item/weapon/grenade/chem_grenade/metalfoam(buildkit.loc) //Useful for sealing breaches in a pinch
			new /obj/item/weapon/grenade/chem_grenade/metalfoam(buildkit.loc)
			new /obj/item/device/multitool(buildkit.loc)
			//Sometimes you just need to eat
			for(var/atom/A in get_turf(pizzakit))
				if(istype(A,/mob/living))
					var/mob/living/unlucky_person = A
					unlucky_person.gib()
				if(istype(A,/obj) || istype(A,/turf/simulated/wall))
					qdel(A) //Telegib
				break
			spawn(1)
			playsound(get_turf(pizzakit), 'sound/effects/sparks1.ogg', 50, 1)
			new /obj/structure/rack(pizzakit.loc)
			new /obj/item/pizzabox/margherita(pizzakit.loc)
			new /obj/item/pizzabox/mushroom(pizzakit.loc)
			new /obj/item/pizzabox/meat(pizzakit.loc)
			new /obj/item/pizzabox/vegetable(pizzakit.loc)
			new /obj/item/weapon/kitchenknife(pizzakit.loc)
			//Don't panic, honest
			for(var/atom/A in get_turf(panickit))
				if(istype(A,/mob/living))
					var/mob/living/unlucky_person = A
					unlucky_person.gib()
				if(istype(A,/obj) || istype(A,/turf/simulated/wall))
					qdel(A)
				break
			spawn(1)
			playsound(get_turf(panickit), 'sound/effects/sparks1.ogg', 50, 1)
			new /obj/structure/rack(panickit.loc)
			new /obj/item/weapon/storage/toolbox/emergency(panickit.loc)
			new /obj/item/weapon/storage/toolbox/emergency(panickit.loc)
			new /obj/item/device/violin(panickit.loc) //My tune will go on
			new /obj/item/weapon/paper_bin(panickit.loc) //Any last wishes ?
			new /obj/item/weapon/pen/red(panickit.loc)
			//One local shield. We're on budget cuts, you see
			for(var/atom/A in get_turf(shieldkit))
				if(istype(A,/mob/living))
					var/mob/living/unlucky_person = A
					unlucky_person.gib()
				if(istype(A,/obj) || istype(A,/turf/simulated/wall))
					qdel(A) //Telegib
				break
			spawn(1)
			playsound(get_turf(shieldkit), 'sound/effects/sparks1.ogg', 50, 1)
			new /obj/machinery/shield_gen(shieldkit.loc)
			//Add new kits here, then add to map

		spawn(meteordelay)
			nometeors = 0

/datum/game_mode/meteor/process()
	spawn(50) //Only check every 5 seconds to avoid lag
	if(nometeors == 0)
		if(prob(25)) //25 % chance of dakka dakka dakka (50 meteors. 50 GODDAMN METEORS IN A ROW)
			meteor_wave(meteors_in_big_wave)
		else if(prob(75))	//75 % chance of stopping here and firing 30 meteors
			meteor_wave(meteors_in_wave)
		else if(prob(90))	//90 % chance of firing 10 meteors
			meteor_wave(meteors_in_small_wave)

/datum/game_mode/meteor/declare_completion()
	var/text
	var/survivors = 0
	for(var/mob/living/player in player_list)
		if(player.stat != DEAD)
			var/turf/location = get_turf(player.loc)
			if(!location)	continue
			switch(location.loc.type)
				if(/area/shuttle/escape/centcom)
					text += "<br><b><font size=2>[player.real_name] escaped on the emergency shuttle</font></b>"
				if(/area/shuttle/escape_pod1/centcom, /area/shuttle/escape_pod2/centcom, /area/shuttle/escape_pod3/centcom, /area/shuttle/escape_pod5/centcom)
					text += "<br><font size=2>[player.real_name] escaped in a life pod.</font>"
				else
					text += "<br><font size=1>[player.real_name] survived but is stranded without any hope of rescue.</font>"
			survivors++

	if(survivors)
		world << "\blue <B>The following survived the meteor storm</B>:[text]"
	else
		world << "\blue <B>Nobody survived the meteor storm!</B>"

	feedback_set_details("round_end_result","end - evacuation")
	feedback_set("round_end_result",survivors)

	..()
	return 1
