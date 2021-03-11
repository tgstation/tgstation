
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

/datum/orion_event/New(_game)
	. = ..()
	game = _game

/**
 * What happens when this event is selected to trigger, in case you want an event that has changing text or randomization
 *
 * Arguments:
 * * None!
 */
/datum/orion_event/proc/on_select()
	return

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
/datum/orion_event/proc/emag_effect(mob/living/carbon/gamer, gamerSkill, gamerSkillLevel)
	game.audible_message(emag_message)
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
	event_responses = list("Use Part", "Wait")

/datum/orion_event/engine_part/response(choice)
	if(choice == "Use Part")
		game.engine = max(0, --game.engine)
	else
		game.food -= ((game.alive + game.lings_aboard)*2)*3
	..()

///Malfunction - spend one engine part or wait 3 days (emag effect randomizes some stats)
/datum/orion_event/electronic_part
	name = "Malfunction"
	text = "The ship's systems are malfunctioning! \
	You can replace the broken electronics with spares, \
	or you can spend 3 days troubleshooting the AI."
	weight = 2
	event_responses = list("Use Part", "Wait")

/datum/orion_event/electronic_part/response(choice)
	if(choice == "Use Part")
		game.electronics = max(0, --game.electronics)
	else
		game.food -= ((game.alive + game.lings_aboard)*2)*3
	..()

/datum/orion_event/electronic_part/emag_effect(mob/living/carbon/gamer, gamerSkill, gamerSkillLevel)
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
	event_responses = list("Use Part", "Wait")

/datum/orion_event/hull_part/response(choice)
	if(choice == "Use Part")
		game.hull = max(0, --game.hull)
	else
		game.food -= ((game.alive + game.lings_aboard)*2)*3
	..()

/datum/orion_event/hull_part/emag_effect(mob/living/carbon/gamer, gamerSkill, gamerSkillLevel)
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

/datum/orion_event/old_ship/emag_effect(mob/living/carbon/gamer, gamerSkill, gamerSkillLevel)
	return //do nothing because this leads into an event where we actually will do something.

/datum/orion_event/exploring_derelict
	name = "Derelict Exploration"
	text = "Your crew spots an old ship floating through space. \
	It might have some supplies, but then again it looks rather unsafe."
	weight = 2
	//set by on_select
	event_responses = list()

/datum/orion_event/exploring_derelict/on_select()
	switch(rand(100))
		if(0 to 15)
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
		if(35 to 65)
			var/oldfood = rand(5,11)
			game.food += oldfood
			game.engine++
			text = "You found [oldfood] Food and some parts amongst the wreck."
			event_responses += "A good find."
		else
			text = "As you look through the wreck you cannot find much of use."
			event_responses += "Continue travels."

//WIP
/datum/orion_event/raiders
	name = "Raider"
	text = "Your crew spots an old ship floating through space. \
	It might have some supplies, but then again it looks rather unsafe."
	weight = 2
	//set by on_select
	event_responses = list()

/datum/orion_event/raiders/emag_effect(mob/living/carbon/gamer, gamerSkill, gamerSkillLevel)
	if(prob(50-gamerSkill))
		to_chat(usr, "<span class='userdanger'>You hear battle shouts. The tramping of boots on cold metal. Screams of agony. The rush of venting air. Are you going insane?</span>")
		gamer.hallucination += 30
	else
		to_chat(usr, "<span class='userdanger'>Something strikes you from behind! It hurts like hell and feel like a blunt weapon, but nothing is there...</span>")
		gamer.take_bodypart_damage(30)
		playsound(game, 'sound/weapons/genhit2.ogg', 100, TRUE)

//WIP
/datum/orion_event/illness
	name = "Space Illness"
	text = "Your crew spots an old ship floating through space. \
	It might have some supplies, but then again it looks rather unsafe."
	weight = 2
	//set by on_select
	event_responses = list()

/datum/orion_event/illness/emag_effect(mob/living/carbon/gamer, gamerSkill, gamerSkillLevel)
	var/maxSeverity = 3
	if(gamerSkillLevel >= SKILL_LEVEL_EXPERT)
		maxSeverity = 2 //part of gitting gud is rng mitigation
	var/severity = rand(1,maxSeverity) //pray to RNGesus. PRAY, PIGS
	if(severity == 1)
		to_chat(gamer, "<span class='userdanger'>You suddenly feel slightly nauseated.</span>" )
	if(severity == 2)
		to_chat(usr, "<span class='userdanger'>You suddenly feel extremely nauseated and hunch over until it passes.</span>")
		gamer.Stun(60)
	if(severity >= 3) //you didn't pray hard enough
		to_chat(gamer, "<span class='warning'>An overpowering wave of nausea consumes over you. You hunch over, your stomach's contents preparing for a spectacular exit.</span>")
		gamer.Stun(100)
		sleep(30)
		gamer.vomit(10, distance = 5)

//WIP
/datum/orion_event/flux
	name = "Flux"
	text = "Your crew spots an old ship floating through space. \
	It might have some supplies, but then again it looks rather unsafe."
	weight = 2
	//set by on_select
	event_responses = list()

/datum/orion_event/flux/emag_effect(mob/living/carbon/gamer, gamerSkill, gamerSkillLevel)
	if(prob(25 + gamerSkill))//withstand the wind with your GAMER SKILL
		to_chat(gamer, "<span class='userdanger'>A violent gale blows past you, and you barely manage to stay standing!</span>")
		return
	gamer.Paralyze(60)
	game.say("A sudden gust of powerful wind slams [gamer] into the floor!")
	gamer.take_bodypart_damage(25)
	playsound(game, 'sound/weapons/genhit.ogg', 100, TRUE)

//VERY WIP
/datum/orion_event/changeling_attack
	name = "Changeling Attack"

/datum/orion_event/changeling_infiltration
	name = "Changeling Infiltration"
