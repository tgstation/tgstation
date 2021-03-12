
//yep you guessed it back at it again with another datum singleton.
/datum/orion_event
	var/name = "this displays the events name"
	var/text = "this displays a blurb about the event"
	///pickweight to show up. will still be in the events pool if added to the events list but not RANDOM, only triggered.
	var/weight = 0
	///buttons to pick in response to the event. Don't worry, orion js will handle the rest
	var/list/event_responses = list()
	///default emag effect of events is to play an audible message and sound
	var/emag_message = "<span class='userdanger'>Coders forgot to set this!</span>"
	var/emag_sound = 'sound/effects/bamf.ogg'
	///our game
	var/obj/machinery/computer/arcade/orion_trail/game
	///gaming skill level of the player
	var/gamerSkillLevel = 0
	///gaming skill of the player
	var/gamerSkill = 0
	///some other metric that makes it easier to do randoms with skill testing, god really 3 vars guys
	var/gamerSkillRands = 0

/datum/orion_event/New(_game)
	. = ..()
	game = _game

/**
 * What happens when this event is selected to trigger, sets vars. also can set some event pre-encounter randomization
 *
 * Arguments:
 * * _gamerSkill: gaming skill of the player
 * * _gamerSkillLevel: gaming skill level of the player
 */
/datum/orion_event/proc/on_select(_gamerSkill, _gamerSkillLevel, _gamerSkillRands)
	SHOULD_CALL_PARENT(TRUE)
	gamerSkillLevel = _gamerSkillLevel
	gamerSkill = _gamerSkill
	gamerSkillRands = _gamerSkillRands

/**
 * What happens when you respond to this event by choosing one of the buttons
 *
 * Arguments:
 * * choice: name of the button you pressed.
 */
/datum/orion_event/proc/response(choice)
	game.event = null

/**
 * Some effect that happens to the carbon when this event triggers on an emagged arcade machine.
 *
 * By default, it just sends an audible message and a sound, both vars on the orion datum
 * Arguments:
 * * gamer: victim to apply effects to
 * * gamerSkill: skill of the gamer, because gamers gods can lessen the effects of the emagged machine
 * * gamerSkillLevel: skill level of the gamer, another way to measure emag downside avoidance
 */
/datum/orion_event/proc/emag_effect(mob/living/carbon/gamer)
	if(emag_message)
		game.audible_message(emag_message)
	if(emag_sound)
		playsound(game, emag_sound, 100, TRUE)

///Engine Breakdown - spend one engine part or wait 3 days (harmless emag effect)
/datum/orion_event/engine_part
	name = "Engine Breakdown"
	text = "Oh no! The engine has broken down! \
	You can repair it with an engine part, or you \
	can make repairs for 3 days."
	emag_message = "<span class='warning'>You hear some large object lurch to a halt right behind you! When you go to look, nothing's there...</span>"
	emag_sound = 'sound/effects/creak1.ogg'
	weight = 2
	event_responses = list()

/datum/orion_event/engine_part/on_select(_gamerSkill, _gamerSkillLevel, gamerSkillRands)
	if(game.engine >= 1)
		event_responses += "Fix Engine"
	event_responses += "Wait"

/datum/orion_event/engine_part/response(choice)
	if(choice == "Fix Engine")
		game.engine = max(0, --game.engine)
	else
		game.food -= ((game.alive + game.lings_aboard)*2)*3
	event_responses.Cut()
	..()

///Malfunction - spend one engine part or wait 3 days (emag effect randomizes some stats)
/datum/orion_event/electronic_part
	name = "Malfunction"
	text = "The ship's systems are malfunctioning! \
	You can replace the broken electronics with spares, \
	or you can spend 3 days troubleshooting the AI."
	weight = 2
	//set by select
	event_responses = list()

/datum/orion_event/electronic_part/on_select(_gamerSkill, _gamerSkillLevel, gamerSkillRands)
	if(game.engine >= 1)
		event_responses += "Repair Electronics"
	event_responses += "Wait"

/datum/orion_event/electronic_part/response(choice)
	if(choice == "Repair Electronics")
		game.electronics = max(0, --game.electronics)
	else
		game.food -= ((game.alive + game.lings_aboard)*2)*3
	event_responses.Cut()
	..()

/datum/orion_event/electronic_part/emag_effect(mob/living/carbon/gamer)
	playsound(game, 'sound/effects/empulse.ogg', 50, TRUE)
	game.visible_message("<span class='danger'>[src] malfunctions, randomizing in-game stats!</span>")
	var/oldfood = game.food
	var/oldfuel = game.fuel
	game.food = rand(10,80) / rand(1,2)
	game.fuel = rand(10,60) / rand(1,2)
	if(game.electronics)
		sleep(10)
		if(oldfuel > game.fuel && oldfood > game.food)
			game.audible_message("<span class='danger'>[src] lets out a somehow reassuring chime.</span>")
		else if(oldfuel < game.fuel || oldfood < game.food)
			game.audible_message("<span class='danger'>[src] lets out a somehow ominous chime.</span>")
		game.food = oldfood
		game.fuel = oldfuel
		playsound(game, 'sound/machines/chime.ogg', 50, TRUE)

///Collision - spend one engine part or wait 3 days (has a nasty emag effect)
/datum/orion_event/hull_part
	name = "Collision"
	text = "Something hit us! Looks like there's some hull damage. \
	You can repair the damage with hull plates, or you can spend \
	the next 3 days welding scrap together."
	weight = 2
	event_responses = list()

/datum/orion_event/hull_part/on_select(_gamerSkill, _gamerSkillLevel, gamerSkillRands)
	if(game.hull >= 1)
		event_responses += "Restore Hull"
	event_responses += "Wait"

/datum/orion_event/hull_part/response(choice)
	if(choice == "Restore Hull")
		game.hull = max(0, --game.hull)
	else
		game.food -= ((game.alive + game.lings_aboard)*2)*3
	event_responses.Cut()
	..()

/datum/orion_event/hull_part/emag_effect(mob/living/carbon/gamer)
	if(prob(10+gamerSkill))
		game.say("Something slams into the floor around [src] - luckily, it didn't get through!")
		playsound(game, 'sound/effects/bang.ogg', 50, TRUE)
		return
	playsound(game, 'sound/effects/bang.ogg', 100, TRUE)
	var/turf/open/floor/F
	for(F in orange(1, src))
		F.ScrapeAway()
	game.say("Something slams into the floor around [src], exposing it to space!")
	if(game.hull)
		sleep(10)
		game.say("A new floor suddenly appears around [src]. What the hell?")
		playsound(game, 'sound/weapons/genhit.ogg', 100, TRUE)
		var/turf/open/space/T
		for(T in orange(1, src))
			T.PlaceOnTop(/turf/open/floor/plating)

/datum/orion_event/old_ship
	name = "Derelict Ship"
	text = "Your crew spots an old ship floating through space. \
	It might have some supplies, but then again it looks rather unsafe."
	weight = 2
	event_responses = list("Explore Ship", "Leave the Derelict")

/datum/orion_event/old_ship/response(choice)
	if(choice == "Leave the Derelict")
		return ..()
	game.encounter_event(/datum/orion_event/exploring_derelict)

/datum/orion_event/old_ship/emag_effect(mob/living/carbon/gamer)
	return //do nothing because this leads into an event where we actually will do something.

/datum/orion_event/exploring_derelict
	name = "Derelict Exploration"
	weight = 2
	//set by on_select
	event_responses = list()

/datum/orion_event/exploring_derelict/on_select(_gamerSkill, _gamerSkillLevel, gamerSkillRands)
	switch(rand(100))
		if(0 to 14)
			var/rescued = game.add_crewmember()
			var/oldfood = rand(1,7)
			var/oldfuel = rand(4,10)
			game.food += oldfood
			game.fuel += oldfuel
			text = "As you look through it you find some supplies and a living person! \
			[rescued] was rescued from the abandoned ship! You also found [oldfood] Food and [oldfuel] Fuel."
			event_responses += "Welcome aboard."
		if(15 to 35)
			var/lostfuel = rand(4,7)
			var/deadname = game.remove_crewmember()
			game.fuel -= lostfuel
			text = "[deadname] was lost deep in the wreckage, and your own vessel lost [lostfuel] Fuel maneuvering to the the abandoned ship."
			event_responses += "Where did you go?!"
		if(36 to 65)
			var/oldfood = rand(5,11)
			game.food += oldfood
			game.engine++
			text = "You found [oldfood] Food and some parts amongst the wreck."
			event_responses += "A good find."
		else
			text = "As you look through the wreck you cannot find much of use."
			event_responses += "Continue travels."

/datum/orion_event/exploring_derelict/response(choice)
	event_responses.Cut() //so they don't pile up between games
	..()

/datum/orion_event/raiders
	name = "Raiders"
	weight = 3
	event_responses = list("Continue")

/datum/orion_event/raiders/on_select(_gamerSkill, _gamerSkillLevel, gamerSkillRands)
	text = "Raiders have come aboard your ship! "
	if(prob(50))
		var/sfood = rand(1,10)
		var/sfuel = rand(1,10)
		game.food -= sfood
		game.fuel -= sfuel
		text += "They have stolen [sfood] Food and [sfuel] Fuel."
	else if(prob(10))
		var/deadname = game.remove_crewmember()
		text += "[deadname] tried to fight back, but was killed."
	else
		text += "Fortunately, you fended them off without any trouble."

/datum/orion_event/raiders/emag_effect(mob/living/carbon/gamer)
	if(prob(50-gamerSkill))
		to_chat(usr, "<span class='userdanger'>You hear battle shouts. The tramping of boots on cold metal. Screams of agony. The rush of venting air. Are you going insane?</span>")
		gamer.hallucination += 30
	else
		to_chat(usr, "<span class='userdanger'>Something strikes you from behind! It hurts like hell and feel like a blunt weapon, but nothing is there...</span>")
		gamer.take_bodypart_damage(30)
		playsound(game, 'sound/weapons/genhit2.ogg', 100, TRUE)

/datum/orion_event/illness
	name = "Space Illness"
	//needs to specify who died, set by select
	weight = 3
	event_responses = list("Continue")

/datum/orion_event/illness/on_select(_gamerSkill, _gamerSkillLevel, gamerSkillRands)
	var/deadname = game.remove_crewmember()
	text = "A deadly illness has been contracted! [deadname] was killed by the disease."

/datum/orion_event/illness/emag_effect(mob/living/carbon/gamer)
	var/maxSeverity = 3
	if(gamerSkillLevel >= SKILL_LEVEL_EXPERT)
		maxSeverity = 2 //part of gitting gud is rng mitigation
	var/severity = rand(1,maxSeverity) //pray to RNGesus. PRAY, PIGS
	if(severity == 1)
		to_chat(gamer, "<span class='userdanger'>You suddenly feel slightly nauseated.</span>" )
		gamer.adjust_disgust(50)
	if(severity == 2)
		to_chat(usr, "<span class='userdanger'>You suddenly feel extremely nauseated and hunch over until it passes.</span>")
		gamer.adjust_disgust(110)
		gamer.Stun(60)
	if(severity >= 3) //you didn't pray hard enough
		to_chat(gamer, "<span class='warning'>An overpowering wave of nausea consumes over you. You hunch over, your stomach's contents preparing for a spectacular exit.</span>")
		gamer.adjust_disgust(150) //max this bitch out so they barf a lot
		gamer.Stun(100)

/datum/orion_event/flux
	name = "Flux"
	text = "This region of space is highly turbulent. If we go \
	slowly we may avoid more damage, but if we keep our speed we won't waste supplies."
	weight = 1
	event_responses = list("Keep Speed","Slow Down")

/datum/orion_event/flux/response(choice)
	if("Keep Speed")
		if(prob(25))
			return ..()
		game.encounter_event(/datum/orion_event/engine_part)
	else //Slow Down response
		game.food -= (game.alive+game.lings_aboard)*2
		game.fuel -= 5
		..()

/datum/orion_event/flux/emag_effect(mob/living/carbon/gamer)
	if(prob(25 + gamerSkill))//withstand the wind with your GAMER SKILL
		to_chat(gamer, "<span class='userdanger'>A violent gale blows past you, and you barely manage to stay standing!</span>")
		return
	gamer.Paralyze(60)
	game.say("A sudden gust of powerful wind slams [gamer] into the floor!")
	gamer.take_bodypart_damage(25)
	playsound(game, 'sound/weapons/genhit.ogg', 100, TRUE)

/datum/orion_event/changeling_infiltration
	name = "Changeling Infiltration"
	event_responses = list("Continue")

/datum/orion_event/changeling_infiltration/on_select(_gamerSkill, _gamerSkillLevel, gamerSkillRands)
	. = ..()
	text = "Strange reports warn of changelings infiltrating crews on trips to Orion..."
	if(game.settlers.len <= 2)
		text += " But your crew's chance of reaching Orion is so slim the changelings likely avoided your ship..."
		if(prob(10)) // "likely", I didn't say it was guaranteed! //worst outcome too because changeling controls don't even enable
			game.lings_aboard = min(++game.lings_aboard,2)
	else
		if(game.lings_aboard) //less likely to stack lings
			if(prob(20))
				game.lings_aboard = min(++game.lings_aboard,2)
		else if(prob(70))
			game.lings_aboard = min(++game.lings_aboard,2)

		text += " You have reasonable suspicion there may be a changeling. Some menu options have been changed."
		game.lings_suspected = TRUE

/datum/orion_event/changeling_attack
	name = "Changeling Attack"
	event_responses = list("Continue")

/datum/orion_event/changeling_attack/on_select(_gamerSkill, _gamerSkillLevel, gamerSkillRands)
	. = ..()
	text = ""
	if(game.lings_aboard <= 0) //shouldn't trigger, but hey.
		text = "Haha, fooled you, there are no changelings on board! (You should report this to a coder :S )"
		return
	var/ling1 = game.remove_crewmember()
	var/ling2 = ""
	if(game.lings_aboard >= 2)
		ling2 = game.remove_crewmember()

	text = "Changelings among your crew suddenly burst from hiding and attack!"
	if(ling2)
		text += " [ling1] and [ling2]'s arms twist and contort into grotesque blades!"
	else
		text += " [ling1]'s arm twists and contorts into a grotesque blade!"

	var/chance2attack = game.alive*20
	if(!prob(chance2attack))
		text += " [pick("Sensing unfavorable odds", "After a failed attack", "Suddenly breaking nerve")], \
		the changeling[ling2 ? "s":""] vanish[ling2 ? "" : "es"] into space through the airlocks! You're safe... for now."
		if(ling2)
			game.lings_aboard = max(0,game.lings_aboard-2)
		else
			game.lings_aboard = max(0,--game.lings_aboard)
		return

	var/chancetokill = 30*game.lings_aboard-(5*game.alive) //eg: 30*2-(10) = 50%, 2 lings, 2 crew is 50% chance
	if(prob(chancetokill))
		var/deadguy = game.remove_crewmember()
		var/murder_text = pick(
			"The changeling[ling2 ? "s" : ""] bring[ling2 ? "" : "s"] down [deadguy] and disembowel[ling2 ? "" : "s"] them in a spray of gore!", \
			"[ling2 ? pick(ling1, ling2) : ling1] corners [deadguy] and impales them through the stomach!", \
			"[ling2 ? pick(ling1, ling2) : ling1] decapitates [deadguy] in a single cleaving arc!")
		text += " [murder_text]"
	else
		text += " You valiantly fight off the changeling[ling2 ? "s":""]!"
		if(ling2)
			game.food += 30
			game.lings_aboard = max(0, game.lings_aboard-2)
		else
			game.food += 15
			game.lings_aboard = max(0, --game.lings_aboard)
		text += " Well, it's perfectly good food...\
			You cut the changeling[ling2 ? "s" : ""] into meat, gaining [ling2 ? "30" : "15"] Food!"

///Black Hole - final  (emag can spawn singulo, see death event)
/datum/orion_event/black_hole
	name = "Looming Black Hole"
	text = "Sensors indicate that a black hole's gravitational field is \
	affecting the region of space we were headed through. We could stay \
	of course, but risk of being overcome by its gravity, or we could \
	change course to go around, which will take longer."
	event_responses = list("Speed Past","Go Around")

/datum/orion_event/black_hole/response(choice)
	if(choice == "Go Around")
		game.food -= ((game.alive + game.lings_aboard)*2)*3
		game.fuel -= 15
		game.turns += 1
		return ..()
	if(prob(75-gamerSkill))
		game.encounter_event(/datum/orion_event/black_hole_death)
		return
	game.turns += 1
	..()

///You died to a black hole, have some fluff text
/datum/orion_event/black_hole_death
	name = "Event Horizon"
	text = "As you jet the shuttle forward, you realize you underestimated the \
	pull of the black hole. Try as you may, you cannot escape its stellar force. \
	It isn't long before you pass the event horizon, and you close your eyes, readying \
	to be torn apart as your ship begins to buckle under the immense pull."
	event_responses = list("Oh...")

/datum/orion_event/black_hole_death/response(choice)
	game.set_game_over(usr, "You were swept away into the black hole.")
	..()

/datum/orion_event/black_hole_death/emag_effect(mob/living/carbon/gamer)
	if(game.obj_flags & EMAGGED)
		playsound(game.loc, 'sound/effects/supermatter.ogg', 100, TRUE)
		game.say("A miniature black hole suddenly appears in front of [game], devouring [gamer] alive!")
		gamer.Stun(200, ignore_canstun = TRUE) //you can't run :^)
		var/S = new /obj/singularity/academy(gamer.loc)
		addtimer(CALLBACK(game, /atom/movable/proc/say, "[S] winks out, just as suddenly as it appeared."), 50)
		QDEL_IN(S, 5 SECONDS)

///You found a space port!
/datum/orion_event/space_port
	name = "Space Port"
	text = "You have spotted a small pocket of civilization along the Orion Trail. \
	A friendly hailing from the nearby space port assures that you can dock to rest \
	and prepare for the travels ahead."
	weight = 2
	event_responses = list("Dock")

/datum/orion_event/space_port/response(choice)
	game.gameStatus = ORION_STATUS_MARKET
	..()

///You found the midway mark!
/datum/orion_event/space_port/tau_ceti
	name = "Tau Ceti Beta"
	text = "You have reached the halfway point in your journey, the largest space port \
	along the trail: Tau Ceti Beta. It bustles with activity and life. It gives you hope \
	of finding your future at Orion."
	//triggered by getting halfway
	weight = 0

///You raided a space port!
/datum/orion_event/space_port_raid
	name = "Space Port Raid"

	event_responses = list("Continue")

/datum/orion_event/space_port_raid/on_select(_gamerSkill, _gamerSkillLevel, gamerSkillRands)
	. = ..()
	var/success = min(15 * game.alive + gamerSkill,100) //default crew (4) have a 60% chance
	game.spaceport_raided = TRUE

	var/FU = 0
	var/FO = 0
	if(prob(success))
		FU = rand(5 + gamerSkillRands,15 + gamerSkillRands)
		FO = rand(5 + gamerSkillRands,15 + gamerSkillRands)
		text = "You successfully raided the spaceport! You gained [FU] Fuel and [FO] Food! (+[FU]FU,+[FO]FO)"
		usr?.mind?.adjust_experience(/datum/skill/gaming, 10)
	else
		FU = rand(-5,-15)
		FO = rand(-5,-15)
		text = "You failed to raid the spaceport! You lost [FU*-1] Fuel and [FO*-1] Food in your scramble to escape! ([FU]FU,[FO]FO)"

		//your chance of lose a crewmember is 1/2 your chance of success
		//this makes higher % failures hurt more, don't get cocky space cowboy!
		if(prob(success*5))
			var/lost_crew = game.remove_crewmember()
			if(!game.settlers.len)
				game.set_game_over(usr, "You were gunned down by space port security.")
				return ..()
			text = "You failed to raid the spaceport! You lost [FU*-1] Fuel and [FO*-1] Food, AND [lost_crew] in your scramble to escape! ([FU]FI,[FO]FO,-Crew)"
			if(game.obj_flags & EMAGGED)
				game.say("WEEWOO! WEEWOO! Spaceport security en route!")
				playsound(game, 'sound/items/weeoo1.ogg', 100, FALSE)
				for(var/i, i<=3, i++)
					var/mob/living/simple_animal/hostile/syndicate/ranged/smg/orion/O = new/mob/living/simple_animal/hostile/syndicate/ranged/smg/orion(get_turf(src))
					O.target = usr
	game.fuel += FU
	game.food += FO

