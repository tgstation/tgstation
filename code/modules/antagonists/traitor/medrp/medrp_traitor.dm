
//There's a lot in this file but to make a long story short, there are two changes from normal traitors:
//1. Added a lot of fluff, this lets people build and play a better character
//2. Gives them refreshing objectives so they can continually antagonize the round.

/datum/antagonist/traitor/roleplay
	name = "MRP Traitor"
	var/role_title = "Bugged Antagonist. Report this!"
	var/hijacking

/datum/antagonist/traitor/roleplay/on_gain()
	employer = pickweight(list("Syndicate" = 5, "Nanotrasen" = 1))
	..()
	role_title = handle_employer()

/datum/antagonist/traitor/roleplay/greet()
	var/list/result = fluff_strings()
	to_chat(owner.current, result.Join("\n"))
	owner.announce_objectives()

/datum/antagonist/traitor/roleplay/apply_innate_effects()
	. = ..()
	if(!owner)
		CRASH("Antag datum with no owner.")
	owner.AddSpell(new /obj/effect/proc_holder/spell/self/add_objectives(null))

/datum/antagonist/traitor/roleplay/remove_innate_effects()
	. = ..()
	if(!owner)
		CRASH("Antag datum with no owner.")
	for(var/s in owner.spell_list)
		var/obj/effect/proc_holder/spell/self/add_objectives/removed_spell = s
		if(istype(removed_spell))
			owner.RemoveSpell(removed_spell)

/datum/antagonist/traitor/roleplay/proc/handle_employer()
	hijacking = locate(/datum/objective/hijack) in objectives
	switch(employer)
		if("Syndicate")
			if(hijacking)
				return pickweight(list("Tiger Cooperative Fanatic" = 3, "Waffle Corporation Terrorist" = 1, "Animal Rights Consortium" = 1,"Bee Liberation Front" = 1))
			else
				return pickweight(list("Cybersun Industries" = 1, "MI13" = 1, "Gorlex Marauders" = 1, "Donk Corporation" = 1, "Waffle Corporation" = 1))
		if("Nanotrasen")
			if(hijacking)
				return "Gone Postal"
			else
				return pickweight(list("Internal Affairs Agent" = 3, "Corporate Climber" = 1, "Legal Trouble" = 1))

//moved to the bottom of the file because of it's size
/datum/antagonist/traitor/roleplay/proc/fluff_strings()
	. = list()
	switch(role_title)
		if("Tiger Cooperative")
			. += "<span class='userdanger'>You are the Tiger Cooperative Fanatic.</span>"
			. += "<span class='big bold'>Only the enlightened Tiger brethren can be trusted; all others must be expelled from this mortal realm!</span>"
			. += "<span class='notice'>Remember the teachings of Hy-lurgixon; kill first, ask questions later!</span>"
			. += "<span class='notice'>You have been provided with a standard uplink to prove yourself to the changeling hive. If you accomplish your tasks, you will be assimilated.</span>"
		if("Waffle Corporation Terrorist")
			. += "<span class='userdanger'>You are the Waffle Corporation Terrorist.</span>"
			. += "<span class='big bold'>Most other syndicate operatives are not to be trusted, except for members of the Gorlex Marauders. Do not trust fellow members of the Waffle.co (but try not to rat them out), as they might have been assigned opposing objectives.</span>"
			. += "<span class='notice'>It has been a relatively quiet month, many of our black market weapons have gone unused. Let's give Nanotrasen a live test and hijack one of their shuttles.</span>"
			. += "<span class='notice'>You have been provided with a standard uplink to accomplish your task.</span>"
		if("Animal Rights Consortium")
			. += "<span class='userdanger'>You are the ARC Terrorist.</span>"
			. += "<span class='big bold'>You may cooperate with other syndicate operatives if they support our cause. Maybe you can convince the Bee Liberation Front operatives to cooperate for once?</span>"
			. += "<span class='notice'>The creatures of this world must be freed from the iron grasp of Nanotrasen, and you are their only hope!</span>"
			. += "<span class='notice'>The Syndicate have graciously given one of their uplinks for your task.</span>"
		if("Bee Liberation Front")
			. += "<span class='userdanger'>You are the Bee Liberation Front Operative.</span>"
			. += "<span class='big bold'>You may cooperate with other syndicate operatives if they support our cause. Maybe you can recruit an Animal Rights Consort to be useful for once?</span>"
			. += "<span class='notice'>We must prove ourselves to the Syndicate or we will not be able to join. Animal Rights Consort will roll us!</span>"
			. += "<span class='notice'>The Syndicate have graciously given one of their uplinks to see if we are worthy.</span>"
		if("Cybersun Industries")
			. += "<span class='userdanger'>You are from Cybersun Industries.</span>"
			. += "<span class='big bold'>Fellow Cybersun operatives are to be trusted. Members of the MI13 organization can be trusted. All other syndicate operatives are not to be trusted. </span>"
			. += "<span class='warning'>Do not establish substantial presence on the designated facility, as larger incidents are harder to cover up.</span>"
			. += "<span class='notice'>You have been supplied the tools for the job in the form of a standard syndicate uplink.</span>"
		if("MI13")
			. += "<span class='userdanger'>You are the MI13 Agent.</span>"
			. += "<span class='big bold'>You are the only operative we are sending, any others are fake. All other syndicate operatives are not to be trusted, with the exception of Cybersun operatives.</span>"
			. += "<span class='warning'>Avoid killing innocent personnel at all costs. You are not here to mindlessly kill people, as that would attract too much attention and is not our goal. Avoid detection at all costs.</span>"
			. += "<span class='notice'>You have been provided with a standard uplink to accomplish your task.</span>"
		if("Gorlex Marauders")
			. += "<span class='userdanger'>You are a Gorlex Marauder.</span>"
			. += "<span class='big bold'>You may collaborate with any friends of the Syndicate coalition, but keep an eye on any of those Tiger punks if they do show up.</span>"
			. += "<span class='warning'>Getting noticed is not an issue, and you may use any level of ordinance to get the job done. That being said, do not make this sloppy by dragging in random slaughter.</span>"
			. += "<span class='notice'>You have been provided with a standard uplink to accomplish your task.</span>"
		if("Donk Corporation")
			. += "<span class='userdanger'>You are the Donk Co. Traitor.</span>"
			. += "<span class='big bold'>Members of Waffle Co. are to be killed on sight; they are not allowed to be on the station while we're around.</span>"
			. += "<span class='warning'>We do not approve of mindless killing of innocent workers; \"get in, get done, get out\" is our motto.</span>"
			. += "<span class='notice'>You have been provided with a standard uplink to accomplish your task.</span>"
		if("Waffle Corporation")
			. += "<span class='userdanger'>You are the Waffle Co. Traitor.</span>"
			. += "<span class='big bold'>Members of Donk Co. are to be killed on sight; they are not allowed to be on the station while we're around. Do not trust fellow members of the Waffle.co (but try not to rat them out), as they might have been assigned opposing objectives.</span>"
			. += "<span class='warning'>You are not here for a stationwide demonstration. Again, other Waffle Co. Traitors may be, so watch out. Your job is to skillfully execute your tasks.</span>"
			. += "<span class='notice'>You have been provided with a standard uplink to accomplish your task.</span>"
		if("Gone Postal")
			. += "<span class='userdanger'>You have gone postal.</span>"
			. += "<span class='big bold'>If a syndicate learns of your plan, they're going to kill you and take your uplink. Take no chances.</span>"
			. += "<span class='warning'>The preparations are finally complete. Today is the day you go postal. You're going to hijack the emergency shuttle and live a new life free of Nanotrasen.</span>"
			. += "<span class='notice'>You've actually managed to steal a full uplink a month ago. This should certainly help accomplish your goals.</span>"
		if("Internal Affairs Agent")
			. += "<span class='userdanger'>You are the Internal Affairs Agent.</span>"
			. += "<span class='big bold'>If a syndicate learns of your plan, they're going to kill you and take your uplink. Take no chances.</span>"
			. += "<span class='warning'>While you have a license to kill, unneeded property damage or loss of employee life will lead to your contract being terminated.</span>"
			. += "<span class='notice'>For the sake of plausible deniability, you have been equipped with an array of captured Syndicate weaponry available via uplink.</span>"
		if("Corporate Climber")
			. += "<span class='userdanger'>You are the Corporate Climber.</span>"
			. += "<span class='big bold'>Death to the Syndicate.</span>"
			. += "<span class='warning'>Killing needlessly would make you some kind of traitor, or at least definitely seen as one. This is all just a means to an end.</span>"
			. += "<span class='notice'>You know where to go to find yourself a Syndicate uplink. Knock off a few loose weights, and your climb will be so much smoother.</span>"
		if("Legal Trouble")
			. += "<span class='userdanger'>You are in legal trouble.</span>"
			. += "<span class='big bold'>Death to the Syndicate.</span>"
			. += "<span class='warning'>Try to stick to your tasks. If they find out what you're actually doing, they're going to be mopping the floor with you.</span>"
			. += "<span class='notice'>You know where to go to find yourself a Syndicate uplink, and so you have. Just tie up a few loose ends or you'll be dead from the courts by next shift.</span>"
