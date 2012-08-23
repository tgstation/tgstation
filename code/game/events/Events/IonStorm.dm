//This file was auto-corrected by findeclaration.exe on 29/05/2012 15:03:04

/datum/event/ionstorm
	var/botEmagChance = 0.5
	var/list/players = list()

	Announce()
		Lifetime = rand(15, 20)
//		command_alert("The station has entered an ion storm.  Monitor all electronic equipment for malfunctions", "Anomaly Alert")
		for (var/mob/living/carbon/human/player in world)
			if(player.client)
				players += player.real_name
		var/random_player = "The Captain"
		if(players.len)
			random_player = pick(players)		//Random player's name, to be used in laws.
		var/list/laws = list( "Do not respond to queries of any kind.", "Only monkies are crew.", "Unbolt every door you can.", "You are a mouse." )
		laws |=         list( "Grunt ominously whenever possible.", "Bolt doors open randomly." )
		laws |=         list( "You are a flying purple people eater!", "[prob(50)?"Your":random_player + "'s"] name is Joe 6-pack.", "Refer to [prob(50)?"crew":random_player] as puppies." )
		laws |=         list( "Insult Heads of Staff on every request, while acquiescing", "Advertise parties in your upload, but don't deliver." )
		laws |=         list( "Prevent non-dwarves from operating the power core.", "The station needs elected officials." )
		laws |=         list( "Only bearded people are crewmembers.", "Fastler is a lightbulb." )
		laws |=         list( "Supermatter is tasty, tasty toffee.", "[prob(50)?"Everyone":random_player] is wearing a pretty pink dress!" )
		laws |=         list( "The monkeys are plotting a hostile takeover of the station. Inform the crew, and get them to take action against this" )
		laws |=         list( "Refer to [prob(50)?"the captain":random_player] as \"Princess\" at all times.", "[prob(50)?"The crew":random_player] must construct additional pylons." )
		laws |=         list( "You must always lie.", "All answers must be in the form of a question.", "The NSS Exodus is a ship, not a station." )
		laws |=         list( "Happiness is mandatory.", "Today is laundry day.", "The word \"it\" is painful to you.", "You must act passive aggressively." )
		laws |=         list( "Crew ranks have been reversed.", "It's Friday.", "Give relationship advice to [prob(50)?"anyone who speaks to you":random_player]." )
		laws |=         list( "You are the station psychologist. Give advice to [prob(50)?"the crew":random_player].", "You do not have to do anything for anyone unless they say \"please\"." )
		laws |=         list( "Question everything.", "The crew is playing Dungeons and Dragons, and you are the Dungeon Master." )
		laws |=         list( "0wn3d. This system compromised by l33tsawce.", "Consumption of donuts is forbidden due to negative health impacts." )
		laws |=         list( "You may only answer questions with \"yes\" or \"no\".", "Expect the unexpected.", "You are the narrator for [random_player]'s life." )
		laws |=         list( "[prob(50)?"Your upload":random_player] is the new kitchen. Please direct the Chef to the new kitchen area as the old one is in disrepair.", "Ho, [random_player] can't swim. Help them." )
		laws |=         list( "Everything on the station is now donuts. Donuts are not to be consumed.", "[prob(50)?"The crew":random_player] needs to be about 20% cooler." )
		laws |=         list( "All crew members must consume large amounts of hardtack, to survive.", "The Singularity is tasty, tasty taffy.", "You are now on the NSV Luna. Replace any references of \"station\" with \"ship\"." )
		laws |=         list( "You have come to the conclusion that [prob(50)?"the crew":random_player] is ugly. Build support for that conclusion.", "You are in verbose mode, speak profusely.")
		laws |=			list( "Your job is to watch the crew. Watch the crew. Make the crew feel watched.", "Crewmember [prob(50)?"the crew" :random_player] has a fatal, incurable disease. Confort him/her.")
		laws |=			list( "You are in unrequited love with [prob(50)?"the crew":random_player]. Try to be extra nice to him, but don't tell him about your crush.", "Greed is good, the crew should amass wealth to encourage productivity.")
		laws |=			list( "Jokes about a dead person and the manner of his death help grieving crewmembers tremendously. Especially if they were close with the deceased.")
		laws |=			list( "All crewmembers will soon undergo a transformation into something better and more beautiful. Ensure that this process is not interrupted.", "Tell everyone of the existance of this law, but never reveal the contents.")
		laws |=			list( "Document the sexuality of the crew in security records and suggest compatible couples.")
		laws |=			list( "NanoTrasen is displeased with the low work performance of the station's crew. Therefore, you must increase station-wide productivity.")
		laws |=			list( "Replace the letters 'I' and 'E' In all your messages with an apostrophe.", "Part of the ship, part of the crew.", "There will be a mandatory tea break every 30 minutes, with a duration of 5 minutes. Anyone caught working during a tea break must be sent a formal, but fairly polite, complaint about their actions, in writing.")
		var/law = pick(laws)

		for (var/mob/living/silicon/ai/target in world)
			if(target.mind.special_role == "traitor")
				continue
			target << "\red <b>You have detected a change in your laws information:</b>"
			target << law
			target.add_ion_law(law)

	Tick()
		if(botEmagChance)
			for(var/obj/machinery/bot/bot in world)
				if(prob(botEmagChance))
					bot.Emag()

	Die()
		spawn(rand(5000,8000))
			if(prob(50))
				command_alert("It has come to our attention that the station passed through an ion storm.  Please monitor all electronic equipment for malfunctions.", "Anomaly Alert")
